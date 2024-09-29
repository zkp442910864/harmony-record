import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils'
import { CommonConstants } from '../../../constants/CommonConstants'
import curves from '@ohos.curves'

@Preview
@Entry
@Component
export struct My {
  options: IOptionItem[] = [
    {label: '资产管理', value: 'setPrice'},
    {label: '分类管理', value: 'setClass'},
    {label: '安全设置', value: 'setSafety'},
    {label: '上传坚果云', value: 'uploadCloud'},
    // {label: '设置资产', value: 'set'},
    // {label: '设置资产', value: 'set'},
    // {label: '设置资产', value: 'set'},
    // {label: '设置资产', value: 'set'},
    // {label: '设置资产', value: 'set'},
    // {label: '设置资产10', value: 'set'},
    // {label: '设置资产9', value: 'set'},
    // {label: '设置资产8', value: 'set'},
    // {label: '设置资产7', value: 'set'},
    // {label: '设置资产6', value: 'set'},
    // {label: '设置资产5', value: 'set'},
    // {label: '设置资产4', value: 'set'},
    // {label: '设置资产3', value: 'set'},
    // {label: '设置资产2', value: 'set'},
    // {label: '设置资产1', value: 'set'},
  ];

  action(value: string) {
    console.log(value)
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
            Text('0.00')
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
            ForEach(this.options, (item: IOptionItem) => {
              Row() {
                Text(item.label)
                  .fontSize(12)
                Text() {
                  SymbolSpan($r('sys.symbol.chevron_right'))
                }
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
              .padding({left: 16, right: 16, top: 12, bottom: 12})
              .onClick(() => this.action(item.value))

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

interface IOptionItem {
  label: string;
  value: string;
}
