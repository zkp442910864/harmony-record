import { MyNavDestinationAnimationModifier } from ".";

export class MyNavPathStack extends NavPathStack {
  constructor() {
    super();
  }

  pop(result?: Object | boolean, animated?: boolean) {
    const fn = MyNavDestinationAnimationModifier.pathLeaveMap.get(this.getAllPathName().length - 1);
    if (fn) {
      fn(() => {
        super.pop(false);
      });
      MyNavDestinationAnimationModifier.pathLeaveMap.delete(this.getAllPathName().length - 1)
      return;
    }

    return super.pop(result, animated);
  }
}
