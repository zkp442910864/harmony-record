import { DataSql } from '../sql/dataSql';
import { EnumRecordType, RecordDayTitleModel, RecordModel } from './types/base';

// @Observed
export class RecordClass {
  /** 当前年份 */
  currentYear = 0;
  /** 当前月份 */
  currentMonth = 0;
  /** 月份总收入 */
  monthInTotal = '0.00';
  /** 月份总支出 */
  monthOutTotal = '0.00';
  listData: Array<RecordModel<Date> | RecordDayTitleModel> = [];

  constructor() {
    // this.switchDate();
  }

  /** 时间切换 */
  switchDate() {
    const date = new Date();
    this.currentYear = date.getFullYear();
    this.currentMonth = date.getMonth() + 1;
    this.getData();
  }

  /** 获取数据 */
  async getData() {
    const resList = await DataSql.getInstance().queryRecordList(this.currentMonth, this.currentYear);
    const listData: Array<RecordModel<Date> | RecordDayTitleModel> = [];
    const map: Record<string, RecordDayTitleModel> = {};
    let monthInTotal = '0.00';
    let monthOutTotal = '0.00';

    resList.forEach((item) => {
      const dateFlag = `${item.recordDate!.getFullYear()}/${item.recordDate!.getMonth() + 1}/${item.recordDate!.getDate()}`;
      let titleItem = map[dateFlag];

      // 创建标题
      if (!titleItem) {
        titleItem = map[dateFlag] = {
          isTitle: true,
          date: `${item.recordDate!.getMonth() + 1}/${item.recordDate!.getDate()}`,
          inTotal: '0.00',
          outTotal: '0.00',
          customKey: dateFlag + Date.now(),
        };
        listData.push(titleItem);
      }

      item.value = Number(item.value).toFixed(2);
      if (item.valueType === EnumRecordType.OUT) {
        titleItem.outTotal = (Number(titleItem.outTotal) + Number(item.value)).toFixed(2);
        monthOutTotal = (Number(monthOutTotal) + Number(item.value)).toFixed(2);
      }
      else {
        titleItem.inTotal = (Number(titleItem.inTotal) + Number(item.value)).toFixed(2);
        monthInTotal = (Number(monthInTotal) + Number(item.value)).toFixed(2);
      }

      // 处理内容
      listData.push(item);
    })

    // console.log(`数量: ${listData.length}`)
    this.listData = listData;
    this.monthInTotal = monthInTotal;
    this.monthOutTotal = monthOutTotal;
  }

}
