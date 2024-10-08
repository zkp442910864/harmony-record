import { CommonConstants } from '../../../constants/CommonConstants'
import { RecordClass } from '../../../viewmodel/record';
import { RecordModel, RecordDayTitleModel, EnumRecordType } from '../../../viewmodel/types/base';
import { uiObserver } from '@kit.ArkUI';
import { DateUtils, EventBus } from '../../../utils';

@Component
export struct Home {
  @Prop @Watch('onCustomPageShow') pageShow: boolean = false;
  @Consume('pageStack') pageStack?: NavPathStack;
  @State homeData: RecordClass = new RecordClass()

  aboutToAppear(): void {
    this.onCustomPageShow()
    this.homeData.switchDate()
    EventBus.on('updateHomeData', this.getData)
  }

  aboutToDisappear(): void {
    EventBus.off('updateHomeData', this.getData);
  }

  onCustomPageShow() {
    if (this.pageShow) {
      console.log('Home 显示')
    }
  }

  /** 添加记录 */
  linkAdd() {
    this.pageStack?.pushPathByName('AddRecord', '');
  }

  getData = (): Promise<void> => this.homeData.getData()

  build() {
    Stack() {
      Column() {
        // Button('取消监听').onClick(() => {
        //   EventBus.off('updateHomeData');
        // })
        // Text(`${this.homeData.listData.length}`)
        Row({ space: 16 }) {
          Text(`${this.homeData.currentMonth}月`)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .backgroundColor(CommonConstants.COLOR_MAIN)
            .fontSize(28)
            .width(120)
            .height(120)
            .textAlign(TextAlign.Center)
            .borderRadius(16)
            .shadow(CommonConstants.BOX_SHADOW)

          Column({ space: 16 }) {
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
          ForEach(this.homeData.listData, (item: RecordDayTitleModel) => {
            ListItemGroup({ header: this.listTitle(item) }) {
              ForEach(item.children!, (child: RecordModel<Date>) => {
                ListItem() {
                  this.listContent(child)
                }
                .width('100%')
              })
            }
          })
        }
        .edgeEffect(EdgeEffect.Fade)
        .shadow({ radius: 10, color: Color.Gray, offsetY: 6 })
        .sticky(StickyStyle.Header)
        .flexGrow(1)
        .height(0)

        // .divider({strokeWidth: 1, color: '#000', startMargin: 16, endMargin: 16})
      }
      .width('100%')
      .height('100%')

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
      .position({ right: 10, bottom: 30 })
      .onClick(() => this.linkAdd())
    }
    .height('100%')
    .width('100%')
    .backgroundColor(CommonConstants.COLOR_OTHER1)
  }

  @Builder
  listContent(item: RecordModel<Date>, showDivider = true) {
    Column() {
      Row({ space: 6 }) {
        Column() {
          Text(item.recordTypeName)
          // Text(item.recordDate?.toLocaleTimeString())
          //   .margin({top: 4})
          //   .fontColor(Color.Gray)
          //   .fontSize(10)
          Text(item.remarks ? `备注：${item.remarks}` : item.remarks)
            .fontColor(Color.Gray)
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(10)
            .alignSelf(ItemAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        .width(0)

        Column() {
          Text(`${item.valueType === EnumRecordType.IN ? '+' : '-'}${item.value}`)
            .fontColor(item.valueType === EnumRecordType.IN ? CommonConstants.COLOR_TEXT_IN :
            CommonConstants.COLOR_TEXT_OUT)
          Text(DateUtils.toTimeString(item.recordDate))
            .margin({ top: 4 })
            .fontColor(Color.Gray)
            .fontSize(10)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({
        top: 8,
        bottom: 8,
        left: 16,
        right: 16
      })

      if (showDivider) {
        Divider()
          .color('#40d2d2d2')
          .strokeWidth(1.5)
          .lineCap(LineCapStyle.Round)
          .margin({ left: 60, right: 60 })
      }
    }
    .width('100%')
  }

  @Builder
  listTitle(item: RecordDayTitleModel) {
    Row() {
      Text(item.date)
        .fontSize(14)

      Row({ space: 16 }) {
        Row({ space: 2 }) {
          Text('收入')
            .fontSize(12)
          Text(item.inTotal)
            .fontSize(14)
            .fontColor(CommonConstants.COLOR_TEXT_IN)
        };

        Row({ space: 2 }) {
          Text('支出')
            .fontSize(12)
          Text(item.outTotal)
            .fontSize(14)
            .fontColor(CommonConstants.COLOR_TEXT_OUT)
        };
      };
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16
    })
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
  }

  @Builder
  topTotalText(type: 'in' | 'out') {
    Row({ space: 6 }) {
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
