import { EnumRecordType, RecordTypeModel } from './base';

export class RecordType {
  inTypeArr: RecordTypeModel[] = [];
  outTypeArr: RecordTypeModel[] = [];

  constructor() {
    this.getRecordTypeDataDb();
  }

  /** 获取数据数据 */
  getRecordTypeDataDb() {
    this.inTypeArr = [
      {
        id: 0,
        recordName: '工资',
        recordType: EnumRecordType.IN,
        date: new Date('2024/9/23'),
      }
    ];

    this.outTypeArr = [
      {
        id: 1,
        recordName: '购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 2,
        recordName: '购物购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 3,
        recordName: '购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 4,
        recordName: '购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 5,
        recordName: '购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 6,
        recordName: '购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      },
      {
        id: 7,
        recordName: '购物购物购物',
        recordType: EnumRecordType.OUT,
        date: new Date('2024/9/23'),
      }
    ]
  }
}

export interface CacheData {
  outRecordTypeId?: number;
  inRecordTypeId?: number
}

