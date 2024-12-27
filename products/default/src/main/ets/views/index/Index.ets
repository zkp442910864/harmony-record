import { CommonConstants } from '../../constants/CommonConstants';
import { Home } from './childrenPages/Home';
import { My } from './childrenPages/My';
import { Statistics } from './childrenPages/Statistics';
import { curves, promptAction } from '@kit.ArkUI';
import { getSqlObj } from '../../sql/baseSql';
import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils';
import { AnimateCallback, CustomTransition } from '../../customTransition';
import { MyNavPathStack } from '../../routerTransition/myNavPathStack';

@Entry
@Component
struct Index {
  @State current: number = 0;
  /** 目前显示的是否根页面 */
  @State isRootPage: boolean = true;
  inPageStack: MyNavPathStack = new MyNavPathStack();
  @Provide('pageStack') pageStack: MyNavPathStack = this.inPageStack;

  lastTime: number = 0;

  aboutToAppear(): void {
    // this.getUIContext()
    // console.log('1');

    this.pageStack.setInterception({
      didShow: () => {
        if (this.inPageStack.getAllPathName().length <= 0) {
          this.isRootPage = true;
        }
        else {
          this.isRootPage = false;
        }
      }
    });
    // CustomTransition.getInstance().registerNavParam(-1, () => {}, 500);
  }

  aboutToDisappear() {
    // CustomTransition.getInstance().unRegisterNavParam(-1);
  }

  onPageShow(): void {
    // console.log('123123')
    // this.getUIContext().getComponentUtils().getRectangleById()
  }

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
    Navigation(this.inPageStack) {
      Tabs({index: 0}) {

        TabContent() {
          Home({pageShow: this.current === 0})
        }
        .tabBar(this.tabBar(0, '首页', $r('app.media.home')))

        TabContent() {
          Statistics({pageShow: this.current === 1})
        }
        .tabBar(this.tabBar(1, '统计', $r('app.media.chart')))

        TabContent() {
          My({pageShow: this.current === 2, pageStack: this.inPageStack, isRootPage: this.isRootPage})
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
    // .customNavContentTransition((from, to, operation) => {
    //   const pages = ['AddRecord'];
    //   if (!from || !to) return undefined;
    //   // if (from.index === -1 || to.index === -1) {
    //   // }
    //
    //   if (!(pages.includes(from.name || '') || pages.includes(to.name || ''))) return undefined;
    //
    //   // let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.index);
    //   // let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.index);
    //   // if (!fromParam.animation || !toParam.animation) {
    //   //   return undefined;
    //   // }
    //
    //   const customAnimation: NavigationAnimatedTransition = {
    //     timeout: 2000,
    //     onTransitionEnd: (isSuccess: boolean) => {
    //       console.log(`当前转换结果为 ${isSuccess}`);
    //     },
    //     transition: (transitionProxy: NavigationTransitionProxy): void => {
    //       // throw new Error('Function not implemented.');
    //       // if (fromParam.animation) {
    //       //   fromParam.animation(operation == NavigationOperation.PUSH, true, transitionProxy);
    //       // }
    //       // if (toParam.animation) {
    //       //   toParam.animation(operation == NavigationOperation.PUSH, false, transitionProxy);
    //       // }
    //     }
    //   };
    //
    //   return customAnimation;
    // })
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
