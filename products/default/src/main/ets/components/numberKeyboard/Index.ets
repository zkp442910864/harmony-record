import { CommonConstants } from '../../constants/CommonConstants';
import { ItemDataModel } from '../../viewmodel/base';

@Preview
// @Entry
@Component
export struct NumberKeyboard {
  @Require commit = () => {};
  @Consume('params') params: Partial<ItemDataModel>
  // @State params: Partial<ItemDataModel> = {};
  numberArr = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
    '0', '.',
  ]

  build() {
    Column() {
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
            Image($r('app.media.blank'))
              .fillColor(CommonConstants.COLOR_TEXT_MAIN)
              .size({
                // width: 50,
                height: 40
              })
          }
            .customButtonStyle()
            .flexGrow(1)
            .height(0)
            .onClick(() => this.setValue('del'))
          Button('确定')
            .customButtonStyle()
            .flexGrow(3)
            .height(0)
            .onClick(() => this.commit())
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
    .height('36%')
  }

  setValue(val: string) {
    const oleValue = this.params.value || '';
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

    this.params.value = valArr.join('');
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
