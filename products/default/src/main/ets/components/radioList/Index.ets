import { requestAnimationFramePolyfill } from '@mcui/mccharts/src/main/ets/utils';
import { CommonConstants } from '../../constants/CommonConstants';
import { curves } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct RadioList {
  private groupName = 'checkboxGroup' + Math.random();
  // private time = 0;
  // private groupLock = false;

  @Require @Param options: RadioListItem[] = [];
  @Param value?: string | number = undefined;
  @Param isVertical: boolean = false;

  @Event onChange: (val: string | number) => void = (val) => {};


  build() {
    List() {
      ForEach(this.options, (item: RadioListItem) => {
        ListItem() {
          Row({space: 4}) {
            Radio({value: item.value.toString(), group: this.groupName})
              .commonRadioStyle()
              .checked(this.value === item.value)
              .hitTestBehavior(HitTestMode.None)
            Text(item.label)
          }
          .height('auto')
          .onClick(() => {
            this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
              this.onChange(item.value);
            })
          })
        }
      }, (item: RadioListItem) => item.value.toString())
    }
    .listDirection(this.isVertical ? Axis.Vertical : Axis.Horizontal)

  }
}

@Extend(Radio)
function commonRadioStyle() {
  .radioStyle({
    checkedBackgroundColor: CommonConstants.COLOR_MAIN,
  })
}


interface RadioListItem {
  label?: string,
  value: string | number,
}