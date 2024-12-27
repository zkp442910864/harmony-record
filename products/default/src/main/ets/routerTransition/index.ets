import { AttributeUpdater, curves, SymbolGlyphModifier } from "@kit.ArkUI";
import { CommonConstants } from "../constants/CommonConstants";

@ObservedV2
export class MyNavDestinationAnimationModifier extends AttributeUpdater<NavDestinationAttribute, NavDestinationInterface> {
  /** 离场映射 */
  static pathLeaveMap = new Map<number, (finishCallback: TFinishCallback) => void>();
  @Trace private boxWidth: Length = '0%';
  @Trace private boxHeight: Length = '0%';
  @Trace private boxPosition: Position = {x: 0, y: 0};
  @Trace private boxOpacity = 0;
  @Trace private boxBlur = true;
  // boxMode = NavDestinationMode.DIALOG;
  private uiContext: UIContext;
  private inParam?: ITransitionParam;
  private onReady: (context: NavDestinationContext) => void;

  constructor(component: CustomComponent, onReady: (context: NavDestinationContext) => void) {
    super();
    this.uiContext = component.getUIContext();
    this.onReady = onReady;
  }

  initializeModifier(instance: NavDestinationAttribute) {
    instance
      .width(this.boxWidth)
      .height(this.boxHeight)
      .mode(NavDestinationMode.DIALOG)
      // .opacity(this.boxOpacity);
      // .menus([
      //   {
      //     value: '保存',
      //     symbolIcon: new SymbolGlyphModifier($r('sys.symbol.save'))
      //       .fontSize(20)
      //       .fontColor([CommonConstants.COLOR_MAIN]),
      //     action: () => {},
      //   }
      // ])
  }

  applyNormalAttribute(instance: NavDestinationAttribute): void {
    instance
      .width(this.boxWidth)
      .height(this.boxHeight)
      .position(this.boxPosition)
      .opacity(this.boxOpacity);

    if (this.boxBlur) {
      instance.foregroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
    }
    // instance.mode(NavDestinationMode.DIALOG);
    // instance.onShown(() => {})
  }

  ready(context: NavDestinationContext) {
    MyNavDestinationAnimationModifier.pathLeaveMap.set(context.pathStack.getAllPathName().length - 1, (finishCallback: TFinishCallback) => {
      this.pageLeave(finishCallback);
    })
    this.inParam = context.pathInfo.param as ITransitionParam;
    this.pageEntry();
    this.onReady(context);
  }

  /** 页面打开 */
  private pageEntry() {
    const data = this.inParam!;
    this.boxPosition = {x: data.x, y: data.y};
    this.boxWidth = data.targetWidth;
    this.boxHeight = data.targetHeight;
    // this.boxOpacity = 1;

    this.uiContext.animateTo({
      curve: curves.springMotion(),
      // duration: 100,
    }, () => {
      this.boxPosition = {x: 0, y: 0}
    })

    this.uiContext.animateTo({
      curve: curves.springMotion(),
      // duration: 1000,
    }, () => {
      this.boxBlur = false;
      this.boxOpacity = 1;
      this.boxPosition = {x: 0, y: 0};
      this.boxWidth = '100%';
      this.boxHeight = '100%';
    })
  }

  /** 页面关闭 */
  private pageLeave(finishCallback: TFinishCallback) {
    if (!this.inParam) return;
    const data = this.inParam;

    // this.uiContext.keyframeAnimateTo({}, [
    //   {
    //     duration: 300,
    //     event: () => {
    //       this.boxOpacity = 0;
    //     }
    //   },
    //   {
    //     duration: 500,
    //     event: () => {
    //       this.boxPosition = {x: data.x, y: data.y};
    //       this.boxWidth = data.targetWidth;
    //       this.boxHeight = data.targetHeight;
    //       this.boxBlur = true;
    //       setTimeout(() => {
    //         finishCallback();
    //       }, 300);
    //     }
    //   }
    // ])

    // this.uiContext.animateTo({
    //   duration: 100,
    //   curve: curves.springMotion(),
    // }, () => {
    //   this.boxOpacity = 0;
    // })

    this.uiContext.animateTo({
      duration: 300,
      curve: curves.springMotion(),
    }, () => {
      this.boxBlur = true;
      this.boxPosition = {x: data.x, y: data.y};
      this.boxWidth = data.targetWidth;
      this.boxOpacity = 0;
      this.boxHeight = data.targetHeight;
      setTimeout(() => {
        finishCallback();
      }, 200);
    })
  }
}


type TFinishCallback = () => void;
export interface ITransitionParam<T = never> {
  /** 元素x坐标 */
  x: number;
  /** 元素y坐标 */
  y: number;
  /** 元素宽 */
  targetWidth: Length;
  /** 元素高 */
  targetHeight: Length;
  data?: T;
}
