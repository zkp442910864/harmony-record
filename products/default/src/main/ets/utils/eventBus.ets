import { BusinessError, commonEventManager, emitter } from '@kit.BasicServicesKit';


export class EventBus {

  static on<T extends (data: emitter.GenericEventData<never>) => void>(key: TKey, cb: T) {
    emitter.on(key, cb);
  }

  static off<T extends (data: emitter.GenericEventData<never>) => void>(key: TKey, cb?: T) {
    cb ? emitter.off(key, cb) : emitter.off(key);
  }

  static emit<T extends object | number | string>(key: TKey, data?: emitter.GenericEventData<T>) {
    emitter.emit(key, data);
  }
}

type TKey = 'updateHomeData';