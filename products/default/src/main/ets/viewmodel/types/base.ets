
/** 基础数据类型 */
export interface ItemDataModel {
  /** 自增id */
  id?: number;
  /** 记录类型: RecordModel.id */
  recordTypeId: number;
  /** 数值类型: 1收入 2支出 */
  valueType: EnumRecordType;
  /** 数值 */
  value: string;
  /** 时间 */
  date?: Date;
  /** 手动时间 */
  recordDate?: Date;
  /** 备注 */
  remarks?: string;
}

/** 记录类型 */
export interface RecordTypeModel {
  /** 自增id */
  id: number;
  /** 类型名称 */
  recordName: string;
  /** 类型: 1收入 2支出 3两边都支持 */
  recordType: EnumRecordType;
  /** 时间 */
  date: Date;
}

/** 钱包类型 */
export interface WalletModel {
  /** 自增id */
  id: number;
  /** 值 */
  value: string;
  /** 时间 */
  date: Date;
}

/** 类型: IN收入 OUT支出 */
export enum EnumRecordType {
  IN = 1,
  OUT = 2,
  ALL = 3
}