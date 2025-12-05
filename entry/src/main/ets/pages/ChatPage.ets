// 聊天页面
import { router } from '@kit.ArkUI';
import { Message, StreamChunk, ExampleQuestion } from '../models/ChatModels';
import ChatService from '../services/ChatService';
import { DateUtils } from '../utils/DateUtils';
import { CHAT_MODES } from '../constants/Modes';

@Entry
@Component
struct ChatPage {
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State currentRole: string = '';
  @State currentAvatar: string = '';
  @State currentContent: string = '';

  private modeId: string = '';
  private modeName: string = '';
  private welcomeTitle: string = '';
  private welcomeDesc: string = '';
  private inputPlaceholder: string = '';
  private modeIcon: string = '';
  private examples: ExampleQuestion[] = [];
  private advisorNames: string[] = [];
  private scroller: Scroller = new Scroller();
  private inputController: TextInputController = new TextInputController();

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    this.modeId = params['modeId'] || 'emperor';
    this.modeName = params['modeName'] || '三国谋士团';

    // 获取模式配置
    const mode = CHAT_MODES.find(m => m.id === this.modeId);
    if (mode) {
      this.welcomeTitle = mode.welcomeTitle;
      this.welcomeDesc = mode.welcomeDesc;
      this.inputPlaceholder = mode.inputPlaceholder;
      this.modeIcon = mode.icon;
      this.examples = mode.examples;
      this.advisorNames = mode.advisors.map(a => `${a.avatar} ${a.name}`);
    }

    // 确保初始状态正确
    this.isLoading = false;
    this.inputText = '';
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';
    
    console.info('[ChatPage] Page initialized, isLoading:', this.isLoading);
  }

  onPageShow() {
    // 页面显示时，确保输入框可用
    console.info('[ChatPage] Page shown, current isLoading:', this.isLoading);
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()

      // 消息列表或欢迎页
      if (this.messages.length === 0) {
        this.WelcomePanel()
      } else {
        List({ scroller: this.scroller }) {
          ForEach(this.messages, (msg: Message) => {
            ListItem() {
              this.MessageItem(msg)
            }
          })

          // 正在输入的消息
          if (this.isLoading && this.currentRole) {
            ListItem() {
              this.StreamingMessage()
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#1a1a2e')
      }

      // 输入框
      this.InputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('sys.symbol.chevron_left'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
        .onClick(() => {
          router.back();
        })

      Text(this.modeName)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .margin({ left: 12 })

      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#16213e')
  }

  @Builder
  WelcomePanel() {
    Scroll() {
      Column({ space: 16 }) {
        Text(this.modeIcon)
          .fontSize(64)
          .margin({ top: 40 })

        Text(this.welcomeTitle)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(this.welcomeDesc)
          .fontSize(14)
          .fontColor('#B0B0B0')
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20 })

        // 角色列表
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.advisorNames, (name: string) => {
            Text(name)
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.8)')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,255,255,0.08)')
              .borderRadius(16)
              .margin(4)
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 示例问题
        Column({ space: 12 }) {
          Text('试试问：')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.5)')

          ForEach(this.examples, (example: ExampleQuestion) => {
            Button(example.text)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                this.sendMessageWithText(example.question);
              })
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 24 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  MessageItem(msg: Message) {
    Column() {
      if (msg.role === 'user') {
        // 用户消息
        Row() {
          Blank()
          Column() {
            Text(msg.content)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .padding(12)
              .backgroundColor('#667eea')
              .borderRadius(18)
          }
          .width('75%')
        }
        .width('100%')
        .margin({ top: 8, bottom: 8 })
      } else {
        // AI 消息
        Row() {
          Text(msg.avatar || '🤖')
            .fontSize(32)
            .margin({ right: 8 })

          Column({ space: 4 }) {
            Text(msg.name || 'AI')
              .fontSize(13)
              .fontColor('#ffd700')
              .fontWeight(FontWeight.Medium)

            Text(msg.content)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .padding(12)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(12)
          }
          .alignItems(HorizontalAlign.Start)
          .width('75%')

          Blank()
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ top: 8, bottom: 8 })
      }
    }
    .width('100%')
  }

  @Builder
  StreamingMessage() {
    Row() {
      Text(this.currentAvatar)
        .fontSize(32)
        .margin({ right: 8 })

      Column({ space: 4 }) {
        Text(this.currentRole)
          .fontSize(13)
          .fontColor('#ffd700')
          .fontWeight(FontWeight.Medium)

        Text(this.currentContent || '正在思考...')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(12)
      }
      .alignItems(HorizontalAlign.Start)
      .width('75%')

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  InputBar() {
    Row() {
      TextInput({ 
        placeholder: this.inputPlaceholder, 
        text: this.inputText,
        controller: this.inputController 
      })
        .layoutWeight(1)
        .height(44)
        .backgroundColor('rgba(255,255,255,0.05)')
        .placeholderColor('#666666')
        .fontColor('#FFFFFF')
        .borderRadius(22)
        .padding({ left: 16, right: 16 })
        .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
        .onChange((value: string) => {
          this.inputText = value;
        })
        .enabled(!this.isLoading)

      Button(this.isLoading ? '停止' : '发送')
        .width(70)
        .height(44)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isLoading ? '#ff6b6b' : (this.modeId === 'emperor' ? '#667eea' : '#f5576c'))
        .borderRadius(22)
        .margin({ left: 12 })
        .enabled(this.isLoading || this.inputText.trim().length > 0)
        .onClick(() => {
          if (this.isLoading) {
            // 停止加载，重置状态
            this.isLoading = false;
            this.currentRole = '';
            this.currentAvatar = '';
            this.currentContent = '';
          } else {
            this.sendMessage();
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.05)')
    .border({ width: { top: 1 }, color: 'rgba(255,255,255,0.1)' })
  }

  private sendMessageWithText(text: string) {
    if (this.isLoading) {
      console.info('[ChatPage] Cannot send example: already loading');
      return;
    }
    this.inputText = text;
    this.sendMessage();
  }

  private sendMessage() {
    if (this.inputText.trim().length === 0 || this.isLoading) {
      console.info('[ChatPage] Cannot send: inputText empty or already loading');
      return;
    }

    const userMessage: Message = {
      id: DateUtils.generateId(),
      role: 'user',
      content: this.inputText.trim(),
      timestamp: Date.now()
    };

    const messageToSend = this.inputText.trim();
    
    // 先设置 loading 状态，再清空输入
    this.isLoading = true;
    this.inputText = '';
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';
    
    console.info('[ChatPage] Sending message, isLoading set to:', this.isLoading);
    
    // 保存历史记录（不包含当前消息）
    const historyToSend = [...this.messages];
    
    // 添加用户消息到显示列表
    this.messages.push(userMessage);

    // 滚动到底部
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    // 设置超时保护，防止 isLoading 一直为 true
    const timeoutId = setTimeout(() => {
      if (this.isLoading) {
        console.warn('Request timeout, resetting loading state');
        this.handleStreamError('请求超时，请重试');
      }
    }, 60000); // 60秒超时

    // 调用 API（发送历史记录，不包含当前消息）
    ChatService.sendMessage(
      messageToSend,
      historyToSend,
      this.modeId,
      (chunk: StreamChunk) => {
        this.handleStreamChunk(chunk);
      },
      () => {
        clearTimeout(timeoutId);
        this.handleStreamComplete();
      },
      (error: string) => {
        clearTimeout(timeoutId);
        this.handleStreamError(error);
      }
    );
  }

  private handleStreamChunk(chunk: StreamChunk) {
    if (chunk.type === 'role_start') {
      // 新角色开始发言
      if (this.currentRole && this.currentContent) {
        // 保存上一个角色的消息
        this.saveCurrentMessage();
      }
      this.currentRole = chunk.role || '';
      this.currentAvatar = chunk.avatar || '🤖';
      this.currentContent = '';
    } else if (chunk.type === 'content') {
      // 追加内容
      this.currentContent += chunk.content || '';
      // 滚动到底部
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 50);
    } else if (chunk.type === 'role_end') {
      // 角色发言结束
      this.saveCurrentMessage();
      this.currentRole = '';
      this.currentAvatar = '';
      this.currentContent = '';
    } else if (chunk.type === 'error') {
      console.error('Stream error:', chunk.error);
    }
  }

  private handleStreamComplete() {
    this.isLoading = false;
    if (this.currentRole && this.currentContent) {
      this.saveCurrentMessage();
    }
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';
  }

  private handleStreamError(error: string) {
    console.error('[ChatPage] Stream error:', error);
    this.isLoading = false;
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';

    // 显示错误消息
    const errorMessage: Message = {
      id: DateUtils.generateId(),
      role: 'assistant',
      content: `抱歉，出现了错误：${error}`,
      name: '系统',
      avatar: '⚠️',
      timestamp: Date.now()
    };
    this.messages.push(errorMessage);
    
    // 强制刷新UI
    console.info('[ChatPage] Error handled, isLoading reset to:', this.isLoading);
  }

  private saveCurrentMessage() {
    if (this.currentContent.trim().length > 0) {
      const message: Message = {
        id: DateUtils.generateId(),
        role: 'assistant',
        content: this.currentContent.trim(),
        name: this.currentRole,
        avatar: this.currentAvatar,
        timestamp: Date.now()
      };
      this.messages.push(message);
    }
  }
}
