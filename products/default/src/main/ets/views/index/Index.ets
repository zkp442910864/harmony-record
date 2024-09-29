import { CommonConstants } from '../../constants/CommonConstants';
import { Home } from './modules/Home';
import { My } from './modules/My';
import { Statistics } from './modules/Statistics';
import { curves, promptAction } from '@kit.ArkUI';
import { getSqlObj } from '../../sql/baseSql';
import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils';

@Entry
@Component
struct Index {
  @State current: number = 0;
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  lastTime: number = 0;

  onBackPress(): boolean | void {
    if (Date.now() - this.lastTime > 2000) {
      this.lastTime = Date.now();
      promptAction.showToast({
        message: '再次返回退出应用',
        duration: 2000,
      })
      return true;
    }
    else {
      return false;
    }
  }

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
          My()
        }
        .tabBar(this.tabBar(2, '个人', $r('app.media.moneybag')))

      }
      // .barBackgroundColor(CommonConstants.COLOR_MAIN)
      .barHeight(50)
      .barPosition(BarPosition.End)
      .onChange((val) => {
        // getSqlObj().test().then(() => {
        //   // getSqlObj().backup();
        //   // getSqlObj().rdbStore.close();
        // })
        this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
          this.current = val;
        })
      })
    }
    .navBarWidth('50%')
    .padding(0)
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
        if (this.current === index) {
          Text(text)
            .fontSize(10)
            .margin({top: 2})
            .fontColor(this.current === index ? CommonConstants.COLOR_MAIN : '#333')
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      // .shadow({radius: 4, color: '#31000000', fill: true, offsetY: -120})
      .width('100%')
      .height('100%')
    }
  }
}
