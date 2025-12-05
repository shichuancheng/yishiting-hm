// 主页面 - 带底部 Tab 导航
import { router } from '@kit.ArkUI';
import { CHAT_MODES } from '../constants/Modes';
import { ChatMode, Advisor } from '../models/ChatModels';

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;
  @State modes: ChatMode[] = CHAT_MODES;
  @State chatHistory: ChatHistoryItem[] = []; // 聊天历史

  aboutToAppear() {
    // 加载聊天历史（后续可以从本地存储加载）
    this.loadChatHistory();
  }

  loadChatHistory() {
    // TODO: 从本地存储加载聊天历史
    // 暂时使用示例数据
    this.chatHistory = [];
  }

  build() {
    Column() {
      // 内容区域
      if (this.currentTab === 0) {
        this.MessagesTab()
      } else {
        this.ContactsTab()
      }

      // 底部 Tab 栏
      this.BottomTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED')
  }

  @Builder
  MessagesTab() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('消息')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#EDEDED')
      .border({ width: { bottom: 0.5 }, color: '#D9D9D9' })

      // 聊天历史列表
      if (this.chatHistory.length === 0) {
        // 空状态
        Column() {
          Text('💬')
            .fontSize(64)
            .margin({ bottom: 16 })

          Text('暂无聊天记录')
            .fontSize(16)
            .fontColor('#888888')
            .margin({ bottom: 8 })

          Text('点击下方"通讯录"选择顾问开始聊天')
            .fontSize(14)
            .fontColor('#B2B2B2')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.chatHistory, (item: ChatHistoryItem, index: number) => {
              this.ChatHistoryItem(item, index === this.chatHistory.length - 1)
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ChatHistoryItem(item: ChatHistoryItem, isLast: boolean) {
    Column() {
      Row() {
        // 头像
        Column() {
          Text(item.icon)
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .backgroundColor('#F7F7F7')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)

        // 信息
        Column({ space: 4 }) {
          Row() {
            Text(item.name)
              .fontSize(16)
              .fontColor('#000000')
              .layoutWeight(1)

            Text(item.timeText)
              .fontSize(12)
              .fontColor('#B2B2B2')
          }
          .width('100%')

          Text(item.lastMessage)
            .fontSize(14)
            .fontColor('#888888')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (!isLast) {
        Divider()
          .color('#EBEBEB')
          .margin({ left: 76 })
      }
    }
    .width('100%')
    .onClick(() => {
      interface RouterParams {
        modeId: string;
        modeName: string;
      }

      const params: RouterParams = {
        modeId: item.modeId,
        modeName: item.name
      };

      router.pushUrl({
        url: 'pages/ChatPage',
        params: params
      });
    })
  }

  @Builder
  ContactsTab() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('通讯录')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#EDEDED')
      .border({ width: { bottom: 0.5 }, color: '#D9D9D9' })

      // 模式列表
      Scroll() {
        Column({ space: 0 }) {
          // 顶部说明
          Column() {
            Text('选择适合你的顾问团')
              .fontSize(13)
              .fontColor('#888888')
          }
          .width('100%')
          .padding({ left: 16, top: 16, bottom: 8 })

          // 模式卡片列表
          Column() {
            ForEach(this.modes, (mode: ChatMode, index: number) => {
              this.ModeItem(mode, index === this.modes.length - 1)
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ left: 12, right: 12 })

          // 功能特性
          this.FeaturesSection()
        }
        .width('100%')
        .padding({ bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#EDEDED')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ModeItem(mode: ChatMode, isLast: boolean) {
    Column() {
      Row() {
        // 图标
        Column() {
          Text(mode.icon)
            .fontSize(36)
        }
        .width(56)
        .height(56)
        .backgroundColor('#F7F7F7')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)

        // 信息
        Column({ space: 4 }) {
          Text(mode.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')

          Text(mode.description)
            .fontSize(13)
            .fontColor('#888888')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 顾问头像行
          Row({ space: 4 }) {
            ForEach(mode.advisors.slice(0, 4), (advisor: Advisor) => {
              Text(advisor.avatar)
                .fontSize(14)
            })
            if (mode.advisors.length > 4) {
              Text(`+${mode.advisors.length - 4}`)
                .fontSize(11)
                .fontColor('#888888')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        // 箭头
        Text('›')
          .fontSize(20)
          .fontColor('#C7C7CC')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 分割线
      if (!isLast) {
        Divider()
          .color('#EBEBEB')
          .margin({ left: 84 })
      }
    }
    .width('100%')
    .onClick(() => {
      interface RouterParams {
        modeId: string;
        modeName: string;
      }

      const params: RouterParams = {
        modeId: mode.id,
        modeName: mode.name
      };

      router.pushUrl({
        url: 'pages/ChatPage',
        params: params
      });
    })
  }

  @Builder
  FeaturesSection() {
    Column({ space: 0 }) {
      // 标题
      Column() {
        Text('功能特点')
          .fontSize(13)
          .fontColor('#888888')
      }
      .width('100%')
      .padding({ left: 16, top: 24, bottom: 8 })

      // 特性列表
      Column() {
        this.FeatureItem('🎯', '问题拆解', '多角色帮你分析问题本质', false)
        this.FeatureItem('💬', '情绪支持', '不只给方案，也给你情绪价值', false)
        this.FeatureItem('✅', '行动清单', '给出可执行的具体建议', true)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .margin({ left: 12, right: 12 })
    }
    .width('100%')
  }

  @Builder
  FeatureItem(icon: string, title: string, desc: string, isLast: boolean) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(24)
          .margin({ right: 12 })

        Column({ space: 2 }) {
          Text(title)
            .fontSize(15)
            .fontColor('#000000')

          Text(desc)
            .fontSize(13)
            .fontColor('#888888')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (!isLast) {
        Divider()
          .color('#EBEBEB')
          .margin({ left: 52 })
      }
    }
    .width('100%')
  }

  @Builder
  BottomTabBar() {
    Row() {
      // 消息 Tab
      Column({ space: 4 }) {
        Text(this.currentTab === 0 ? '💬' : '💬')
          .fontSize(24)
          .fontColor(this.currentTab === 0 ? '#07C160' : '#888888')

        Text('消息')
          .fontSize(10)
          .fontColor(this.currentTab === 0 ? '#07C160' : '#888888')
      }
      .layoutWeight(1)
      .padding({ top: 6, bottom: 6 })
      .onClick(() => {
        this.currentTab = 0;
      })

      // 通讯录 Tab
      Column({ space: 4 }) {
        Text(this.currentTab === 1 ? '📖' : '📖')
          .fontSize(24)
          .fontColor(this.currentTab === 1 ? '#07C160' : '#888888')

        Text('通讯录')
          .fontSize(10)
          .fontColor(this.currentTab === 1 ? '#07C160' : '#888888')
      }
      .layoutWeight(1)
      .padding({ top: 6, bottom: 6 })
      .onClick(() => {
        this.currentTab = 1;
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#F7F7F7')
    .border({ width: { top: 0.5 }, color: '#D9D9D9' })
  }
}

// 聊天历史项数据模型
interface ChatHistoryItem {
  modeId: string;
  name: string;
  icon: string;
  lastMessage: string;
  timeText: string;
  timestamp: number;
}
