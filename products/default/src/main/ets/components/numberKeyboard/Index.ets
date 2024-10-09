import { CommonConstants } from '../../constants/CommonConstants';
import { RecordModel } from '../../viewmodel/types/base';

@Preview
// @Entry
@Component
export struct NumberKeyboard {
  @Prop value?: string;
  boxHeight: string = '36%';
  onChange?: (newValue: string, currentValue: string) => void;
  commit?: () => void;
  @BuilderParam children?: () => void;
  @BuilderParam actionBtnExtend?: () => void;
  // @Consume('params') params: RecordModel;
  // @State params: Partial<RecordModel> = {};
  numberArr = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
    '0', '.',
  ]

  build() {
    Column() {
      if (this.children) {
        this.children();
      }

      Row() {
        Grid(undefined, {
          regularSize: [1, 1],
          onGetRectByIndex: (index) => {
            if (this.numberArr[index] === '0') {
              return [4, 0, 1, 2]
            }

            return [parseInt(`${index / 4}`), parseInt(`${index / 3}`), 1, 1]
          }
        }) {
          ForEach(this.numberArr, (val: string) => {
            GridItem() {
              if (val) {
                Button(val)
                  .customButtonStyle()
                  .onClick(() => this.setValue(val))
              }
            }
          }, (val: string) => val)
        }
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .columnsTemplate('1fr 1fr 1fr')
        .width('70%')
        .columnsGap(16)
        .rowsGap(16)
        .padding({left: 16, bottom: 16, right: 16, top: 8})

        Column({space: 16}) {
          Button() {
            Text() {
              SymbolSpan($r('sys.symbol.delete_left'))
                .fontColor([CommonConstants.COLOR_TEXT_MAIN])
                .fontSize(40)
            }
          }
            .customButtonStyle()
            .flexGrow(1)
            .height(0)
            .onClick(() => this.setValue('del'))

          if (this.commit) {
            Button('确定')
              .customButtonStyle()
              .flexGrow(3)
              .height(0)
              .onClick(() => this.commit?.())
          }

          this.actionBtnExtend?.();
        }
        .width('30%')
        .height('100%')
        .padding({left: 0, bottom: 16, right: 16, top: 8})

      }
      .flexGrow(1)
      .height(0)
    }
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .width('100%')
    .height(this.boxHeight)
  }

  setValue(val: string) {
    const oleValue = this.value || '';
    let valArr = oleValue.split('').filter(ii => ii !== '');

    if (val === 'del') {
      if (oleValue === '0.') {
        valArr = [];
      }
      else if (valArr.length) {
        valArr.pop()
      }
    }
    else {
      if (val === '.') {
        if (valArr.length === 0) {
          valArr.push('0');
        }
        else if (valArr.indexOf('.') > -1) {
          return;
        }
      }

      valArr.push(val)
    }

    // this.params.value = valArr.join('');
    this.onChange?.(valArr.join(''), val);
  }
}

@Extend(Button)
function customButtonStyle() {
  .type(ButtonType.Normal)
  .borderRadius(8)
  .shadow(CommonConstants.BOX_SHADOW)
  .fontColor(CommonConstants.COLOR_TEXT_MAIN)
  .width('100%')
  .backgroundColor(CommonConstants.COLOR_MAIN)
  .height('100%')
}
