import { DataSql } from '../sql/dataSql';
import { EnumRecordType, RecordTypeModel } from './types/base';

@ObservedV2
export class RecordType {
  @Trace inTypeArr: RecordTypeModel[] = [];
  @Trace outTypeArr: RecordTypeModel[] = [];

  constructor() {}

  /** 获取数据数据 */
  async getRecordTypeDataDb() {
    const list = await DataSql.getInstance().queryRecordTypeList()
    this.inTypeArr = list.filter(ii => [EnumRecordType.IN, EnumRecordType.ALL].includes(ii.recordType!));
    this.outTypeArr = list.filter(ii => [EnumRecordType.OUT, EnumRecordType.ALL].includes(ii.recordType!));
  }
}

export interface CacheData {
  outRecordTypeId?: number;
  inRecordTypeId?: number
}

