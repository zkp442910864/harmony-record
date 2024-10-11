import { sleep } from '.';

export class NewNavPathStack extends NavPathStack {
  pageBackMonitorArr: Array<() => void> = [];

  pop(resultOrAnimated?: boolean | Object, animated?: boolean): NavPathInfo | undefined {
    setTimeout(() => this.pageBackMonitorArr.forEach((fn) => {fn()}), 0);
    return super.pop(resultOrAnimated, animated);
  }

  /** 监听 页面返回 */
  pageBackMonitor(callback: () => void) {
    this.pageBackMonitorArr.push(callback);
  };

}


