import { DataSql } from '../sql/dataSql';
import { EnumRecordType, RecordTypeModel } from './types/base';

export class RecordType {
  inTypeArr: RecordTypeModel[] = [];
  outTypeArr: RecordTypeModel[] = [];

  constructor() {}

  /** 获取数据数据 */
  async getRecordTypeDataDb() {
    const list = await DataSql.getInstance().queryRecordTypeList()
    this.inTypeArr = list.filter(ii => ii.recordType === EnumRecordType.IN);
    this.outTypeArr = list.filter(ii => ii.recordType === EnumRecordType.OUT);
  }
}

export interface CacheData {
  outRecordTypeId?: number;
  inRecordTypeId?: number
}

