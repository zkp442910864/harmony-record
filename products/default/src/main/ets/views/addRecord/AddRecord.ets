import { CommonConstants } from '../../constants/CommonConstants'
import { EnumRecordType } from '../../viewmodel/base'
import { RecordType } from './RecordType'
import { curves } from '@kit.ArkUI'

@Builder
export function AddRecordBuilder ()  {
  AddRecord()
}

@Preview
@Component
struct AddRecord {
  pathStack: NavPathStack = new NavPathStack()
  recordType = new RecordType()
  @State currentRecordType: EnumRecordType = EnumRecordType.OUT
  @State currentRecordBg: number = 0;

  build() {
    NavDestination() {
      Column() {
        Text('111')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_OTHER1)
    }
    .title(this.navTitle)
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .onReady((context) => {
      this.pathStack = context.pathStack;
      context.getConfigInRouteMap()
    })
    .onAppear(() => {
      // this.pathStack.getParent()
    })
  }

  @Builder
  navTitle() {
    Row() {
      Row() {
        Stack() {
          Row()
            .backgroundColor(CommonConstants.COLOR_SECONDARY)
            .width(76)
            .height(32)
            .borderRadius(16)
            .zIndex(1)
            .position({top: 2, bottom: 2, left: 2})
            .translate({x: this.currentRecordBg})

          Row() {
            this.navTitleText('支出', EnumRecordType.OUT)
            this.navTitleText('收入', EnumRecordType.IN)

          }
          .zIndex(2)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .width(160)
          .height(36)
        }
      }
      .backgroundColor(CommonConstants.COLOR_OTHER1)
      .borderRadius(16)
      // .margin({left: -100})
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }

  @Builder
  navTitleText(text: string, type: EnumRecordType) {
    Text(text)
      .fontSize(16)
      .padding(8)
      .width(80)
      .textAlign(TextAlign.Center)
      .fontColor(this.currentRecordType === type ? CommonConstants.COLOR_MAIN : '#333')
      .onClick(() => {
        this.currentRecordType = type;
        this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
          this.currentRecordBg = EnumRecordType.IN === type ? 80 : 0;
        })
      })
  }
}