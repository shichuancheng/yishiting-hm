// 入口页面 - 重定向到首页
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  aboutToAppear() {
    // 自动跳转到首页
    router.replaceUrl({
      url: 'pages/HomePage'
    });
  }

  build() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
    .justifyContent(FlexAlign.Center)
  }
}