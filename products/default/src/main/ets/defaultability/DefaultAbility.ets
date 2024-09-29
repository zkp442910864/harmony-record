import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger } from '@ohos/common';
import { getSqlObj, initSqlObj } from '../sql/baseSql';

export default class DefaultAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('Ability onCreate');
  }

  onDestroy(): void {
    Logger.info('Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability.
    Logger.info('Ability onWindowStageCreate');

    initSqlObj(this.context);
    AppStorage.setOrCreate('PropA', 47);
    windowStage.loadContent('views/index/Index', (err) => {
      if (err.code) {
        Logger.error('Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources.
    Logger.info('Ability onWindowStageDestroy');
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage): void {
    getSqlObj().rdbStore.close();
  }

  onForeground(): void {
    // Ability has brought to foreground.
    Logger.info('Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background.
    Logger.info('Ability onBackground');
  }

  onBackPressed(): boolean {
    return false;
  }
}
