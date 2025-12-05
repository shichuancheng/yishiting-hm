# 智囊团 - 鸿蒙版本

这是智囊团 AI 决策顾问的鸿蒙原生应用版本，功能与 Web 版完全一致。

## 功能特性

- ✅ **皇帝模式**：诸葛亮、孙武、管仲、总管阿宁等谋士团队
- ✅ **西游模式**：唐僧师徒四人（唐三藏、孙悟空、猪八戒、沙僧）
- ✅ **流式对话**：实时显示 AI 回复，多角色轮流发言
- ✅ **智能调度**：导演 AI 自动决定角色出场顺序
- ✅ **原生体验**：完全使用 ArkTS 开发，流畅的鸿蒙原生体验

## 项目结构

```
entry/src/main/ets/
├── constants/          # 常量配置
│   └── Modes.ets      # 模式和角色配置
├── models/            # 数据模型
│   └── ChatModels.ets # 聊天相关类型定义
├── services/          # 服务层
│   └── ChatService.ets # API 请求服务
├── utils/             # 工具函数
│   └── DateUtils.ets  # 日期工具
└── pages/             # 页面组件
    ├── Index.ets      # 入口页面
    ├── HomePage.ets   # 首页（模式选择）
    └── ChatPage.ets   # 聊天页面
```

## 开发环境要求

- DevEco Studio 5.0.0 或更高版本
- HarmonyOS SDK API 12 (6.0.1) 或更高版本
- Node.js 环境（用于运行后端服务）

## 快速开始

### 1. 启动后端服务

鸿蒙应用需要连接到后端 API 服务：

```bash
# 进入后端目录
cd /Users/csc/Desktop/ht/study/yishiting/backend

# 确保已配置 .env 文件
# 启动服务
npm run dev
```

后端服务将运行在 `http://localhost:3000`

### 2. 配置网络访问

**开发环境（模拟器/真机调试）：**

如果使用真机调试，需要修改 `entry/src/main/ets/services/ChatService.ets` 中的 `baseUrl`：

```typescript
// 将 localhost 改为你的电脑 IP 地址
private baseUrl: string = 'http://192.168.x.x:3000';
```

**生产环境：**

部署时需要将后端服务部署到公网服务器，并修改 `baseUrl` 为实际的服务器地址。

### 3. 运行应用

1. 使用 DevEco Studio 打开项目
2. 连接鸿蒙设备或启动模拟器
3. 点击运行按钮

## 核心功能说明

### 模式选择（HomePage）

- 显示两种模式：皇帝模式和西游模式
- 展示每个模式的顾问团队
- 点击卡片进入对应的聊天页面

### 聊天对话（ChatPage）

- 支持文本输入
- 流式显示 AI 回复
- 多角色轮流发言
- 自动滚动到最新消息
- 显示角色头像和名称

### API 服务（ChatService）

- 使用 HarmonyOS 的 `@kit.NetworkKit` 进行网络请求
- 支持 SSE（Server-Sent Events）流式响应
- 处理多种消息类型：role_start、content、role_end、error

## 技术栈

- **开发语言**：ArkTS（TypeScript 超集）
- **UI 框架**：ArkUI（声明式 UI）
- **网络请求**：@kit.NetworkKit
- **路由导航**：@kit.ArkUI (router)
- **后端 API**：Node.js + Express + OpenAI SDK

## 与 Web 版的差异

1. **网络请求**：使用鸿蒙原生的 HTTP 模块替代 axios
2. **UI 组件**：使用 ArkUI 组件替代 Vue 组件
3. **状态管理**：使用 @State 装饰器替代 Vue 的响应式系统
4. **路由**：使用鸿蒙 router 替代 vue-router

## 注意事项

1. **网络权限**：已在 `module.json5` 中配置 `ohos.permission.INTERNET` 权限
2. **跨域问题**：开发时确保后端 CORS 配置正确
3. **流式响应**：处理 SSE 流式数据时需要正确解析 `data:` 前缀
4. **真机调试**：使用真机时需要确保手机和电脑在同一局域网

## 后续优化建议

1. **离线缓存**：使用 Preferences 存储聊天历史
2. **主题切换**：支持深色/浅色主题
3. **语音输入**：集成语音识别功能
4. **消息复制**：长按消息支持复制
5. **分享功能**：支持分享对话内容
6. **推送通知**：后台消息提醒

## 常见问题

**Q: 无法连接到后端服务？**
A: 检查后端是否正常运行，真机调试时确保使用正确的 IP 地址。

**Q: 消息显示不完整？**
A: 检查网络连接，确保流式响应正常接收。

**Q: 如何添加新的模式？**
A: 在 `constants/Modes.ets` 中添加新的模式配置，后端也需要相应配置。

## 开发者

基于 Web 版本移植到鸿蒙平台，保持功能完全一致。
