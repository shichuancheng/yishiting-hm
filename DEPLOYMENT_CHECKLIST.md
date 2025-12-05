# 鸿蒙版部署检查清单

## 开发环境配置

### 模拟器开发
- [ ] 后端服务已启动（http://localhost:3000）
- [ ] `ApiConfig.ets` 中 `CURRENT_ENV` 设置为 `'emulator'`
- [ ] 模拟器已启动
- [ ] 运行应用测试功能

### 真机调试
- [ ] 后端服务已启动
- [ ] 查看电脑 IP 地址（例如：192.168.1.100）
- [ ] 修改 `ApiConfig.ets` 中的 `DEVICE_BASE_URL` 为你的 IP
- [ ] `ApiConfig.ets` 中 `CURRENT_ENV` 设置为 `'device'`
- [ ] 手机和电脑连接同一 Wi-Fi
- [ ] 手机通过 USB 连接电脑
- [ ] 手机开启开发者模式和 USB 调试
- [ ] 运行应用测试功能

## 生产环境部署

### 后端部署
- [ ] 后端代码部署到服务器
- [ ] 配置环境变量（API Key 等）
- [ ] 确保服务器开放 HTTP/HTTPS 端口
- [ ] 配置域名和 SSL 证书（推荐）
- [ ] 测试 API 接口可访问

### 应用配置
- [ ] 修改 `ApiConfig.ets` 中的 `PROD_BASE_URL` 为实际服务器地址
- [ ] `ApiConfig.ets` 中 `CURRENT_ENV` 设置为 `'production'`
- [ ] 更新 `AppScope/app.json5` 中的应用信息：
  - [ ] bundleName（包名）
  - [ ] versionCode（版本号）
  - [ ] versionName（版本名称）
  - [ ] icon（应用图标）
  - [ ] label（应用名称）

### 构建和签名
- [ ] 配置签名证书
- [ ] 构建 Release 版本
- [ ] 测试 Release 包功能
- [ ] 检查包大小

### 发布前测试
- [ ] 功能测试
  - [ ] 模式选择正常
  - [ ] 消息发送接收正常
  - [ ] 流式显示正常
  - [ ] 多角色轮流发言正常
  - [ ] 错误处理正常
- [ ] 性能测试
  - [ ] 应用启动速度
  - [ ] 消息加载速度
  - [ ] 内存占用
  - [ ] 网络流量
- [ ] 兼容性测试
  - [ ] 不同设备测试
  - [ ] 不同网络环境测试
  - [ ] 弱网环境测试

### 应用商店发布
- [ ] 准备应用截图（至少 3 张）
- [ ] 准备应用描述
- [ ] 准备隐私政策
- [ ] 提交审核
- [ ] 等待审核通过

## 配置文件快速参考

### ApiConfig.ets 配置

**模拟器开发：**
```typescript
static readonly CURRENT_ENV: string = 'emulator';
```

**真机调试：**
```typescript
static readonly CURRENT_ENV: string = 'device';
// 并修改 DEVICE_BASE_URL 为你的电脑 IP
DEVICE_BASE_URL: 'http://192.168.1.100:3000',
```

**生产环境：**
```typescript
static readonly CURRENT_ENV: string = 'production';
// 并修改 PROD_BASE_URL 为实际服务器地址
PROD_BASE_URL: 'https://api.yourdomain.com'
```

## 常见问题

### Q1: 如何快速切换环境？
A: 只需修改 `ApiConfig.ets` 中的 `CURRENT_ENV` 值即可。

### Q2: 真机调试时无法连接？
A: 检查以下几点：
1. 手机和电脑在同一 Wi-Fi
2. IP 地址配置正确
3. 后端服务正在运行
4. 防火墙没有阻止 3000 端口

### Q3: 如何查看网络请求日志？
A: 在 DevEco Studio 的 Log 窗口，筛选 "ChatService" 标签。

### Q4: 生产环境需要 HTTPS 吗？
A: 强烈推荐使用 HTTPS，可以：
- 保护数据传输安全
- 避免某些网络环境的限制
- 提升用户信任度

## 性能优化建议

- [ ] 启用消息缓存（避免重复请求）
- [ ] 优化列表渲染（使用虚拟滚动）
- [ ] 压缩网络传输数据
- [ ] 添加请求重试机制
- [ ] 实现离线消息队列

## 安全建议

- [ ] 不要在客户端硬编码 API Key
- [ ] 使用 HTTPS 加密传输
- [ ] 实现用户认证机制
- [ ] 添加请求频率限制
- [ ] 敏感信息加密存储

## 监控和维护

- [ ] 配置错误日志收集
- [ ] 监控 API 响应时间
- [ ] 跟踪用户使用数据
- [ ] 定期更新依赖版本
- [ ] 收集用户反馈
