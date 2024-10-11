
/** 平铺promise */
export const tilePromise = async <T = void>() => {
  return new Promise<ITilePromise<T>>((rel) => {
    const promise = new Promise<T>((resolve, reject) => {
      setTimeout(() => {
        rel({
          promise,
          resolve,
          reject
        })
      }, 0);
    })
  })
}

export interface ITilePromise<T> {
  promise: Promise<T>;
  resolve: (value: T | PromiseLike<T>) => void;
  reject: (reason?: object) => void
}