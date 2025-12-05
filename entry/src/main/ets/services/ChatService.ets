// 聊天服务 - 处理 API 请求
import { http } from '@kit.NetworkKit';
import { Message, StreamChunk } from '../models/ChatModels';
import { ApiConfig } from '../config/ApiConfig';

export class ChatService {
  private baseUrl: string = ApiConfig.getBaseUrl();

  /**
   * 发送聊天消息（流式）
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
    console.info('[ChatService] 历史记录数:', history.length);
    
    let httpRequest: http.HttpRequest | null = null;
    let hasCompleted = false;
    let buffer = '';
    
    try {
      console.info('[ChatService] 创建 HTTP 请求...');
      httpRequest = http.createHttp();
      console.info('[ChatService] HTTP 请求创建成功');
      
      // 构建请求体
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
      console.info(`[ChatService] 目标 URL: ${url}`);
      console.info(`[ChatService] 请求体:`, JSON.stringify(requestBody));

      // 注册事件监听器
      console.info('[ChatService] 注册事件监听器...');
      
      httpRequest.on('headersReceive', (header) => {
        console.info('[ChatService] ✅ 收到响应头:', JSON.stringify(header));
      });

      // 处理流式响应
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        console.info('[ChatService] 📥 dataReceive 事件触发！');
        try {
          const text = this.arrayBufferToString(data);
          console.info('[ChatService] 数据块长度:', data.byteLength);
          console.info('[ChatService] 数据内容:', text.substring(0, 200));
          
          // 将新数据追加到缓冲区
          buffer += text;
          
          // 按行处理
          const lines = buffer.split('\n');
          // 保留最后一个不完整的行
          buffer = lines.pop() || '';
          
          for (const line of lines) {
            if (line.startsWith('data: ')) {
              const dataStr = line.substring(6).trim();
              if (dataStr === '[DONE]') {
                if (!hasCompleted) {
                  hasCompleted = true;
                  console.info('[ChatService] Stream completed with [DONE]');
                  onComplete();
                }
                return;
              }
              
              if (dataStr) {
                try {
                  const chunk: StreamChunk = JSON.parse(dataStr);
                  console.info('[ChatService] Parsed chunk:', JSON.stringify(chunk));
                  onChunk(chunk);
                } catch (e) {
                  console.error('[ChatService] Parse chunk error:', e, 'Data:', dataStr);
                }
              }
            }
          }
        } catch (e) {
          console.error('[ChatService] DataReceive error:', e);
        }
      });

      httpRequest.on('dataEnd', () => {
        console.info('[ChatService] ✅ dataEnd 事件触发');
        if (!hasCompleted) {
          hasCompleted = true;
          console.info('[ChatService] 调用 onComplete');
          onComplete();
        }
        if (httpRequest) {
          httpRequest.destroy();
          console.info('[ChatService] HTTP 请求已销毁');
        }
      });
      
      httpRequest.on('dataReceiveProgress', (dataProgress: object) => {
        console.info('[ChatService] 📊 dataReceiveProgress:', JSON.stringify(dataProgress));
      });
      
      console.info('[ChatService] 事件监听器注册完成');

      // 发送请求
      console.info('[ChatService] 🚀 发送 HTTP 请求...');
      const requestPromise = httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream'
          },
          extraData: JSON.stringify(requestBody),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: ApiConfig.TIMEOUT.CONNECT,
          readTimeout: ApiConfig.TIMEOUT.READ
        },
        (err, data) => {
          if (err) {
            console.error('[ChatService] ❌ 请求错误');
            console.error('[ChatService] 错误对象:', JSON.stringify(err));
            console.error('[ChatService] 错误码:', err.code);
            console.error('[ChatService] 错误信息:', err.message);
            if (!hasCompleted) {
              hasCompleted = true;
              // 提供更友好的错误信息
              let errorMsg = '网络请求失败';
              if (err.code === 2300003) {
                errorMsg = '无法连接到服务器，请检查：\n1. 后端服务是否启动\n2. 网络配置是否正确\n3. 模拟器使用 10.0.2.2，真机使用电脑IP';
              } else if (err.message) {
                errorMsg = err.message;
              }
              onError(errorMsg);
            }
            if (httpRequest) {
              httpRequest.destroy();
            }
            return;
          }
          
          console.info('[ChatService] ✅ 收到响应，状态码:', data.responseCode);
          
          // 检查响应状态
          if (data && data.responseCode !== 200) {
            console.error('[ChatService] ❌ 响应错误，状态码:', data.responseCode);
            console.error('[ChatService] 响应内容:', data.result);
            if (!hasCompleted) {
              hasCompleted = true;
              onError(`服务器错误: ${data.responseCode}`);
            }
            if (httpRequest) {
              httpRequest.destroy();
            }
            return;
          }
          
          // HarmonyOS 会把所有流式数据缓存在 result 中
          if (data.result && typeof data.result === 'string') {
            console.info('[ChatService] 📦 从 result 中解析数据，长度:', data.result.length);
            
            try {
              // 解析所有数据
              const lines = data.result.split('\n');
              
              for (const line of lines) {
                if (line.startsWith('data: ')) {
                  const dataStr = line.substring(6).trim();
                  
                  if (dataStr === '[DONE]') {
                    console.info('[ChatService] 解析完成 [DONE]');
                    continue;
                  }
                  
                  if (dataStr) {
                    try {
                      const chunk: StreamChunk = JSON.parse(dataStr);
                      console.info('[ChatService] 解析 chunk:', chunk.type);
                      onChunk(chunk);
                    } catch (e) {
                      console.error('[ChatService] 解析 chunk 失败:', e, 'Data:', dataStr);
                    }
                  }
                }
              }
              
              // 所有数据处理完成
              if (!hasCompleted) {
                hasCompleted = true;
                console.info('[ChatService] 所有数据处理完成，调用 onComplete');
                onComplete();
              }
            } catch (e) {
              console.error('[ChatService] 解析 result 失败:', e);
              if (!hasCompleted) {
                hasCompleted = true;
                onError('解析响应数据失败');
              }
            }
            
            if (httpRequest) {
              httpRequest.destroy();
            }
          }
        }
      );
    } catch (error) {
      console.error('[ChatService] ❌ 发送消息异常:', error);
      console.error('[ChatService] 异常详情:', JSON.stringify(error));
      if (!hasCompleted) {
        hasCompleted = true;
        onError('发送消息失败: ' + error);
      }
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
    console.info('=== ChatService.sendMessage 结束 ===');
  }

  private arrayBufferToString(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    let result = '';
    for (let i = 0; i < uint8Array.length; i++) {
      result += String.fromCharCode(uint8Array[i]);
    }
    return result;
  }
}

export default new ChatService();
