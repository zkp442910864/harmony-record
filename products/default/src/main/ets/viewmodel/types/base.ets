import { relationalStore } from '@kit.ArkData';

/** 记录 模型 */
export interface RecordModel<T extends number | Date = number> {
  /** 自增id */
  id?: number;
  /** 记录类型: RecordModel.id */
  recordTypeId?: number;
  recordTypeName?: string;
  /** 数值类型: 1收入 2支出 */
  valueType?: EnumRecordType;
  /** 数值 */
  value?: string;
  /** 创建时间 */
  createDate?: T;
  /** 手动时间 */
  recordDate?: T;
  /** 备注 */
  remarks?: string;
}

/** 记录每天标题 模型 */
export interface RecordDayTitleModel {
  /** 是否标题 */
  isTitle: boolean;
  /** 日期 */
  date: string;
  /** 当天收入 */
  inTotal: string;
  /** 当天支出 */
  outTotal: string;
  /** 自定义key */
  customKey: string;
  children?: RecordModel<Date>[];
}

/** 记录类型 模型 */
export interface RecordTypeModel<T extends number | Date = number> {
  /** 自增id */
  id?: number;
  /** 类型名称 */
  recordName?: string;
  /** 类型: 1收入 2支出 3两边都支持 */
  recordType?: EnumRecordType;
  /** 时间 */
  createDate?: T;
  /** 是否删除 0否 1是 */
  isDelete?: number;
  /** 排序 */
  sort?: number;
}

/** 记录类型 统计模型 */
export interface RecordTypeStatisticsModel {
  recordTypeId?: number;
  /** 类型名称 */
  recordName?: string;
  /** 记录类型 */
  valueType?: EnumRecordType;
  /** 类型统计 */
  total?: string;
  /** 占用百分比 */
  pre?: string;
  /** 是否删除 0否 1是 */
  isDelete?: number;
}

/** 钱包类型 */
export interface WalletModel<T extends number | Date = number> {
  /** 自增id */
  id?: number;
  /** 值 */
  value?: string;
  /** 时间 */
  createDate?: T;
}

/** 类型: IN收入 OUT支出 */
export enum EnumRecordType {
  IN = 1,
  OUT = 2,
  ALL = 3
}

/** 统计每项数据 */
export interface StatisticsItem {
  month: string;
  total: number;
}

/** 统计数据 */
export interface StatisticsData {
  inList: Array<StatisticsItem | null>;
  outList: Array<StatisticsItem | null>;
}

/** router_map.json data类型定义 */
export interface IRouterMapData {
  title: string;
}

/** 解析的xml模型 */
export interface IXmlData {
  children?: IXmlData[];
  name: string;
  type: string;
  value?: string;
}

/** xml根模型 */
export interface IXmlRoot {
  children: IXmlData[];
}

/** 转换的数据模型 */
export interface ICloudListData {
  value?: string;
  date?: Date;
  dateStr?: string;
  isCollection?: boolean;
  children?: ICloudListData[]
}

