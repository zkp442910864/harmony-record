import { CommonConstants } from '../../../constants/CommonConstants'
import { McBarChart, Options } from '@mcui/mccharts'

// @Entry
// @Preview
@Component
export struct Statistics {
  @Consume('pageStack') pageStack?: NavPathStack;
  defOption: Options = new Options({
    color: [CommonConstants.COLOR_TEXT_OUT, CommonConstants.COLOR_TEXT_IN],
    legend: {
      // show: false,
      top: '0%',
      left: '84%'
    },
    xAxis:{
      data:[
        '1月', '2月', '3月', '4月', '5月', '6月',
        '7月', '8月', '9月', '10月', '11月', '12月'
      ],
      // axisTick: {
      //   show: false,
      // },
      axisLine: {
        show: false,
      },
    },
    yAxis:{
      // name:'￥'
      axisLine: {
        show: false,
      },
      // axisTick: {
      //   show: false,
      // },
      splitLine: {
        show: false
      }
    },
    series:[
      {
        name:'支出',
        data:[11, 11, 15, 13, 12, 130, 10, 11, 11, 15, 13, 12, 130]
      },
      {
        name:'收入',
        data:[11, 11, 15, 13, 12, 130, 10, 11, 11, 15, 13, 12, 130]
      }
    ],
    dataZoom: {
      show: true,
      start: 5,
      end: 11,
    }
  })

  build() {
    Column() {
      Column() {
        Row() {
          Text('2024年')
          // Text('9月')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left: 16, right: 16, top: 16})

        McBarChart({
          options: this.defOption
        })
          .margin({top: -14})
          .height(200)
          .padding({left: 16, right: 16})
      }
      // .padding(16)
      .margin(16)
      .borderRadius(16)
      .backgroundColor(CommonConstants.COLOR_OTHER1)

      Column() {
        Stack() {
          Tabs() {
            TabContent() {
              this.bottomContent()
            }
            .tabBar('支出')

            TabContent() {
              this.bottomContent()
            }
            .tabBar('收入')
          }
          .scrollable(false)

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
      }
      .flexGrow(1)
      .height(0)
      .margin({left: 16, right: 16, bottom: 16})
      .borderRadius(16)
      .backgroundColor(CommonConstants.COLOR_OTHER1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
  }

  linkAdd() {
    this.pageStack?.pushPathByName('AddRecordType', '');
  }

  @Builder
  bottomContent() {
    List() {
      ListItem() {
        Row() {
          Text('类型')
          Text('0.00')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
      }

      ListItem() {
        Row() {
          Text('类型')

          Text('0.00')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 0.5, startMargin: 60, endMargin: 60, color: '#22666666' })
  }
}
