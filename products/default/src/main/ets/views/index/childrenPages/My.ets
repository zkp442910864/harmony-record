import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils'
import { CommonConstants } from '../../../constants/CommonConstants'
import curves from '@ohos.curves'
import { DataSql } from '../../../sql/dataSql';
import { getSqlObj } from '../../../sql/baseSql';
import { ComponentContent } from '@kit.ArkUI';
import { updatePriceDialogFn } from '../modules/UpdatePriceDialog';
import { sleep } from '../../../utils';
import { CloudBackup } from '../../../utils/cloudBackup';
import { ITransitionParam } from '../../../routerTransition';
import { RecordModel } from '../../../viewmodel/types/base';

@Preview
@Entry
@ComponentV2
export struct My {
  @Param @Require pageStack: NavPathStack = new NavPathStack();
  @Param isRootPage: boolean = true;
  @Param pageShow: boolean = false;
  @Local totalPrice: string = '0.00';
  @Local options: COptionItem[] = [
    new COptionItem('资产管理', 'setPrice'),
    // new COptionItem('分类管理', 'setClass'),
    // new COptionItem('安全设置', 'setSafety'),
    new COptionItem('云备份设置', 'uploadCloud'),
    new COptionItem('重启sql', 'resetSql'),
  ];

  aboutToAppear(): void {
    this.onCustomPageShow();
  }

  @Monitor('pageShow', 'isRootPage')
  onCustomPageShow() {
    if (this.pageShow && this.isRootPage) {
      console.log('My 显示')
      this.getData();
    }
  }

  async getData() {
    this.totalPrice = await DataSql.getInstance().queryLastWalletItem();
  }

  async action(e: ClickEvent, type: string, item: COptionItem, index: number) {
    // console.log(type)
    if (type === 'setPrice') {
      updatePriceDialogFn(this.getUIContext()).then(() => {
        this.getData();
      });
    }
    else if (type === 'uploadCloud') {
      const data: ITransitionParam<RecordModel<Date>> = {
        x: e.windowX - e.x,
        y: e.windowY - e.y,
        targetWidth: e.target.area.width,
        targetHeight: e.target.area.height,
        // data: item,
      };
      this.pageStack.pushPathByName('CloudBackupSet', data, false);
    }
    else if (type === 'resetSql') {
      if (item.loading) return;
      item.loading = true;
      DataSql.destroyInstance();
      await getSqlObj().resetStart(getContext());
      await sleep(1000);
      item.loading = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        Stack() {
          Image($r('app.media.ic_launcher'))
            .backgroundColor('#fff')
            .width(60)
            .height(60)
            .borderRadius('50%')
            .padding(16)
            .zIndex(2)
            .shadow(CommonConstants.BOX_SHADOW)
            .margin({top: -60})
          Row() {
            Text('资产')
              .flexGrow(1)
              .width(0)
              .textAlign(TextAlign.Start)
            Text(this.totalPrice)
              .flexGrow(1)
              .width(0)
              .textAlign(TextAlign.End)
          }
          .backgroundColor('#fff')
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(16)
          .padding(16)
          .width('100%')
        }
        .padding({top: 50, left: 16, right: 16})

        Stack() {
          Column() {
            ForEach(this.options, (item: COptionItem, index) => {
              Row() {
                Text(item.label)
                  .fontSize(12)

                if (item.loading) {
                  SymbolGlyph($r('sys.symbol.rays'))
                    .fontSize(20)
                    .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), true)
                }
                else {
                  Text() {
                    SymbolSpan($r('sys.symbol.chevron_right'))
                      .fontSize(20)
                  }
                }
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
              .padding({left: 16, right: 16, top: 12, bottom: 12})
              .onClick((e) => this.action(e, item.value, item, index))

              Divider()
                .margin({left: 60, right: 60})
                .color('#22666666')
            })
          }
          .borderRadius(16)
          .backgroundColor('#fff')
        }
        .padding(16)
      }
      .width('100%')
    }
    .align(Alignment.TopStart)
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
  }
}

@ObservedV2
class COptionItem {
  label: string;
  value: string;
  @Trace loading?: boolean;

  constructor(label: string, value: string, loading: boolean = false) {
    this.label = label;
    this.value = value;
    this.loading = loading;
  }

}
