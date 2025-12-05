// 聊天服务 - 使用 requestInStream 实现真正的流式输出
import { http } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { Message, StreamChunk } from '../models/ChatModels';
import { ApiConfig } from '../config/ApiConfig';

export class ChatService {
  private baseUrl: string = ApiConfig.getBaseUrl();
  private currentRequest: http.HttpRequest | null = null;
  private decoder: util.TextDecoder = new util.TextDecoder('utf-8');

  /**
   * 发送聊天消息（流式）
   * 使用 HarmonyOS 的 requestInStream API 实现真正的流式输出
   */
  async sendMessage(
    message: string,
    history: Message[],
    mode: string,
    onChunk: (chunk: StreamChunk) => void,
    onComplete: () => void,
    onError: (error: string) => void
  ): Promise<void> {
    console.info('=== ChatService.sendMessage 开始 ===');
    console.info('[ChatService] 消息:', message);
    console.info('[ChatService] 模式:', mode);
    
    // 取消之前的请求
    if (this.currentRequest) {
      this.currentRequest.destroy();
      this.currentRequest = null;
    }
    
    // 重置解码器
    this.decoder = new util.TextDecoder('utf-8');
    
    try {
      interface HistoryItem {
        role: string;
        content: string;
        name?: string;
      }
      
      interface RequestBody {
        message: string;
        history: HistoryItem[];
        mode: string;
      }
      
      const requestBody: RequestBody = {
        message: message,
        history: history.map((msg: Message): HistoryItem => ({
          role: msg.role,
          content: msg.content,
          name: msg.name
        })),
        mode: mode
      };

      const url = `${this.baseUrl}/api/chat/stream`;
      console.info('[ChatService] URL:', url);

      this.currentRequest = http.createHttp();
      const httpRequest = this.currentRequest;
      let buffer = '';
      let hasCompleted = false;

      // 注册流式数据接收事件
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        // 使用 TextDecoder 正确处理 UTF-8 编码，避免中文乱码
        const text = this.decoder.decodeWithStream(new Uint8Array(data), { stream: true });
        console.info('[ChatService] 收到数据块:', text.length, '字符');
        
        buffer += text;
        
        // 按行解析 SSE 数据
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';
        
        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const dataStr = line.substring(6).trim();
            
            if (dataStr === '[DONE]') {
              if (!hasCompleted) {
                hasCompleted = true;
                console.info('[ChatService] 流式传输完成');
                onComplete();
              }
              continue;
            }
            
            if (dataStr) {
              try {
                const chunk: StreamChunk = JSON.parse(dataStr);
                onChunk(chunk);
              } catch (e) {
                console.error('[ChatService] 解析失败:', dataStr);
              }
            }
          }
        }
      });

      httpRequest.on('dataEnd', () => {
        console.info('[ChatService] dataEnd 事件');
        if (!hasCompleted) {
          hasCompleted = true;
          onComplete();
        }
        if (this.currentRequest) {
          this.currentRequest.destroy();
          this.currentRequest = null;
        }
      });

      // 使用 requestInStream 发起流式请求
      httpRequest.requestInStream(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream'
          },
          extraData: JSON.stringify(requestBody),
          connectTimeout: ApiConfig.TIMEOUT.CONNECT,
          readTimeout: ApiConfig.TIMEOUT.READ
        },
        (err, responseCode) => {
          if (err) {
            console.error('[ChatService] 请求错误:', err);
            if (!hasCompleted) {
              hasCompleted = true;
              onError('网络请求失败: ' + (err.message || '未知错误'));
            }
            if (this.currentRequest) {
              this.currentRequest.destroy();
              this.currentRequest = null;
            }
            return;
          }
          
          console.info('[ChatService] 响应状态码:', responseCode);
          
          if (responseCode !== 200) {
            if (!hasCompleted) {
              hasCompleted = true;
              onError(`服务器错误: ${responseCode}`);
            }
            if (this.currentRequest) {
              this.currentRequest.destroy();
              this.currentRequest = null;
            }
          }
        }
      );
      
    } catch (error) {
      console.error('[ChatService] 异常:', error);
      onError('发送消息失败: ' + error);
      if (this.currentRequest) {
        this.currentRequest.destroy();
        this.currentRequest = null;
      }
    }
  }

  /**
   * 停止当前请求
   */
  stopCurrentRequest(): void {
    if (this.currentRequest) {
      console.info('[ChatService] 停止当前请求');
      this.currentRequest.destroy();
      this.currentRequest = null;
    }
  }


}

export default new ChatService();
