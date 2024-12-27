import { CommonConstants } from '../../../constants/CommonConstants'
import { McBarChart, Options } from '@mcui/mccharts'
import { DataSql } from '../../../sql/dataSql';
import { DateUtils } from '../../../utils';
import { EnumRecordType, RecordModel, RecordTypeStatisticsModel } from '../../../viewmodel/types/base';
import { curves } from '@kit.ArkUI';
import { ITransitionParam } from '../../../routerTransition';

// @Entry
// @Preview
@Component
export struct Statistics {
  @Prop @Watch('onCustomPageShow') pageShow: boolean = false;
  @Consume('pageStack') pageStack?: NavPathStack;
  @State dateType: 'year' | 'month' = 'year';
  @State currentYear: number = new Date().getFullYear();
  @State chartOption: Options | null = null;
  @State statisticsList: RecordTypeStatisticsModel[] = [];
  @State selectIndex: number = 0;

  aboutToAppear(): void {
    this.onCustomPageShow();
  }

  onCustomPageShow() {
    if (this.pageShow) {
      console.log('Statistics 显示')
      this.getChartData();
      this.getRecordTypeStatisticsData();
    }
  }

  async getChartData() {
    const data = await DataSql.getInstance().queryStatisticsData(
      'month',
      DateUtils.getStartDate('year', new Date(this.currentYear.toString())),
      DateUtils.getEndDate('year', new Date(this.currentYear.toString()))
    );
    const offset = this.currentYear === new Date().getFullYear() ? new Date().getMonth() + 1 : undefined;
    this.chartOption = new Options({
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
        ].slice(0, offset),
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
          data: data.outList.map((item) => item?.total ?? 0).slice(0, offset)
        },
        {
          name:'收入',
          data: data.inList.map((item) => item?.total ?? 0).slice(0, offset)
        }
      ],
      dataZoom: {
        show: true,
        start: 5,
        end: 11,
      }
    });
  }

  async getRecordTypeStatisticsData() {
    const list = await DataSql.getInstance().queryRecordTypeStatisticsData(
      DateUtils.getStartDate('year', new Date(this.currentYear.toString())),
      DateUtils.getEndDate('year', new Date(this.currentYear.toString()))
    );
    this.statisticsList = list;
  }

  linkAdd(e: ClickEvent) {
    const data: ITransitionParam<RecordModel<Date>> = {
      x: e.windowX - e.x,
      y: e.windowY - e.y,
      targetWidth: e.target.area.width,
      targetHeight: e.target.area.height,
      // data: item,
    };
    this.pageStack?.pushPathByName('AddRecordType', data, (popInfo) => {
      if (popInfo.result === 'addSuccess') {
        this.getRecordTypeStatisticsData();
      }
    }, false);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text(`${this.currentYear}年`)
          // Text('9月')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left: 16, right: 16, top: 16})

        if (this.chartOption) {
          McBarChart({
            options: this.chartOption
          })
            .margin({top: -14})
            .height(200)
            .padding({left: 16, right: 16})
        }
        else {
          Blank()
            .margin({top: -14})
            .height(200)
            .padding({left: 16, right: 16})
        }
      }
      // .padding(16)
      .margin(16)
      .borderRadius(16)
      .backgroundColor(CommonConstants.COLOR_OTHER1)

      Column() {
        Stack() {
          Tabs() {
            TabContent() {
              this.bottomContent(EnumRecordType.OUT)
            }
            .tabBar(this.tabStyle('支出', 0))

            TabContent() {
              this.bottomContent(EnumRecordType.IN)
            }
            .tabBar(this.tabStyle('收入', 1))
          }
          .scrollable(false)
          .barHeight(40)
          .onChange((val) => {
            this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
              this.selectIndex = val;
            })
          })

          Button() {
            Text('+')
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
          }
            .type(ButtonType.Circle)
            .backgroundColor(CommonConstants.COLOR_MAIN)
            // .opacity(.5)
            .width(50)
            .height(50)
            .shadow(CommonConstants.BOX_SHADOW)
            .position({right: 10, bottom: 30})
            .onClick((e) => this.linkAdd(e))
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

  @Builder
  tabStyle(text: string, value: number) {
    Column() {
      Text(text)
        .fontColor(this.selectIndex === value ? CommonConstants.COLOR_MAIN : Color.Gray)
      Blank()
        .width(18)
        .height(2)
        .backgroundColor(this.selectIndex === value ? CommonConstants.COLOR_MAIN : Color.Transparent)
        .margin({top: 4})
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  bottomContent(type: EnumRecordType) {
    List() {
      ForEach(this.statisticsList, (item: RecordTypeStatisticsModel) => {
        if (item.valueType === type)
        ListItem() {
          Row() {
            Text(item.recordName)
            if (item.isDelete) {
              Text('已删除')
                .fontColor(CommonConstants.COLOR_TEXT_OUT)
                .fontSize(14)
                .flexGrow(1)
            }
            Text(Number(item.total).toFixed(2))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
        }
      }, (ii: RecordTypeStatisticsModel) => ii.recordTypeId!.toString())
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 0.5, startMargin: 60, endMargin: 60, color: '#22666666' })
  }
}
