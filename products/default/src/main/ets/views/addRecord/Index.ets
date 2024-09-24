import { CommonConstants } from '../../constants/CommonConstants'
import { EnumRecordType, ItemDataModel, RecordTypeModel } from '../../viewmodel/base'
import { CacheData, RecordType } from '../../viewmodel/recordType'
import { curves } from '@kit.ArkUI'
import { NumberKeyboard } from '../../components/numberKeyboard/Index'
import { JSON } from '@kit.ArkTS'

@Builder
export function builderFn() {
  AddRecord()
}

@Preview
@Entry
@Component
struct AddRecord {
  pathStack: NavPathStack = new NavPathStack()
  recordType = new RecordType()
  cacheData: CacheData = {}
  @State currentRecordBg: number = 0;
  @Provide('params') params: Partial<ItemDataModel> = {
    valueType: EnumRecordType.OUT,
    value: '',
    remarks: ''
  };

  aboutToAppear(): void {
    this.cacheData.outRecordTypeId = this.recordType.outTypeArr[0].id;
    this.cacheData.inRecordTypeId = this.recordType.inTypeArr[0].id;
    this.params.recordTypeId = this.cacheData.outRecordTypeId;
  }

  build() {
    NavDestination() {
      Column() {
        if (this.params.valueType === EnumRecordType.OUT) {
          this.content(this.recordType.outTypeArr, EnumRecordType.OUT)
        } else {
          this.content(this.recordType.inTypeArr, EnumRecordType.IN)
        }

        NumberKeyboard({
          commit: this.commit
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
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

  commit() {
    console.log(JSON.stringify(this.params))

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
            .position({ top: 2, bottom: 2, left: 2 })
            .translate({ x: this.currentRecordBg })

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
    .margin({left: 16})
    // .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .height('100%')
    // .width('100%')
  }

  @Builder
  navTitleText(text: string, type: EnumRecordType) {
    Text(text)
      .fontSize(16)
      .padding(8)
      .width(80)
      .textAlign(TextAlign.Center)
      .fontColor(this.params.valueType === type ? CommonConstants.COLOR_MAIN : '#333')
      .onClick(() => {
        this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
          this.params.valueType = type;
          this.params.recordTypeId = EnumRecordType.IN === type ? this.cacheData.inRecordTypeId : this.cacheData.outRecordTypeId;
          this.currentRecordBg = EnumRecordType.IN === type ? 80 : 0;
        })
      })
  }

  @Builder
  content(data: RecordTypeModel[], type: EnumRecordType) {
    List() {
      ForEach(data, (item: RecordTypeModel) => {
        ListItem() {
          Button(item.recordName)
            .type(ButtonType.Normal)
            .borderRadius(8)
            .shadow( { radius: 6, color: '#3e000000' })
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .padding(0)
            .fontSize(12)
            .width('100%')
            .backgroundColor(this.params.recordTypeId === item.id ? CommonConstants.COLOR_MAIN : CommonConstants.COLOR_SECONDARY)
            .onClick(() => {
              if (type === EnumRecordType.OUT) {
                this.cacheData.outRecordTypeId = item.id;
              }
              else {
                this.cacheData.inRecordTypeId = item.id;
              }

              this.params.recordTypeId = item.id;
            })
        }
        .padding(4)
      }, (item: RecordTypeModel) => item.id.toString())
    }
    .padding(4)
    .lanes(5)
    .opacity(this.params.valueType === type ? 1 : 0)
  }
}