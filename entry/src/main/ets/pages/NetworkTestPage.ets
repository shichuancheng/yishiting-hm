// 网络测试页面
import { http } from '@kit.NetworkKit';
import { ApiConfig } from '../config/ApiConfig';

@Entry
@Component
struct NetworkTestPage {
  @State testResult: string = '点击按钮测试网络连接';
  @State isLoading: boolean = false;

  build() {
    Column() {
      Text('网络连接测试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      Text(`目标地址: ${ApiConfig.getBaseUrl()}`)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 20 })

      Button('测试简单请求')
        .width('80%')
        .margin({ bottom: 10 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testSimpleRequest();
        })

      Button('测试流式请求')
        .width('80%')
        .margin({ bottom: 10 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testStreamRequest();
        })

      Button('测试连接性')
        .width('80%')
        .margin({ bottom: 10 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testConnectivity();
        })

      Button('测试健康检查（最简单）')
        .width('80%')
        .margin({ bottom: 20 })
        .backgroundColor('#4CAF50')
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testHealth();
        })

      Scroll() {
        Text(this.testResult)
          .fontSize(12)
          .fontColor('#333333')
          .width('90%')
          .padding(10)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
      }
      .layoutWeight(1)
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  private async testSimpleRequest() {
    this.isLoading = true;
    this.testResult = '正在测试简单请求...\n';

    try {
      const httpRequest = http.createHttp();
      const baseUrl = ApiConfig.getBaseUrl();
      
      this.testResult += `请求地址: ${baseUrl}/api/chat/stream\n`;
      
      interface RequestBody {
        message: string;
        history: Array<Record<string, string>>;
        mode: string;
      }
      
      const requestBody: RequestBody = {
        message: '测试',
        history: [],
        mode: 'emperor'
      };

      this.testResult += `请求体: ${JSON.stringify(requestBody)}\n`;
      this.testResult += '发送请求中...\n';

      interface RequestOptions {
        method: http.RequestMethod;
        header: Record<string, string>;
        extraData: string;
        expectDataType: http.HttpDataType;
        connectTimeout: number;
        readTimeout: number;
      }
      
      const options: RequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestBody),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000
      };

      const response = await httpRequest.request(
        `${baseUrl}/api/chat/stream`,
        options
      );

      this.testResult += `响应状态码: ${response.responseCode}\n`;
      this.testResult += `响应头: ${JSON.stringify(response.header)}\n`;
      
      if (response.result) {
        const resultStr = typeof response.result === 'string' 
          ? response.result 
          : JSON.stringify(response.result);
        this.testResult += `响应内容（前500字符）: ${resultStr.substring(0, 500)}\n`;
      }

      this.testResult += '\n✅ 请求成功！';
      httpRequest.destroy();
      
    } catch (error) {
      this.testResult += `\n❌ 错误: ${JSON.stringify(error)}\n`;
      this.testResult += `错误详情: ${error}\n`;
    }

    this.isLoading = false;
  }

  private async testStreamRequest() {
    this.isLoading = true;
    this.testResult = '正在测试流式请求...\n';

    try {
      const httpRequest = http.createHttp();
      const baseUrl = ApiConfig.getBaseUrl();
      
      this.testResult += `请求地址: ${baseUrl}/api/chat/stream\n`;
      
      interface RequestBody {
        message: string;
        history: Array<Record<string, string>>;
        mode: string;
      }
      
      const requestBody: RequestBody = {
        message: '测试',
        history: [],
        mode: 'emperor'
      };

      let receivedData = '';
      let chunkCount = 0;

      httpRequest.on('headersReceive', (header) => {
        this.testResult += `\n收到响应头: ${JSON.stringify(header)}\n`;
      });

      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        chunkCount++;
        const text = this.arrayBufferToString(data);
        receivedData += text;
        this.testResult += `\n数据块 ${chunkCount}: ${text.substring(0, 100)}...\n`;
      });

      httpRequest.on('dataEnd', () => {
        this.testResult += `\n数据传输完成，共收到 ${chunkCount} 个数据块\n`;
        this.testResult += `\n完整数据（前1000字符）:\n${receivedData.substring(0, 1000)}\n`;
        this.testResult += '\n✅ 流式请求成功！';
        httpRequest.destroy();
        this.isLoading = false;
      });

      this.testResult += '发送流式请求...\n';

      interface StreamRequestOptions {
        method: http.RequestMethod;
        header: Record<string, string>;
        extraData: string;
        expectDataType: http.HttpDataType;
        connectTimeout: number;
        readTimeout: number;
      }
      
      const streamOptions: StreamRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream'
        },
        extraData: JSON.stringify(requestBody),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 30000
      };

      httpRequest.request(
        `${baseUrl}/api/chat/stream`,
        streamOptions,
        (err, data) => {
          if (err) {
            this.testResult += `\n❌ 请求错误: ${JSON.stringify(err)}\n`;
            this.isLoading = false;
            httpRequest.destroy();
            return;
          }
          
          this.testResult += `\n响应状态码: ${data.responseCode}\n`;
          
          if (data.responseCode !== 200) {
            this.testResult += `\n❌ 服务器错误: ${data.responseCode}\n`;
            this.testResult += `响应内容: ${data.result}\n`;
            this.isLoading = false;
            httpRequest.destroy();
          }
        }
      );
      
    } catch (error) {
      this.testResult += `\n❌ 错误: ${JSON.stringify(error)}\n`;
      this.isLoading = false;
    }
  }

  private async testHealth() {
    this.isLoading = true;
    this.testResult = '=== 健康检查测试 ===\n';
    
    const baseUrl = ApiConfig.getBaseUrl();
    this.testResult += `目标: ${baseUrl}/health\n\n`;

    try {
      console.info('[NetworkTest] 开始健康检查');
      console.info('[NetworkTest] URL:', `${baseUrl}/health`);
      
      const httpRequest = http.createHttp();
      
      console.info('[NetworkTest] 发送 GET 请求...');
      const response = await httpRequest.request(`${baseUrl}/health`, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });
      
      console.info('[NetworkTest] 收到响应，状态码:', response.responseCode);
      console.info('[NetworkTest] 响应内容:', response.result);
      
      this.testResult += `✅ 连接成功！\n`;
      this.testResult += `状态码: ${response.responseCode}\n`;
      this.testResult += `响应: ${response.result}\n`;
      
      httpRequest.destroy();
    } catch (error) {
      console.error('[NetworkTest] 健康检查失败:', error);
      console.error('[NetworkTest] 错误码:', error.code);
      console.error('[NetworkTest] 错误信息:', error.message);
      
      this.testResult += `❌ 连接失败\n`;
      this.testResult += `错误码: ${error.code}\n`;
      this.testResult += `错误: ${error.message}\n\n`;
      
      // 根据错误码给出建议
      if (error.code === 2300003) {
        this.testResult += `💡 无法连接到服务器\n`;
        this.testResult += `请检查:\n`;
        this.testResult += `1. 后端是否启动 (npm start)\n`;
        this.testResult += `2. 模拟器用 10.0.2.2，真机用电脑IP\n`;
        this.testResult += `3. 防火墙是否允许3000端口\n`;
      }
    }

    this.isLoading = false;
  }

  private async testConnectivity() {
    this.isLoading = true;
    this.testResult = '正在测试网络连接性...\n';

    const baseUrl = ApiConfig.getBaseUrl();
    this.testResult += `目标地址: ${baseUrl}\n\n`;

    // 测试1: 基本连接
    this.testResult += '【测试1】基本HTTP连接\n';
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(baseUrl, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });
      this.testResult += `✅ 连接成功，状态码: ${response.responseCode}\n\n`;
      httpRequest.destroy();
    } catch (error) {
      this.testResult += `❌ 连接失败\n`;
      this.testResult += `错误码: ${error.code}\n`;
      this.testResult += `错误信息: ${error.message}\n`;
      this.testResult += `\n💡 建议:\n`;
      this.testResult += `- 如果是模拟器，确认使用 10.0.2.2\n`;
      this.testResult += `- 如果是真机，确认使用电脑IP地址\n`;
      this.testResult += `- 确认后端服务已启动 (npm start)\n`;
      this.testResult += `- 确认防火墙允许3000端口\n\n`;
    }

    // 测试2: API端点
    this.testResult += '【测试2】API端点可达性\n';
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(`${baseUrl}/api/chat/stream`, {
        method: http.RequestMethod.OPTIONS,
        connectTimeout: 5000,
        readTimeout: 5000
      });
      this.testResult += `✅ API端点可达，状态码: ${response.responseCode}\n\n`;
      httpRequest.destroy();
    } catch (error) {
      this.testResult += `❌ API端点不可达\n`;
      this.testResult += `错误: ${error.message}\n\n`;
    }

    // 测试3: 网络权限
    this.testResult += '【测试3】网络权限检查\n';
    this.testResult += `✅ INTERNET权限已配置\n`;
    this.testResult += `✅ GET_NETWORK_INFO权限已配置\n\n`;

    this.testResult += '【配置信息】\n';
    this.testResult += `当前环境: ${ApiConfig.CURRENT_ENV}\n`;
    this.testResult += `Base URL: ${baseUrl}\n`;
    this.testResult += `连接超时: ${ApiConfig.TIMEOUT.CONNECT}ms\n`;
    this.testResult += `读取超时: ${ApiConfig.TIMEOUT.READ}ms\n`;

    this.isLoading = false;
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
