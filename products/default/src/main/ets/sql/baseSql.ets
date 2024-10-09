import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@ohos.base';
import { DateUtils } from '../utils/dateUtils';
import { BaseSqlSentence } from '../viewmodel/baseSqlSentence';
import { RecordTypeModel, EnumRecordType } from '../viewmodel/types/base';
import { DataSql } from './dataSql';

let sqlObj: BaseSql;

class BaseSql {
  store?: relationalStore.RdbStore;
  BACKUP_NAME = 'back_dataDb.db';
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'dataDb.db',
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
    encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
    // customDir: 'customDir/subCustomDir', // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
    isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
  };

  /** 获取 数据库实例 */
  get rdbStore() {
    return this.store!;
  }

  async init(context: Context) {
    // await this.deleteDb(context)
    return new Promise<void>((rel, rej) => {
      relationalStore.getRdbStore(context, this.STORE_CONFIG, async (err, rdbStore) => {
        if (err) {
          console.error(`Sql： 获取 RdbStore 失败, code: ${err.code},message: ${err.message}`);
          rej(err);
          return;
        }

        console.info('Sql: 成功获取 RdbStore');
        this.store = rdbStore;

        await this.initTable();
        await this.initRecordTypeData();
        rel();
      })
    })
  }

  async initTable() {
    if (this.store!.version > 0) return;
    try {
      await Promise.all([
        this.store!.executeSql(BaseSqlSentence.RECORD_LIST_TABLE_SQL),
        this.store!.executeSql(BaseSqlSentence.RECORD_TYPE_LIST_TABLE_SQL),
        this.store!.executeSql(BaseSqlSentence.WALLET_TABLE_SQL),
      ]);
      console.info('Sql: 表创建成功');
      this.store!.version = ++this.store!.version;
    } catch (err) {
      console.error(`Sql： 表创建失败, code: ${err.code},message: ${err.message}`);
    }
  }

  /** 重新启动 */
  async resetStart(context: Context) {
    await this.store!.close();
    this.store = undefined;
    await this.init(context);
  }

  async test() {
    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, SALARY REAL, CODES BLOB, IDENTITY UNLIMITED INT)';
    try {
      await this.store!.executeSql(SQL_CREATE_TABLE);
      const valueBucket1: relationalStore.ValuesBucket = {
        'NAME': 'value1',
        'AGE': 18,
        'SALARY': 18,
        'CODES': new Uint8Array([1, 2, 3, 4, 5]),
        'IDENTITY': BigInt('15822401018187971961171'),
      };
      await this.store!.insert('EMPLOYEE', valueBucket1);
      // await this.store!.insert('EMPLOYEE', valueBucket1);
      // await this.store!.insert('EMPLOYEE', valueBucket1);

      let predicates2 = new relationalStore.RdbPredicates('EMPLOYEE');
      // predicates2.equalTo('NAME', 'Rose');
      const resultSet = await this.store!.query(predicates2, ['ID', 'NAME', 'AGE', 'SALARY', 'IDENTITY']);

      // console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      // while (resultSet.goToNextRow()) {
      //   const id = resultSet.getLong(resultSet.getColumnIndex("ID"));
      //   const name = resultSet.getString(resultSet.getColumnIndex("NAME"));
      //   const age = resultSet.getLong(resultSet.getColumnIndex("AGE"));
      //   const salary = resultSet.getDouble(resultSet.getColumnIndex("SALARY"));
      //   console.info(`id=${id}, name=${name}, age=${age}, salary=${salary}`);
      // }
      console.info(`Sql: 测试成功.${resultSet.rowCount}`);
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
      this.store!.close()
    } catch (err) {
      console.error(`Sql: 测试失败, code: ${err.code},message: ${err.message}`);
    }
  }


  /** 初始化 recordType 数据 */
  async initRecordTypeData() {
    if (this.store!.version > 1) return;

    try {
      const createDate = DateUtils.toUTCTime(new Date());
      const data: RecordTypeModel<number>[] = [
        {
          recordName: '工资',
          recordType: EnumRecordType.IN,
          createDate,
          isDelete: 0,
          sort: 0,
        },
        {
          recordName: '用餐',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 0,
        },
        {
          recordName: '购物',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 1,
        },
        {
          recordName: '借出',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 2,
        },
        {
          recordName: '交通',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 3,
        },
        {
          recordName: '家用',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 4,
        },
        {
          recordName: '其他',
          recordType: EnumRecordType.OUT,
          createDate,
          isDelete: 0,
          sort: 5,
        },
      ];
      await Promise.all(
        data.map(async (item) => {
          return this.store!.insert(BaseSqlSentence.RECORD_TYPE_LIST_TABLE_NAME, item as relationalStore.ValuesBucket);
        })
      )
      console.info('Sql: 初始化RecordType数据成功');
      this.store!.version = ++this.store!.version;
    } catch (err) {
      console.error(`Sql： 初始化RecordType数据失败, code: ${err.code},message: ${err.message}`);
    }
  }

  /** 备份 */
  backup() {
    this.store!.backup(this.BACKUP_NAME, (err: BusinessError) => {
      if (err) {
        console.error(`Sql: 备份数据库失败. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('Sql: 备份数据库成功.');
    })
  }

  /** 删库 */
  deleteDb(context: Context) {
    return new Promise<void>((rel, rej) => {
      relationalStore.deleteRdbStore(context, this.STORE_CONFIG.name, (err: BusinessError) => {
        if (err) {
          console.error(`Sql: 删除数据库失败, code: ${err.code},message: ${err.message}`);
          rej();
          return;
        }
        console.info('Sql: 删除数据库成功.');
        rel();
      })
    })
  }
}


export const initSqlObj = (context: Context) => {
  if (sqlObj) {
    return sqlObj;
  }
  sqlObj = new BaseSql();
  sqlObj.init(context).then(async () => {
    // xxx
  })
  return sqlObj;
}

export const getSqlObj = () => {
  return sqlObj!;
}
