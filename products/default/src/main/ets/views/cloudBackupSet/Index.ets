import { CommonConstants } from '../../constants/CommonConstants';
import { ICloudListData, IRouterMapData } from '../../viewmodel/types/base';
import { ITilePromise, tilePromise, toast } from '../../utils';
import { Store } from '../../store';
import { promptAction } from '@kit.ArkUI';
import { CloudBackup } from '../../utils/cloudBackup';
import { CloudParamsData } from '../../viewmodel/cloudData';

@Builder
export function builderFn() {
  CloudBackupSet()
}

@Preview
@ComponentV2
struct CloudBackupSet {
  pathStack?: NavPathStack;
  @Local title: string = '';
  @Local params: CloudParamsData = Store.getData(CloudParamsData, 'webDavParams', () => new CloudParamsData());
  @Local loading: boolean = false;
  customDialogComponentId = 0;

  aboutToAppear(): void {
    this.queryNavDestinationInfo()
  }

  saveWebDavData = () => {
    Store.saveData(CloudParamsData, 'webDavParams', this.params);
    this.getUIContext().getFocusController().clearFocus();
    CloudBackup.getInstance(true);
    toast('保存成功');
  }

  action = async (type: string) => {
    const obj = CloudBackup.getInstance();
    if (!obj.checkBaseData()) {
      return;
    }

    if (this.loading) {
      return;
    }
    this.loading = true;

    try {
      if (type === 'backup') {
        await obj.uploadDbFile();
        toast('备份成功');
      } else if (type === 'restore') {
        const data = await obj.getListV2();
        const fileName = await this.showPrompt(data);
        await obj.restoreFileData(fileName);
        toast('恢复成功');
      }
    } catch (err) {
      console.error(`error: ${JSON.stringify(err)}`);
    }

    this.loading = false;
  }

  /** 文件选择框 */
  async showPrompt(data: ICloudListData) {
    const obj = await tilePromise<string>();

    await promptAction.openCustomDialog({
      builder: () => {
        this.dialogContext(data, obj)
      },
      alignment: DialogAlignment.Bottom,
      onWillDismiss: (action) => {
        obj.reject();
        action.dismiss();
      },
    }).then((dialogId) => {
      this.customDialogComponentId = dialogId;
    });

    return obj.promise;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('WebDav备份与还原')
            .fontSize(16)

          Button() {
            SymbolGlyph($r('sys.symbol.rays'))
              .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), true)
              .fontColor([CommonConstants.COLOR_TEXT_MAIN])
          }
          .padding(4)
          .backgroundColor(CommonConstants.COLOR_SECONDARY)
          .opacity(this.loading ? 1 : 0)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Column() {
          Text('WebDav备份')
            .fontSize(12)
          Text(`数据将备份到此目录:[/WebDav根目录${CloudBackup.getInstance().folderName}/]`)
            .fontSize(10)
            .margin({ top: 4 })
            .fontColor(Color.Gray)
        }
        .width('100%')
        .padding({ bottom: 12, top: 12 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .borderColor(CommonConstants.COLOR_SECONDARY)
        .borderWidth({ bottom: 1 })
        .borderStyle(BorderStyle.Dashed)
        .onClick(() => this.action('backup'))

        Column() {
          Text('WebDav还原')
            .fontSize(12)
          Text('从您的远程备份目录中还原数据，还原将会替换掉现有数据')
            .fontSize(10)
            .margin({ top: 4 })
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 12 })
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding(16)
      .backgroundColor('#fff')
      .borderRadius(16)
      .margin(16)
      .onClick(() => this.action('restore'))

      Column() {
        Row() {
          Text('WebDav设置')
            .fontSize(16)

          Button() {
            Text() {
              SymbolSpan($r('sys.symbol.save'))
                .fontColor([CommonConstants.COLOR_TEXT_MAIN])
            }
          }
          .padding(4)
          .backgroundColor(CommonConstants.COLOR_SECONDARY)
          .onClick(this.saveWebDavData)
        }
        .width('100%')
        .margin({ bottom: 12 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('地址')
            .textStyle()
          TextInput({ placeholder: '输入WebDav服务器地址', text: this.params.cloudUrl })
            .inputStyle()
            .onChange((val) => {
              this.params.cloudUrl = val;
            })
        }
        .rowStyle()

        Row() {
          Text('用户名')
            .textStyle()
          TextInput({ placeholder: '输入WebDav用户名', text: this.params.cloudUserName })
            .inputStyle()
            .onChange((val) => {
              this.params.cloudUserName = val;
            })
        }
        .rowStyle()

        Row() {
          Text('密码')
            .textStyle()
          TextInput({ placeholder: '输入WebDav密码', text: this.params.cloudPassword })
            .inputStyle()
            .onChange((val) => {
              this.params.cloudPassword = val;
            })
          // .type(InputType.Password)
        }
        .rowStyle()
      }
      .padding(16)
      .backgroundColor('#fff')
      .borderRadius(16)
      .margin(16)
    }
    .title(this.title)
    .backgroundColor(CommonConstants.COLOR_SECONDARY)
    .onReady((context) => {
      const routerConfig = context.getConfigInRouteMap();
      const data = routerConfig!.data as IRouterMapData;

      this.pathStack = context.pathStack;
      this.title = data.title;

    })
  }

  @Builder
  dialogContext(data: ICloudListData, callObj: ITilePromise<string>) {
    Column() {
      Text('文件列表')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({bottom: 16})
      List({space: 16}) {
        ForEach(data.children, (item: ICloudListData) => {
          ListItem() {
            Column() {
              Text() {
                SymbolSpan($r('sys.symbol.doc_text_badge_magnifyingglass'))
                  .fontColor(['#000', CommonConstants.COLOR_MAIN])
                  .fontSize(50)
              }
              Text(item.value?.replace(data.value!, ''))
                .maxLines(2)
                .fontSize(10)
                .textOverflow({overflow: TextOverflow.Ellipsis})
                .margin({top: 4})
            }
          }
          .onClick(() => {
            // console.log(`${JSON.stringify(item)}`)
            const fileName = `/${item.value?.replace(data.value!, '')}`;
            promptAction.closeCustomDialog(this.customDialogComponentId);
            callObj.resolve(fileName);
          })
        })
      }
      .lanes(2, 16)
      .constraintSize({maxHeight: '50%'})
      // .columnsTemplate('1fr 1fr 1fr')
    }
    .padding(16)
  }
}

@Extend(Row)
function rowStyle() {
  .width('100%')
  .margin({ bottom: 8 })
}

@Extend(Text)
function textStyle() {
  .width(50)
  .fontSize(12)
}

@Extend(TextInput)
function inputStyle() {
  .flexGrow(1)
  .width(0)
  .backgroundColor(Color.Transparent)
  .fontSize(12)
  .placeholderFont({ size: 12 })
  .padding(0)
  .height(30)
  .borderRadius(0)
  .borderColor(CommonConstants.COLOR_SECONDARY)
  .caretColor(CommonConstants.COLOR_SECONDARY)
  .borderWidth({ bottom: 1 })
  // .cancelButton({style: CancelButtonStyle.INPUT})
}

