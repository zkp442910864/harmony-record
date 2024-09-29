
export class BaseSqlSentence {
  static RECORD_LIST_TABLE_NAME = 'recordList';
  static RECORD_TYPE_LIST_TABLE_NAME = 'recordTypeList';
  static WALLET_TABLE_NAME = 'wallet';

  static RECORD_LIST_TABLE_SQL = `
    CREATE TABLE IF NOT EXISTS "${BaseSqlSentence.RECORD_LIST_TABLE_NAME}" (
      "id"	INTEGER NOT NULL UNIQUE,
      "recordTypeId"	INTEGER NOT NULL,
      "valueType"	INTEGER NOT NULL DEFAULT 1,
      "value"	TEXT NOT NULL,
      "createDate"	INTEGER NOT NULL,
      "recordDate"	INTEGER,
      "remarks"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  `;

  static RECORD_TYPE_LIST_TABLE_SQL = `
    CREATE TABLE "${BaseSqlSentence.RECORD_TYPE_LIST_TABLE_NAME}" (
      "id"	INTEGER NOT NULL UNIQUE,
      "recordName"	TEXT NOT NULL,
      "recordType"	INTEGER NOT NULL,
      "createDate"	INTEGER NOT NULL,
      "isDelete"	INTEGER NOT NULL DEFAULT 0,
      "sort"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  `;

  static WALLET_TABLE_SQL = `
    CREATE TABLE "${BaseSqlSentence.WALLET_TABLE_NAME}" (
      "id"	INTEGER NOT NULL UNIQUE,
      "value"	TEXT NOT NULL,
      "createDate"	INTEGER NOT NULL,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  `;
}
