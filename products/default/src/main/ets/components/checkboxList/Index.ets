import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils';
import { CommonConstants } from '../../constants/CommonConstants';
import { curves } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct CheckboxList {
  private groupName = 'checkboxGroup' + Math.random();
  // private time = 0;
  // private groupLock = false;

  @Require @Param options: CheckboxListItem[] = [];
  @Param value: Array<string | number> = [];
  @Param isVertical: boolean = false;

  @Event onChange: (vals: Array<string | number>, lastSelectValue: string | number) => void = (vals) => {};

  // @Computed
  // private get optionsMap() {
  //   const map: Record<string, CheckboxListItem> = {};
  //   this.options.reduce((data: Record<string, CheckboxListItem>, item: CheckboxListItem) => {
  //     data[item.value.toString()] = item;
  //     return data;
  //   }, map);
  //   return map;
  // }

  build() {
    List() {
      ForEach(this.options, (item: CheckboxListItem) => {
        ListItem() {
          Row({space: 4}) {
            Checkbox({name: item.value.toString(), group: this.groupName})
              .commonCheckboxStyle()
              .select(this.value.includes(item.value))
              .hitTestBehavior(HitTestMode.None)
            Text(item.label)
          }
          .height('auto')
          .onClick(() => {
            let newArr: Array<string | number> = this.value.slice();
            let selected = false;

            if (this.value.includes(item.value)) {
              newArr = [];
              selected = false;
              this.value.forEach((val) => {
                item.value !== val && newArr.push(val);
              })
            }
            else {
              selected = true;
              newArr.push(item.value)
            }

            if (item.intercept) {
              newArr = item.intercept(newArr, selected);
            }
            // console.log(`newArr: ${JSON.stringify(newArr)}`)
            this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
              this.onChange(newArr, item.value);
            })
          })
        }
      }, (item: CheckboxListItem) => item.value.toString())
    }
    .listDirection(this.isVertical ? Axis.Vertical : Axis.Horizontal)
    // .height(100)
    // .height(0)
    // .flexGrow(1)
    // .height('auto')
    // .width('auto')
  }

  /** 锁住，阻止List渲染时候导致CheckboxGroup触发change */
  // lockGroupTrigger() {
  //   this.groupLock = true;
  //   setTimeout(() => {
  //     this.groupLock = false;
  //   }, 16);
  // }

  /** 防抖触发 */
  // groupChange(arr: Array<string>) {
  //   clearTimeout(this.time);
  //   this.time = setTimeout(() => {
  //     const newArr: Array<string | number> = [];
  //
  //     arr.forEach((val) => {
  //       if (this.optionsMap[val]) {
  //         newArr.push(this.optionsMap[val].value)
  //       }
  //     });
  //
  //     // this.value = newArr;
  //     // console.log(`newArr: ${JSON.stringify(newArr)}`)
  //     this.lockGroupTrigger();
  //   }, 0)
  // }
}


@Extend(Checkbox)
function commonCheckboxStyle() {
  .shape(CheckBoxShape.ROUNDED_SQUARE)
  .selectedColor(CommonConstants.COLOR_SECONDARY)
}


interface CheckboxListItem {
  label?: string,
  value: string | number,
  intercept?: (vals: Array<string | number>, selected: boolean) => Array<string | number>;
}