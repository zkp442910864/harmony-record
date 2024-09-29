import { CommonConstants } from '../../../constants/CommonConstants'
import { RecordClass } from '../../../viewmodel/record';
import { RecordModel, RecordDayTitleModel, EnumRecordType } from '../../../viewmodel/types/base';
import { uiObserver } from '@kit.ArkUI';
import { EventBus } from '../../../utils';

@Component
export struct Home {

  @Consume('pageStack') pageStack?: NavPathStack;
  @State homeData: RecordClass = new RecordClass()

  aboutToAppear(): void {
    this.homeData.switchDate()
    EventBus.on('updateHomeData', this.getData)
  }

  aboutToDisappear(): void {
    EventBus.off('updateHomeData', this.getData);
  }

  /** 添加记录 */
  linkAdd() {
    this.pageStack?.pushPathByName('AddRecord', '');
  }

  getData = (): Promise<void> => this.homeData.getData()

  build() {
    Stack() {
      Scroll() {
        Column() {
          // Button('取消监听').onClick(() => {
          //   EventBus.off('updateHomeData');
          // })
          // Text(`${this.homeData.listData.length}`)
          Row({space: 16}) {
            Text(`${this.homeData.currentMonth}月`)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .backgroundColor(CommonConstants.COLOR_MAIN)
              .fontSize(28)
              .width(120)
              .height(120)
              .textAlign(TextAlign.Center)
              .borderRadius(16)
              .shadow(CommonConstants.BOX_SHADOW)

            Column({space: 16}) {
              this.topTotalText('in')
              this.topTotalText('out')
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
            ForEach(this.homeData.listData, (item: RecordModel<Date> | RecordDayTitleModel) => {
              ListItem() {
                if ((item as RecordDayTitleModel).isTitle) {
                  this.listTitle(
                    (item as RecordDayTitleModel).date,
                    (item as RecordDayTitleModel).inTotal,
                    (item as RecordDayTitleModel).outTotal,
                  )
                }
                else {
                  this.listContent(item as RecordModel<Date>)
                }
              }
              .width('100%')
            })

          }
          .shadow({ radius: 10, color: Color.Gray, offsetY: 6 })
          // .divider({strokeWidth: 1, color: '#000', startMargin: 16, endMargin: 16})
          // .sticky(StickyStyle.Header)
        }
        .width('100%')
      }
      .align(Alignment.TopStart)
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

  @Builder
  listContent(item: RecordModel<Date>, showDivider = true) {
    Column() {
      Row({space: 6}) {
        Column() {
          Text(item.recordTypeName)
          Text(item.recordDate?.toLocaleTimeString())
            .margin({top: 4})
            .fontColor(Color.Gray)
            .fontSize(10)
        }
        .alignItems(HorizontalAlign.Start)
        Text(item.remarks ? `备注：${item.remarks}` : item.remarks)
          .fontColor(Color.Gray)
          .maxLines(2)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .flexGrow(1)
          .width(0)
          .fontSize(10)
          .alignSelf(ItemAlign.Start)
        Text(`${item.valueType === EnumRecordType.IN ? '+' : '-'}${item.value}`)
          .fontColor(item.valueType === EnumRecordType.IN ? CommonConstants.COLOR_TEXT_IN : CommonConstants.COLOR_TEXT_OUT)
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
  topTotalText(type: 'in' | 'out') {
    Row({space: 6}) {
      Text(type === 'out' ? '支出' : '收入')
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .fontWeight(type === 'out' ? FontWeight.Bold : FontWeight.Normal)
      Text(type === 'out' ? this.homeData.monthOutTotal : this.homeData.monthInTotal)
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
