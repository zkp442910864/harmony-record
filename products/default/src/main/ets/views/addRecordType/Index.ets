import { CheckboxList } from '../../components/checkboxList'
import { CommonConstants } from '../../constants/CommonConstants'
import { EnumRecordType, RecordTypeModel } from '../../viewmodel/types/base'
import { SymbolGlyphModifier } from '@ohos.arkui.modifier'
import { RadioList } from '../../components/radioList/Index'
import { JSON } from '@kit.ArkTS'

@Builder
export function builderFn() {
  AddRecordType()
}

@ComponentV2
@Preview
@Entry
struct AddRecordType {
  pathStack: NavPathStack = new NavPathStack()
  textInputController: TextInputController = new TextInputController();
  @Local params: RecordType = new RecordType();

  commit = () => {
    console.log(`RecordType: ${JSON.stringify(this.params)}`)
    this.pathStack.pop()
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('分类名称')
            // .onClick(() => {
            //   this.textInputController.caretPosition(0)
            // })
          TextInput({placeholder: '请输入', text: this.params.recordName, controller: this.textInputController})
            .backgroundColor(Color.Transparent)
            .textAlign(TextAlign.End)
            .flexGrow(1)
            .width(0)
            .defaultFocus(true)
            .onChange((val) => {
              this.params.recordName = val;
            })
        }
        .commonRowStyle()

        Row({space: 8}) {
          Text('分类类型')
          Blank()
          RadioList({
            options: [
              {label: '支出', value: EnumRecordType.OUT},
              {label: '收入', value: EnumRecordType.IN},
              {label: '所有', value: EnumRecordType.ALL},
            ],
            value: this.params.recordType,
            onChange: (val) => {
              this.params.recordType = val as number;
            }
          })
            .height(32)
        }
        .commonRowStyle()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_OTHER1)
    }
    .title('记录分类')
    .menus([
      {
        value: '保存',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.save'))
          .fontSize(20)
          .fontColor([CommonConstants.COLOR_MAIN]),
        action: this.commit,
      }
    ])
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .onReady((context) => {
      this.pathStack = context.pathStack;
    })
  }

}

@Extend(Row)
function commonRowStyle() {
  .justifyContent(FlexAlign.SpaceBetween)
  .width('100%')
  .padding(16)
}

@Extend(Checkbox)
function commonCheckboxStyle() {
  .shape(CheckBoxShape.ROUNDED_SQUARE)
  .selectedColor(CommonConstants.COLOR_SECONDARY)
}

@ObservedV2
class RecordType implements Partial<RecordTypeModel> {
  @Trace recordName = '';
  @Trace recordType = EnumRecordType.ALL;

  // public toJSON() {
  //   console.log(`RecordType: ${JSON.stringify(this)}`)
  //   return '';
  // }
}
