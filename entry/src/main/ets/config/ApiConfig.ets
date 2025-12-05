// API 配置文件
// 根据不同环境修改这里的配置

interface DevConfig {
  EMULATOR_BASE_URL: string;
  DEVICE_BASE_URL: string;
  PROD_BASE_URL: string;
}

interface TimeoutConfig {
  CONNECT: number;
  READ: number;
}

export class ApiConfig {
  // 开发环境配置
  static readonly DEV_CONFIG: DevConfig = {
    // 模拟器使用 10.0.2.2（模拟器访问宿主机的特殊地址）
    // 如果 10.0.2.2 不通，尝试使用真实 IP: 192.168.148.49
    EMULATOR_BASE_URL: 'http://192.168.148.49:3000',
    
    // 真机调试使用电脑 IP
    DEVICE_BASE_URL: 'http://192.168.148.49:3000',
    
    // 生产环境使用实际服务器地址
    PROD_BASE_URL: 'https://your-server.com'
  };

  // 当前使用的环境
  // 'emulator' | 'device' | 'production'
  static readonly CURRENT_ENV: string = 'emulator';

  // 获取当前 Base URL
  static getBaseUrl(): string {
    switch (ApiConfig.CURRENT_ENV) {
      case 'emulator':
        return ApiConfig.DEV_CONFIG.EMULATOR_BASE_URL;
      case 'device':
        return ApiConfig.DEV_CONFIG.DEVICE_BASE_URL;
      case 'production':
        return ApiConfig.DEV_CONFIG.PROD_BASE_URL;
      default:
        return ApiConfig.DEV_CONFIG.EMULATOR_BASE_URL;
    }
  }

  // 超时配置（毫秒）
  static readonly TIMEOUT: TimeoutConfig = {
    CONNECT: 60000,  // 连接超时
    READ: 60000      // 读取超时
  };
}
