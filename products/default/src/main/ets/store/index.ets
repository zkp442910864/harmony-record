import { PersistenceV2 } from '@kit.ArkUI';
import { StorageDefaultCreator, TypeConstructorWithArgs } from '@ohos.arkui.StateManagement';

export class Store {
  /** 注意传入的类型需要实现copy函数，以此达到 使用数据和存储数据 进行解耦 */
  static getData<T extends CExtend<T>>(type: TypeConstructorWithArgs<T>, key: TKey, defaultCreator: StorageDefaultCreator<T>) {
    const data = PersistenceV2.connect(type, key, defaultCreator)!.copy();
    return data;
  }

  /** 保存数据 */
  static saveData<T extends CExtend<T>>(type: TypeConstructorWithArgs<T>, key: TKey, data: T) {
    Store.removeData(key);
    PersistenceV2.connect(type, key, () => data);
  }

  static removeData(key: TKey) {
    PersistenceV2.remove(key);
  }
}


type TKey = 'webDavParams';
interface  IExtend<T extends object> {
  copy: () => T;
}
class CExtend<T extends object> {
  copy() {
    return new Object() as T;
  }
}