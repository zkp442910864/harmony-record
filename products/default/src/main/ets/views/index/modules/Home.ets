import { CommonConstants } from '../../../constants/CommonConstants'

@Component
export struct IndexHome {

  @Consume('pageStack') pageStack?: NavPathStack;

  build() {
    Stack() {
      Scroll() {
        Column() {
          Row({space: 16}) {
            Text('9月')
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .backgroundColor(CommonConstants.COLOR_MAIN)
              .fontSize(28)
              .width(120)
              .height(120)
              .textAlign(TextAlign.Center)
              .borderRadius(16)
              .shadow(CommonConstants.BOX_SHADOW)

            Column({space: 16}) {
              this.topTotalText('in', '收入', '122222.00')
              this.topTotalText('out', '支出', '0.00')
            }
            .flexGrow(1)
            .width(0)
            // .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(CommonConstants.COLOR_SECONDARY)


          List() {
            ListItem() {
              this.listTitle('09.23', '100', '10')
            }
            .width('100%')

            ListItem() {
              this.listContent('类型', '10.00', 1)
            }
            .width('100%')

            ListItem() {
              this.listContent('类型', '10.00', 2, false)
            }
            .width('100%')
          }
          .shadow({ radius: 10, color: Color.Gray, offsetY: 6 })
          // .divider({strokeWidth: 1, color: '#000', startMargin: 16, endMargin: 16})
          // .sticky(StickyStyle.Header)
        }
        .height('100%')
        .width('100%')
      }
      .height('100%')
      .width('100%')

      Button() {
        Text('+')
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
      }
      .type(ButtonType.Circle)
      .backgroundColor(CommonConstants.COLOR_MAIN)
      .width(50)
      .height(50)
      .shadow(CommonConstants.BOX_SHADOW)
      .position({right: 10, bottom: 30})
      .onClick(() => this.linkAdd())
    }
    .height('100%')
    .width('100%')
    .backgroundColor(CommonConstants.COLOR_OTHER1)
  }

  /** 添加记录 */
  linkAdd() {
    this.pageStack?.pushPathByName('AddRecord', '');
  }

  @Builder
  listContent(typeStr: string, value: string, valueType: 1 | 2, showDivider = true) {
    Column() {
      Row({space: 6}) {
        Text(typeStr)
        Text('备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息')
          .fontColor(Color.Gray)
          .maxLines(2)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .flexGrow(1)
          .width(0)
          .fontSize(10)
        Text(`${valueType === 1 ? '+' : '-'}${value}`)
          .fontColor(valueType === 1 ? CommonConstants.COLOR_TEXT_IN : CommonConstants.COLOR_TEXT_OUT)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({top: 8, bottom: 8, left: 16, right: 16})

      if (showDivider) {
        Divider()
          .color('#40d2d2d2')
          .strokeWidth(1.5)
          .lineCap(LineCapStyle.Round)
          .margin({left: 60, right: 60})
      }
    }
    .width('100%')
  }

  @Builder
  listTitle(day: string, inTotal: string, outTotal: string) {
    Row() {
      Text(day)
        .fontSize(14)

      Row({space: 16}) {
        Row({space: 2}) {
          Text('收入')
            .fontSize(12)
          Text(inTotal)
            .fontSize(14)
            .fontColor(CommonConstants.COLOR_TEXT_IN)
        };

        Row({space: 2}) {
          Text('支出')
            .fontSize(12)
          Text(outTotal)
            .fontSize(14)
            .fontColor(CommonConstants.COLOR_TEXT_OUT)
        };
      };
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({top: 8, bottom: 8, left: 16, right: 16})
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
  }

  @Builder
  topTotalText(type: 'in' | 'out', title: string, value: string) {
    Row({space: 6}) {
      Text(title)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .fontWeight(type === 'out' ? FontWeight.Bold : FontWeight.Normal)
      Text(value)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .fontSize(type === 'out' ? 20 : 16)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(CommonConstants.COLOR_MAIN)
    .width('100%')
    .height(52)
    .padding(8)
    .shadow(CommonConstants.BOX_SHADOW)
    .borderRadius(16)
    // .position({top: 0})
  }
}
