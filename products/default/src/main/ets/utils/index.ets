import { promptAction } from '@kit.ArkUI';

export {DateUtils} from './dateUtils';
export {EventBus} from './eventBus';
export * from './newNavPathStack';
export * from './extendPromise';

export const isEmpty = (val: string | number | boolean | null | undefined) => {
  if (val === '' || val === null || val === undefined) {
    return true;
  }
  return false;
}

export const toast = (message: string, duration = 1000) => {
  promptAction.showToast({
    message,
    duration,
  })
}

export const sleep = (duration = 300) => {
  return new Promise<void>((rel) => {
    setTimeout(() => {
      rel()
    }, duration)
  })
}