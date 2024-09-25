import { CommonConstants } from '../../constants/CommonConstants';
import { Home } from './modules/Home';
import { Statistics } from './modules/Statistics';

@Entry
@Component
struct Index {
  @State current: number = 0;
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Tabs({index: 0}) {

        TabContent() {
          Home()
        }
        .tabBar(this.tabBar(0, '首页', $r('app.media.home')))

        TabContent() {
          Statistics()
        }
        .tabBar(this.tabBar(1, '统计', $r('app.media.chart')))

        TabContent() {
          Home()
        }
        .tabBar(this.tabBar(2, '个人', $r('app.media.moneybag')))

      }
      .barBackgroundColor(CommonConstants.COLOR_SECONDARY)
      .barHeight(50)
      .barPosition(BarPosition.End)
      .onChange((val) => {
        this.current = val;
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .height('100%')
    .width('100%')
  }

  @Builder
  tabBar(index: number, text: string, icon: Resource) {
    Stack() {
      Column()
        .width('100%')
        .height(1)
        .shadow({radius: 1, color: '#3effffff', fill: true})
        .position({top: 0, left: 0})
      Column() {
        Image(icon)
          .width(20)
          .fillColor(this.current === index ? CommonConstants.COLOR_MAIN : '#333')
        Text(text)
          .fontSize(10)
          .margin({top: 2})
          .fontColor(this.current === index ? CommonConstants.COLOR_MAIN : '#333')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      // .shadow({radius: 4, color: '#31000000', fill: true, offsetY: -120})
      .width('100%')
      .height('100%')
    }
  }

}