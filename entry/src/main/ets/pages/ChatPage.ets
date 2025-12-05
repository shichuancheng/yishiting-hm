// 聊天页面 - 微信风格
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
    const params = router.getParams() as Record<string, string>;
    this.modeId = params['modeId'] || 'emperor';
    this.modeName = params['modeName'] || '三国谋士团';

    const mode = CHAT_MODES.find(m => m.id === this.modeId);
    if (mode) {
      this.welcomeTitle = mode.welcomeTitle;
      this.welcomeDesc = mode.welcomeDesc;
      this.inputPlaceholder = mode.inputPlaceholder;
      this.modeIcon = mode.icon;
      this.examples = mode.examples;
      this.advisorNames = mode.advisors.map(a => `${a.avatar} ${a.name}`);
    }

    this.isLoading = false;
    this.inputText = '';
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';
  }

  onPageShow() {
    console.info('[ChatPage] Page shown');
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

          if (this.isLoading && this.currentRole) {
            ListItem() {
              this.StreamingMessage()
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#EDEDED')
      }

      // 输入框
      this.InputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED')
  }

  @Builder
  TopBar() {
    Row() {
      Text('←')
        .fontSize(22)
        .fontColor('#000000')
        .onClick(() => {
          router.back();
        })

      Blank()

      Text(this.modeName)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')

      Blank()

      // 占位，保持标题居中
      Row().width(24).height(24)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#EDEDED')
    .border({ width: { bottom: 0.5 }, color: '#D9D9D9' })
  }

  @Builder
  WelcomePanel() {
    Scroll() {
      Column({ space: 16 }) {
        // 头像区域
        Column() {
          Text(this.modeIcon)
            .fontSize(56)
        }
        .width(80)
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 40 })

        Text(this.welcomeTitle)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ top: 8 })

        Text(this.welcomeDesc)
          .fontSize(14)
          .fontColor('#888888')
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 })

        // 角色标签
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.advisorNames, (name: string) => {
            Text(name)
              .fontSize(12)
              .fontColor('#576B95')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .margin(4)
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ top: 8 })

        // 示例问题
        Column({ space: 10 }) {
          Text('你可以这样问：')
            .fontSize(13)
            .fontColor('#888888')
            .margin({ bottom: 4 })

          ForEach(this.examples, (example: ExampleQuestion) => {
            Row() {
              Text(example.text)
                .fontSize(14)
                .fontColor('#576B95')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              this.sendMessageWithText(example.question);
            })
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ top: 24 })
      }
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  MessageItem(msg: Message) {
    Column() {
      if (msg.role === 'user') {
        // 用户消息 - 右侧绿色气泡
        Row() {
          Blank()
          Text(msg.content)
            .fontSize(16)
            .fontColor('#000000')
            .padding(12)
            .backgroundColor('#95EC69')
            .borderRadius(4)
            .constraintSize({ maxWidth: '70%' })

          // 用户头像
          Column() {
            Text('👤')
              .fontSize(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
          .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ top: 12, bottom: 12 })
      } else {
        // AI 消息 - 左侧白色气泡
        Row() {
          // AI头像
          Column() {
            Text(msg.avatar || '🤖')
              .fontSize(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
          .margin({ right: 8 })

          Column({ space: 4 }) {
            Text(msg.name || 'AI')
              .fontSize(12)
              .fontColor('#576B95')

            Text(msg.content)
              .fontSize(16)
              .fontColor('#000000')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .constraintSize({ maxWidth: '70%' })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ top: 12, bottom: 12 })
      }
    }
    .width('100%')
  }

  @Builder
  StreamingMessage() {
    Row() {
      Column() {
        Text(this.currentAvatar)
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor('#FFFFFF')
      .borderRadius(4)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 8 })

      Column({ space: 4 }) {
        Text(this.currentRole)
          .fontSize(12)
          .fontColor('#576B95')

        Text(this.currentContent || '正在输入...')
          .fontSize(16)
          .fontColor('#000000')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .constraintSize({ maxWidth: '70%' })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: 12, bottom: 12 })
  }

  @Builder
  InputBar() {
    Row() {
      // 语音按钮（装饰）
      Text('🎤')
        .fontSize(24)

      TextInput({
        placeholder: this.inputPlaceholder,
        text: this.inputText,
        controller: this.inputController
      })
        .layoutWeight(1)
        .height(36)
        .backgroundColor('#FFFFFF')
        .placeholderColor('#B2B2B2')
        .fontColor('#000000')
        .borderRadius(4)
        .padding({ left: 12, right: 12 })
        .margin({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.inputText = value;
        })
        .enabled(!this.isLoading)

      if (this.inputText.trim().length > 0 || this.isLoading) {
        // 发送/停止按钮
        Button(this.isLoading ? '停止' : '发送')
          .height(36)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isLoading ? '#FA5151' : '#07C160')
          .borderRadius(4)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            if (this.isLoading) {
              this.isLoading = false;
              this.currentRole = '';
              this.currentAvatar = '';
              this.currentContent = '';
            } else {
              this.sendMessage();
            }
          })
      } else {
        // 表情按钮（装饰）
        Text('😊')
          .fontSize(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F7F7F7')
    .border({ width: { top: 0.5 }, color: '#D9D9D9' })
  }

  private sendMessageWithText(text: string) {
    if (this.isLoading) return;
    this.inputText = text;
    this.sendMessage();
  }

  private sendMessage() {
    if (this.inputText.trim().length === 0 || this.isLoading) return;

    const userMessage: Message = {
      id: DateUtils.generateId(),
      role: 'user',
      content: this.inputText.trim(),
      timestamp: Date.now()
    };

    const messageToSend = this.inputText.trim();
    this.isLoading = true;
    this.inputText = '';
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';

    const historyToSend = [...this.messages];
    this.messages.push(userMessage);

    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    const timeoutId = setTimeout(() => {
      if (this.isLoading) {
        this.handleStreamError('请求超时，请重试');
      }
    }, 60000);

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
      if (this.currentRole && this.currentContent) {
        this.saveCurrentMessage();
      }
      this.currentRole = chunk.role || '';
      this.currentAvatar = chunk.avatar || '🤖';
      this.currentContent = '';
    } else if (chunk.type === 'content') {
      this.currentContent += chunk.content || '';
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 50);
    } else if (chunk.type === 'role_end') {
      this.saveCurrentMessage();
      this.currentRole = '';
      this.currentAvatar = '';
      this.currentContent = '';
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
    this.isLoading = false;
    this.currentRole = '';
    this.currentAvatar = '';
    this.currentContent = '';

    const errorMessage: Message = {
      id: DateUtils.generateId(),
      role: 'assistant',
      content: `出现了错误：${error}`,
      name: '系统提示',
      avatar: '⚠️',
      timestamp: Date.now()
    };
    this.messages.push(errorMessage);
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
