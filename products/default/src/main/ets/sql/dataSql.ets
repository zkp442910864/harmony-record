import { relationalStore } from '@kit.ArkData';
import { DateUtils } from '../utils/dateUtils';
import { BaseSqlSentence } from '../viewmodel/baseSqlSentence';
import { EnumRecordType, RecordModel, RecordTypeModel } from '../viewmodel/types/base';
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

  sqlObj = getSqlObj();
  store: relationalStore.RdbStore = this.sqlObj.rdbStore;

  private constructor() {}

  /** 查询记录列表 */
  async queryRecordList(month?: number, year?: number) {
    const list: RecordModel<Date>[] = [];

    try {
      const data = DateUtils.getMonthRang(month, year);
      const resultSet = await this.store.querySql(`
        SELECT recordList.id, recordList.recordTypeId, recordTypeList.recordName as recordTypeName, recordList.valueType, recordList.value, recordList.recordDate, recordList.remarks
        FROM recordList
        LEFT JOIN recordTypeList ON recordTypeId = recordTypeList.id
        WHERE recordList.recordDate >= ${data[0]} AND recordList.recordDate <= ${data[1]}
        ORDER BY recordList.recordDate DESC
      `);

      while (resultSet.goToNextRow()) {
        const data: RecordModel<Date> = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          recordTypeId: resultSet.getLong(resultSet.getColumnIndex('recordTypeId')),
          recordTypeName: resultSet.getString(resultSet.getColumnIndex('recordTypeName')),
          valueType: resultSet.getLong(resultSet.getColumnIndex('valueType')),
          value: resultSet.getString(resultSet.getColumnIndex('value')),
          recordDate: DateUtils.toLocalDate(resultSet.getLong(resultSet.getColumnIndex('recordDate'))),
          remarks: resultSet.getString(resultSet.getColumnIndex('remarks')),
        };
        list.push(data);
      }
    } catch (err) {
      console.error(`查询记录列表失败: queryRecordList, code: ${err.code}, message: ${err.message}`);
    }

    return list;
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
    await this.store.insert(BaseSqlSentence.RECORD_LIST_TABLE_NAME, params as relationalStore.ValuesBucket).catch((err: BusinessError) => {
      console.error(`插入记录数据失败: insertRecordItem, code: ${err.code}, message: ${err.message}`);
      return Promise.reject(err);
    })
  }

  /** 查询分类列表 */
  async queryRecordTypeList() {
    const list: RecordTypeModel[] = [];

    try {
      const data = new relationalStore.RdbPredicates(BaseSqlSentence.RECORD_TYPE_LIST_TABLE_NAME);
      data.orderByAsc('sort');
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
    } catch (err) {
      console.error(`查询分类列表失败: queryRecordTypeList, code: ${err.code}, message: ${err.message}`);
    }

    return list;
  }

}


