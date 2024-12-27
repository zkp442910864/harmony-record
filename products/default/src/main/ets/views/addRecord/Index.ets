import { CommonConstants } from '../../constants/CommonConstants'
import { EnumRecordType, RecordModel, RecordTypeModel } from '../../viewmodel/types/base'
import { RecordType } from '../../viewmodel/recordType'
import { BuilderNode, curves, NodeController, SymbolGlyphModifier } from '@kit.ArkUI'
import { NumberKeyboard } from '../../components/numberKeyboard/Index'
import { JSON } from '@kit.ArkTS'
import { DataSql } from '../../sql/dataSql'
import { EventBus, isEmpty, toast } from '../../utils'
import { ITransitionParam, MyNavDestinationAnimationModifier } from '../../routerTransition/index'

@Builder
export function builderFn() {
  AddRecord()
}

@Preview
@Entry
@ComponentV2
struct AddRecord {
  pathStack: NavPathStack = new NavPathStack()
  @Local cacheData: CacheData = new CacheData()
  @Local myNavDestinationAnimationModifier: MyNavDestinationAnimationModifier = new MyNavDestinationAnimationModifier(
    this,
    async (context) => {
      this.pathStack = context.pathStack;
      const param = context.pathInfo.param as ITransitionParam<RecordModel<Date>>;

      await this.initData();
      if (param.data) this.handleEditData(param.data);
    }
  );
  @Local recordType: RecordType = new RecordType()
  @Local currentRecordBg: number = 0;
  @Local params: Cparams = new Cparams();

  aboutToAppear(): void {}

  initData = async () => {
    await this.recordType.getRecordTypeDataDb();

    this.cacheData.outRecordTypeId = this.recordType.outTypeArr[0].id;
    this.cacheData.inRecordTypeId = this.recordType.inTypeArr[0].id;
    this.params.recordTypeId = this.cacheData.outRecordTypeId;
  }

  handleEditData = (item: RecordModel<Date>) => {
    this.toggleTopType(item.valueType!);
    this.toggleType(item.valueType!, {id: item.recordTypeId});
    // this.params = JSON.parse(JSON.stringify(item)) as RecordModel<Date>;
    this.params = new Cparams(item.valueType, item.value, item.remarks, item.recordTypeId, item.id, item.recordDate);
  }

  /** 切换顶部菜单类型 */
  toggleTopType = (type: EnumRecordType) => {
    this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
      this.params.valueType = type;
      this.params.recordTypeId =
        EnumRecordType.IN === type ? this.cacheData.inRecordTypeId : this.cacheData.outRecordTypeId;
      this.currentRecordBg = EnumRecordType.IN === type ? 80 : 0;
    })
  }

  /** 切换类型 */
  toggleType = (type: EnumRecordType, item: RecordTypeModel) => {
    if (type === EnumRecordType.OUT) {
      this.cacheData.outRecordTypeId = item.id;
    } else {
      this.cacheData.inRecordTypeId = item.id;
    }

    this.params.recordTypeId = item.id;
  }

  commit = async () => {
    if (isEmpty(this.params.value)) {
      toast('请输入金额');
      return;
    }
    if (this.params.id) {
      await DataSql.getInstance().updateRecordItem(this.params.toCopyData());
    }
    else {
      this.params.recordDate = new Date();
      await DataSql.getInstance().insertRecordItem(this.params.toCopyData());
    }

    setTimeout(() => {
      this.pathStack.pop();
    })
    EventBus.emit('updateHomeData')
  }

  build() {
    NavDestination() {
      Column() {
        if (this.params.valueType === EnumRecordType.OUT) {
          this.content(EnumRecordType.OUT)
        } else {
          this.content(EnumRecordType.IN)
        }

        NumberKeyboard({
          children: () => {
            this.numberKeyboardTopBox()
          },
          value: this.params.value,
          onChange: (newValue) => {
            this.params.value = newValue;
          },
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
    .menus([
      {
        value: '保存',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.save'))
          .fontSize(20)
          .fontColor([CommonConstants.COLOR_MAIN]),
        action: this.commit,
      }
    ])
    .attributeModifier(this.myNavDestinationAnimationModifier)
    .onReady((context) => {
      this.myNavDestinationAnimationModifier.ready(context);
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
    .margin({ left: 16 })
    // .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .height('100%')
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
        this.toggleTopType(type);
      })
  }

  @Builder
  content(type: EnumRecordType) {
    List() {
      ForEach(
        type === EnumRecordType.OUT ? this.recordType.outTypeArr : this.recordType.inTypeArr,
        (item: RecordTypeModel) => {
          ListItem() {
            Button(item.recordName)
              .type(ButtonType.Normal)
              .borderRadius(8)
              .shadow({ radius: 6, color: '#3e000000' })
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .padding(0)
              .fontSize(12)
              .width('100%')
              .backgroundColor(this.params.recordTypeId === item.id ? CommonConstants.COLOR_MAIN :
              CommonConstants.COLOR_SECONDARY)
              .onClick(() => {
                this.toggleType(type, item)
              })
          }
          .padding(4)
        },
        (item: RecordTypeModel) => item.id!.toString())
    }
    .padding(4)
    .lanes(5)
    .opacity(this.params.valueType === type ? 1 : 0)
  }

  @Builder
  numberKeyboardTopBox() {
    Row() {
      TextInput({text: this.params.remarks, placeholder: '请输入备注'})
        .flexGrow(1)
        .width(0)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding(0)
        .fontSize(12)
        .placeholderFont({size: 12})
        .onChange((val) => {
          this.params.remarks = val.toString()
        })

      Text(this.params.value || '0.00')
      // .flexGrow(1)
      // .width(0)
    }
    .padding({left: 16, top: 8, right: 16})
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

}

@ObservedV2
class Cparams implements RecordModel<Date> {
  @Trace valueType = EnumRecordType.OUT;
  @Trace value = '';
  @Trace remarks = '';
  @Trace recordTypeId: number | undefined;
  id: number | undefined;
  @Trace recordDate: Date | undefined;

  constructor(valueType?: EnumRecordType, value?: string, remarks?: string, recordTypeId?: number, id?: number, recordDate?: Date) {
    if (id) {
      this.valueType = valueType!
      this.value = value!
      this.remarks = remarks!
      this.recordTypeId = recordTypeId!
      this.id = id!
      this.recordDate = recordDate!
    }
  }

  toCopyData() {
    const data: RecordModel<Date> = {
      valueType: this.valueType,
      value: this.value,
      remarks: this.remarks,
      recordTypeId: this.recordTypeId,
      id: this.id,
      recordDate: this.recordDate,
    };

    return data;
  }
}

@ObservedV2
class CacheData {
  @Trace outRecordTypeId?: number;
  @Trace inRecordTypeId?: number
}
