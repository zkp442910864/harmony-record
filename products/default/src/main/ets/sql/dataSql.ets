import { relationalStore } from '@kit.ArkData';
import { DateUtils } from '../utils/dateUtils';
import { BaseSqlSentence } from '../viewmodel/baseSqlSentence';
import {
  EnumRecordType,
  RecordModel,
  RecordTypeModel,
  StatisticsData,
  WalletModel,
  StatisticsItem,
  RecordTypeStatisticsModel
} from '../viewmodel/types/base';
import { getSqlObj } from './baseSql';
import { BusinessError } from '@ohos.base';

export class DataSql {
  private static dataSql?: DataSql;

  static getInstance() {
    if (!DataSql.dataSql) {
      DataSql.dataSql = new DataSql();
    }

    return DataSql.dataSql;
  }

  static destroyInstance() {
    DataSql.dataSql = undefined;
  }

  sqlObj = getSqlObj();
  store: relationalStore.RdbStore = this.sqlObj.rdbStore;

  private constructor() {
  }

  /** 删除记录数据 */
  deleteRecordItem() {
  }

  /** 查询记录列表 */
  async queryRecordList(start: Date, end: Date) {
    let list: RecordModel<Date>[] = [];

    try {
      // const data = DateUtils.getMonthRang(month, year);
      const resultSet = await this.store.querySql(`
        SELECT recordList.id, recordList.recordTypeId, recordTypeList.recordName as recordTypeName, recordList.valueType, recordList.value, recordList.recordDate, recordList.remarks
        FROM recordList
        LEFT JOIN recordTypeList ON recordList.recordTypeId = recordTypeList.id
        WHERE recordList.recordDate >= ${DateUtils.toUTCTime(start)} AND recordList.recordDate <= ${DateUtils.toUTCTime(end)}
        ORDER BY recordList.recordDate DESC
      `);

      list = this.convertorRecordData(resultSet);

      resultSet.close();
    } catch (err) {
      console.error(`查询记录列表失败: queryRecordList, code: ${err.code}, message: ${err.message}`);
    }

    return list;
  }

  /** 记录数据 结构转换 */
  private convertorRecordData(resultSet: relationalStore.ResultSet, hasRecordTypeName = true) {
    const list: RecordModel<Date>[] = [];

    while (resultSet.goToNextRow()) {
      const data: RecordModel<Date> = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        recordTypeId: resultSet.getLong(resultSet.getColumnIndex('recordTypeId')),
        recordTypeName: hasRecordTypeName ? resultSet.getString(resultSet.getColumnIndex('recordTypeName')) : undefined,
        valueType: resultSet.getLong(resultSet.getColumnIndex('valueType')),
        value: resultSet.getString(resultSet.getColumnIndex('value')),
        recordDate: DateUtils.toLocalDate(resultSet.getLong(resultSet.getColumnIndex('recordDate'))),
        remarks: resultSet.getString(resultSet.getColumnIndex('remarks')),
      };
      list.push(data);
    }

    return list;
  }

  /** 指定查询一条数据 */
  async queryAssignRecordItem(id: number) {
    let item: RecordModel<Date> | undefined = undefined;
    try {
      const data = new relationalStore.RdbPredicates(BaseSqlSentence.RECORD_LIST_TABLE_NAME);
      data.equalTo('id', id);
      const resultSet = await this.store.query(data);
      item = this.convertorRecordData(resultSet, false)[0];
      resultSet.close();
    } catch (err) {
      console.error(`指定查询一条数据 失败: queryStatisticsData, code: ${err.code}, message: ${err.message}`);
    }
    return item;
  }

  /** 按记录 查询 支出/收入 统计 */
  async queryStatisticsData(type: 'year' | 'month' | 'date', start: Date, end: Date) {
    const count = DateUtils.getTwoDateRang(type, start, end);
    const resultData: StatisticsData = {
      inList: new Array(count).fill(null),
      outList: new Array(count).fill(null),
    };
    try {
      const format = type === 'year'
        ? "'%Y'"
        : (type === 'month' ? "'%Y/%m'" : "'%Y/%m/%d'");
      // const dateWhere = type === 'year'
      //     ? `month >= '${yearVal}/01' AND month < '${yearVal + 1}/01'`
      //     : `month >= '${yearVal}/${`${monthVal}`.padStart(2, '0')}' AND month < '${yearVal}/${`${monthVal + 1}`.padStart(2, '0')}'`;

      const resultSet = await this.store.querySql(`
        SELECT strftime(${format}, recordList.recordDate / 1000, 'unixepoch', 'utc') AS month,
          recordList.recordDate,
          recordList.valueType,
          SUM(recordList.value) AS total
        FROM recordList
        WHERE recordList.recordDate >= ${DateUtils.toUTCTime(start)} AND recordList.recordDate <= ${DateUtils.toUTCTime(end)}
        GROUP BY month,
                recordList.valueType
      `);
      while (resultSet.goToNextRow()) {
        const valueType = resultSet.getLong(resultSet.getColumnIndex('valueType'));
        const date = new Date(resultSet.getString(resultSet.getColumnIndex('month')));
        const data: StatisticsItem = {
          month: resultSet.getString(resultSet.getColumnIndex('month')),
          total: resultSet.getLong(resultSet.getColumnIndex('total')),
        };

        if (valueType === EnumRecordType.IN) {
          resultData.inList[date.getMonth()] = data;
        } else {
          resultData.outList[date.getMonth()] = data;
        }
      }

      resultSet.close();
    } catch (err) {
      console.error(`按记录 查询 支出/收入 统计失败: queryStatisticsData, code: ${err.code}, message: ${err.message}`);
    }

    return resultData;
  }

  /** 插入记录数据 */
  async insertRecordItem(data: RecordModel<Date>) {
    const params: RecordModel<number> = JSON.parse(JSON.stringify(data));
    if (!data.id) {
      params.createDate = DateUtils.toUTCTime(Date.now());
    }
    if (data.recordDate) {
      params.recordDate = DateUtils.toUTCTime(data.recordDate);
    }
    await this.store.insert(BaseSqlSentence.RECORD_LIST_TABLE_NAME, params as relationalStore.ValuesBucket)
      .catch((err: BusinessError) => {
        console.error(`插入记录数据失败: insertRecordItem, code: ${err.code}, message: ${err.message}`);
        return Promise.reject(err);
      });
    this.updateWalletData(params.valueType === EnumRecordType.IN ? 'in' : 'out', params.value!);
  }

  /** 更新记录数据 */
  async updateRecordItem(data: RecordModel<Date>) {
    let params: RecordModel<number> = JSON.parse(JSON.stringify(data));
    params.recordTypeName = undefined;
    params = JSON.parse(JSON.stringify(params));

    if (data.createDate) {
      params.createDate = DateUtils.toUTCTime(data.createDate);
    }

    if (data.recordDate) {
      params.recordDate = DateUtils.toUTCTime(data.recordDate);
    }

    await this.recoverWallet(data.id!);
    const predicates = new relationalStore.RdbPredicates(BaseSqlSentence.RECORD_LIST_TABLE_NAME);
    predicates.equalTo('id', data.id!);
    await this.store.update(params as relationalStore.ValuesBucket, predicates)
      .catch((err: BusinessError) => {
        console.error(`更新记录数据失败: insertRecordItem, code: ${err.code}, message: ${err.message}`);
        return Promise.reject(err);
      })
    await this.updateWalletData(params.valueType === EnumRecordType.IN ? 'in' : 'out', params.value!);
  }

  /** 查询分类列表 */
  async queryRecordTypeList() {
    const list: RecordTypeModel[] = [];

    try {
      const data = new relationalStore.RdbPredicates(BaseSqlSentence.RECORD_TYPE_LIST_TABLE_NAME);
      data.orderByAsc('sort');
      data.orderByAsc('id');
      data.equalTo('isDelete', 0)

      const resultSet = await this.store.query(data, ['id', 'recordName', 'recordType', 'sort']);
      while (resultSet.goToNextRow()) {
        const data: RecordTypeModel = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          recordName: resultSet.getString(resultSet.getColumnIndex('recordName')),
          recordType: resultSet.getLong(resultSet.getColumnIndex('recordType')),
          // createDate: 0,
          // isDelete: 0,
          sort: resultSet.getLong(resultSet.getColumnIndex('sort')),
        };
        list.push(data);
      }
      resultSet.close();

    } catch (err) {
      console.error(`查询分类列表失败: queryRecordTypeList, code: ${err.code}, message: ${err.message}`);
    }

    return list;
  }

  /** 分类统计 */
  async queryRecordTypeStatisticsData(start: Date, end: Date) {
    const list: RecordTypeStatisticsModel[] = [];
    try {
      const startTime = DateUtils.toUTCTime(start);
      const endTime = DateUtils.toUTCTime(end);
      const resultSet = await this.store.querySql(`
        SELECT recordList.recordTypeId,
          recordTypeList.recordName AS recordName,
          recordList.valueType,
          round(SUM(recordList.value), 2) AS total,
          round(CAST (SUM(recordList.value) AS REAL) / (
            SELECT SUM(inRecordList.value) AS total
            FROM recordList AS inRecordList
            WHERE inRecordList.recordDate >= ${startTime} AND
              inRecordList.recordDate <= ${endTime} AND
              inRecordList.valueType == recordList.valueType
          ) * 100, 2) AS pre,
          recordTypeList.isDelete
        FROM recordList
        LEFT JOIN recordTypeList ON recordList.recordTypeId = recordTypeList.id
        WHERE recordList.recordDate >= ${startTime} AND
              recordList.recordDate <= ${endTime}
        GROUP BY recordList.recordTypeId,
                recordList.valueType
        ORDER BY total DESC,
                recordList.recordTypeId ASC;
      `);

      while (resultSet.goToNextRow()) {
        const data: RecordTypeStatisticsModel = {
          recordTypeId: resultSet.getLong(resultSet.getColumnIndex('recordTypeId')),
          recordName: resultSet.getString(resultSet.getColumnIndex('recordName')),
          valueType: resultSet.getLong(resultSet.getColumnIndex('valueType')),
          total: resultSet.getString(resultSet.getColumnIndex('total')),
          pre: resultSet.getString(resultSet.getColumnIndex('pre')),
          isDelete: resultSet.getLong(resultSet.getColumnIndex('isDelete')),
        };
        list.push(data);
      }

      resultSet.close();
    } catch (err) {
      console.error(`分类统计失败: queryRecordTypeStatisticsData, code: ${err.code}, message: ${err.message}`);
    }

    return list;
  }

  /** 分类添加 */
  async insertRecordTypeItem(data: RecordTypeModel<number>) {
    try {
      data.createDate = DateUtils.toUTCTime(new Date());
      data.sort = 999_999;
      await this.store.insert(BaseSqlSentence.RECORD_TYPE_LIST_TABLE_NAME, data as relationalStore.ValuesBucket);
    } catch (err) {
      console.error(`分类添加失败: insertRecordTypeItem, code: ${err.code}, message: ${err.message}`);
    }
  }

  /** 移除一条记录后，钱包金额恢复 */
  async recoverWallet(id: number) {
    const oldData = await this.queryAssignRecordItem(id);
    if (oldData) {
      await this.updateWalletData(oldData.valueType === EnumRecordType.IN ? 'out' : 'in', oldData.value!).catch((err: BusinessError) => {
        console.error(`移除一条记录后，钱包金额恢复 失败: queryLastWalletItem, code: ${err.code}, message: ${err.message}`);
        return Promise.reject(err);
      })
    }
  }

  /** 查询钱包最后一条记录 */
  async queryLastWalletItem() {
    let value = '0.00';

    try {
      const data = new relationalStore.RdbPredicates(BaseSqlSentence.WALLET_TABLE_NAME);
      data.orderByDesc('id');
      data.limitAs(1);

      const resultSet = await this.store.query(data);

      if (resultSet.rowCount) {
        resultSet.goToFirstRow();
        value = resultSet.getString(resultSet.getColumnIndex('value'));
      }

      resultSet.close();
    } catch (err) {
      console.error(`查询钱包最后一条记录失败: queryLastWalletItem, code: ${err.code}, message: ${err.message}`);
    }

    return value;
  }

  /** 插入钱包记录 */
  async insertWalletItem(value: string) {
    try {
      const data: WalletModel<number> = {
        value,
        createDate: DateUtils.toUTCTime(Date.now()),
      }
      await this.store.insert(BaseSqlSentence.WALLET_TABLE_NAME, data as relationalStore.ValuesBucket);
    } catch (err) {
      console.error(`插入钱包记录失败: insertWalletItem, code: ${err.code}, message: ${err.message}`);
    }
  }

  /** 更新钱包记录 */
  async updateWalletData(type: 'in' | 'out' | 'overlay', value: string) {
    try {
      let lastValue = await this.queryLastWalletItem();
      if (type === 'in') {
        lastValue = `${Number(lastValue) + Number(value)}`;
      } else if (type === 'out') {
        lastValue = `${Number(lastValue) - Number(value)}`;
      } else {
        lastValue = value;
      }
      await this.insertWalletItem(lastValue);

      return lastValue;
    } catch (err) {
      console.error(`更新钱包记录失败: updateWalletData, code: ${err.code}, message: ${err.message}`);
    }
    return '0.00';
  }
}


