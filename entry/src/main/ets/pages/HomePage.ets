// 首页 - 微信风格
import { router } from '@kit.ArkUI';
import { CHAT_MODES } from '../constants/Modes';
import { ChatMode, Advisor } from '../models/ChatModels';

@Entry
@Component
struct HomePage {
  @State modes: ChatMode[] = CHAT_MODES;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('选择顾问')
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
    .backgroundColor('#EDEDED')
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
}
