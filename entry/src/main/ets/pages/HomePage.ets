// 首页 - 选择模式
import { router } from '@kit.ArkUI';
import { CHAT_MODES } from '../constants/Modes';
import { ChatMode, Advisor } from '../models/ChatModels';

@Entry
@Component
struct HomePage {
  @State modes: ChatMode[] = CHAT_MODES;

  build() {
    Column() {
      // 标题区域
      Column() {
        Row() {
          Column() {
            Text('选择你的顾问团')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })

            Text('不同风格，同样帮你解决问题')
              .fontSize(16)
              .fontColor('#B0B0B0')
              .opacity(0.8)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('测试')
            .fontSize(14)
            .height(36)
            .backgroundColor('#ff6b6b')
            .onClick(() => {
              router.pushUrl({ url: 'pages/NetworkTestPage' });
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ top: 60, bottom: 40, left: 20, right: 20 })

      // 模式选择卡片
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.modes, (mode: ChatMode) => {
            this.ModeCard(mode)
          })

          // 功能特性
          this.FeaturesSection()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }

  @Builder
  ModeCard(mode: ChatMode) {
    Column() {
      // 图标和标题
      Row() {
        Text(mode.icon)
          .fontSize(48)
          .margin({ right: 16 })

        Column({ space: 4 }) {
          Text(mode.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(mode.description)
            .fontSize(14)
            .fontColor('#B0B0B0')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ bottom: 16 })

      // 顾问列表
      Column({ space: 8 }) {
        ForEach(mode.advisors, (advisor: Advisor) => {
          Row() {
            Text(advisor.avatar)
              .fontSize(20)
              .margin({ right: 8 })

            Text(advisor.name)
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .width('100%')
        })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .borderWidth({ top: 1 })
      .borderColor('rgba(255,255,255,0.1)')

      // 开始按钮
      Button(mode.id === 'emperor' ? '开始问策' : '开始取经')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(mode.id === 'emperor' ? '#667eea' : '#f5576c')
        .borderRadius(22)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(24)
    .backgroundColor('rgba(255,255,255,0.05)')
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
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
    Column({ space: 16 }) {
      Row({ space: 16 }) {
        this.FeatureCard('🎯', '问题拆解', '多角色帮你分析问题本质')
        this.FeatureCard('💬', '情绪支持', '不只给方案，也给你情绪价值')
      }
      .width('100%')

      Column() {
        this.FeatureCard('✅', '行动清单', '给出可执行的具体建议')
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 40 })
  }

  @Builder
  FeatureCard(icon: string, title: string, desc: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(28)

      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')

      Text(desc)
        .fontSize(12)
        .fontColor('#B0B0B0')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding(20)
    .backgroundColor('rgba(255,255,255,0.05)')
    .borderRadius(16)
  }
}
