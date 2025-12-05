// API 配置文件
// 环境配置管理

interface DevConfig {
  EMULATOR_BASE_URL: string;
  DEVICE_BASE_URL: string;
  PROD_BASE_URL: string;
}

interface TimeoutConfig {
  CONNECT: number;
  READ: number;
}

type Environment = 'emulator' | 'device' | 'production';

export class ApiConfig {
  // ==================== 环境配置 ====================
  // 修改这里切换环境：'emulator' | 'device' | 'production'
  private static readonly CURRENT_ENV: Environment = 'emulator';
  
  // 开发环境配置
  private static readonly DEV_CONFIG: DevConfig = {
    // 模拟器使用 10.0.2.2（模拟器访问宿主机的特殊地址）
    EMULATOR_BASE_URL: 'http://10.0.2.2:3000',
    
    // 真机调试使用电脑 IP（需要根据实际 IP 修改）
    DEVICE_BASE_URL: 'http://192.168.148.49:3000',
    
    // 生产环境使用实际服务器地址
    PROD_BASE_URL: 'https://your-server.com'
  };

  // ==================== 公共方法 ====================
  
  /**
   * 获取当前环境的 Base URL
   */
  static getBaseUrl(): string {
    switch (ApiConfig.CURRENT_ENV) {
      case 'emulator':
        console.info('[ApiConfig] 使用模拟器环境:', ApiConfig.DEV_CONFIG.EMULATOR_BASE_URL);
        return ApiConfig.DEV_CONFIG.EMULATOR_BASE_URL;
      case 'device':
        console.info('[ApiConfig] 使用真机环境:', ApiConfig.DEV_CONFIG.DEVICE_BASE_URL);
        return ApiConfig.DEV_CONFIG.DEVICE_BASE_URL;
      case 'production':
        console.info('[ApiConfig] 使用生产环境:', ApiConfig.DEV_CONFIG.PROD_BASE_URL);
        return ApiConfig.DEV_CONFIG.PROD_BASE_URL;
      default:
        return ApiConfig.DEV_CONFIG.EMULATOR_BASE_URL;
    }
  }

  /**
   * 判断是否为开发环境
   */
  static isDevelopment(): boolean {
    return ApiConfig.CURRENT_ENV === 'emulator' || ApiConfig.CURRENT_ENV === 'device';
  }

  /**
   * 判断是否为生产环境
   */
  static isProduction(): boolean {
    return ApiConfig.CURRENT_ENV === 'production';
  }

  /**
   * 获取当前环境名称
   */
  static getEnvironment(): string {
    return ApiConfig.CURRENT_ENV;
  }

  // 超时配置（毫秒）
  static readonly TIMEOUT: TimeoutConfig = {
    CONNECT: 60000,  // 连接超时
    READ: 60000      // 读取超时
  };
}
