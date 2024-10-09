import { ComponentContent, inspector } from '@kit.ArkUI';
import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils';
import { NumberKeyboard } from '../../../components/numberKeyboard/Index';
import { CommonConstants } from '../../../constants/CommonConstants';
import { DataSql } from '../../../sql/dataSql';
import { toast } from '../../../utils';

@Component
struct UpdatePriceDialog {
  @State list: CListItem[] = [new CListItem()];
  @State selectCur: number = 0;
  scroller = new Scroller();
  listener = this.getUIContext().getUIInspector().createComponentObserver('textInputBox');
  focusController = this.getUIContext().getFocusController();
  /** input是为了控制焦点乱跳 */
  inputTypeAction?: 'add' | 'del' | 'input';

  aboutToAppear(): void {
    this.listener.on('layout', this.afterListUpdate)
  }

  aboutToDisappear(): void {
    this.listener.off('layout', this.afterListUpdate)
  }

  commit = () => {
    if (!this.checkList()) return;
    const total = this.list.reduce((total, item) => total += Number(item.value), 0);
    DataSql.getInstance().updateWalletData('overlay', total.toString());
    successCallback();
  }

  checkList() {
    if (this.list.some(ii => ii.value === '')) {
      toast('请输入资产');
      return false;
    }

    return true;
  }

  /** 更新后操作焦点 */
  afterListUpdate = () => {
    if (!this.inputTypeAction) {
      return;
    }
    if (this.inputTypeAction === 'input') {
      // input是为了控制焦点乱跳
      this.setInputFocus(`text-input-${this.selectCur}`);
    }
    else {
      // 定位并设置焦点
      const index = this.inputTypeAction === 'del' ? Math.max(this.selectCur - 1, 0) : this.list.length - 1;
      this.setInputFocus(`text-input-${index}`);
      this.scroller.scrollToIndex(index);
    }
    this.inputTypeAction = undefined;
  }

  /** 设置焦点 */
  setInputFocus(key?: string) {
    try {
      if (key) {
        this.focusController.requestFocus(key);
      } else {
        this.focusController.clearFocus();
      }
    } catch (err) {
      // 销毁时候，容易报错
    }
  }

  build() {
    Column() {
      Row() {
        Text('资产设置')
          .fontSize(18)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 8
      })

      List({scroller: this.scroller}) {
        ForEach(this.list, (item: CListItem, index: number) => {
          ListItem() {
            TextInput({ text: item.value })
              .key(`text-input-${index}`)
              .defaultFocus(index === 0)
              .customKeyboard(this.emptyContent)
              .textAlign(TextAlign.End)
              .borderRadius(8)
              .fontSize(14)
              .height(30)
              .margin({ bottom: 8 })
              .onFocus(() => {
                // console.info(`选中项` + index);
                if (this.inputTypeAction === 'input') return;
                this.selectCur = index;
              })
          }
        }, (item: CListItem) => item.now.toString())
      }
      .id('textInputBox')
      .padding({ left: 16, right: 16, bottom: 8 })
      .constraintSize({
        maxHeight: '40%'
      })

      NumberKeyboard({
        value: (this.list[this.selectCur] || this.list[0]).value,
        actionBtnExtend: () => {
          this.actionBtnExtend()
        },
        onChange: (newValue) => {
          this.inputTypeAction = 'input';
          this.list[this.selectCur] = new CListItem(newValue);
          this.focusController.clearFocus()
        }
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor('#fff')
    .width('100%')
  }

  @Builder
  actionBtnExtend() {
    Button('删除项')
      .type(ButtonType.Normal)
      .borderRadius(8)
      .shadow(CommonConstants.BOX_SHADOW)
      .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      .width('100%')
      .backgroundColor(CommonConstants.COLOR_MAIN)
      .height('100%')
      .flexGrow(1)
      .height(0)
      .onClick(() => {
        if (this.list.length <= 1) {
          return;
        }

        if (typeof this.selectCur === 'number') {
          this.inputTypeAction = 'del';
          this.setInputFocus();
          this.list.splice(this.selectCur, 1);
        }
      });
    Button('增加项')
      .type(ButtonType.Normal)
      .borderRadius(8)
      .shadow(CommonConstants.BOX_SHADOW)
      .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      .width('100%')
      .backgroundColor(CommonConstants.COLOR_MAIN)
      .height('100%')
      .flexGrow(1)
      .height(0)
      .onClick(() => {
        if (!this.checkList()) {
          return;
        }
        this.inputTypeAction = 'add';
        this.setInputFocus();
        this.list.push(new CListItem());
      });
    Button('确定')
      .type(ButtonType.Normal)
      .borderRadius(8)
      .shadow(CommonConstants.BOX_SHADOW)
      .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      .width('100%')
      .backgroundColor(CommonConstants.COLOR_MAIN)
      .height('100%')
      .flexGrow(1)
      .height(0)
      .onClick(this.commit)
  }

  @Builder
  emptyContent() {
  }
}

@Builder
function buildText() {
  UpdatePriceDialog();
}

let successCallback = () => {};
export const updatePriceDialogFn = async (uiContext: UIContext) => {
  return new Promise<void>((rel, rej) => {
    let success = false;
    const promptAction = uiContext.getPromptAction();
    const contentNode = new ComponentContent(uiContext, wrapBuilder(buildText));
    successCallback = () => {
      success = true;
      promptAction.closeCustomDialog(contentNode);
    };
    promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Bottom,
      isModal: true,
      // autoCancel: false,
      // transition: TransitionEffect.OPACITY
      onDidDisappear: () => {
        success ? rel() : rej();
      }
    });
  })
}

class CListItem {
  value = '';
  now = Date.now() + Math.random();

  constructor(value: string = '', now: number = Date.now() + Math.random()) {
    this.value = value;
    this.now = now;
  }
}
