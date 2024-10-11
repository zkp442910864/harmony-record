import { http } from '@kit.NetworkKit';
import { convertxml, util } from '@kit.ArkTS';
import { BusinessError } from '@ohos.base';
import rcp from '@hms.collaboration.rcp';
import fs from '@ohos.file.fs';
import { Store } from '../store';
import { CloudParamsData } from '../viewmodel/cloudData';
import { isEmpty, toast } from '.';
import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { getSqlObj } from '../sql/baseSql';
import { IXmlRoot, IXmlData, ICloudListData } from '../viewmodel/types/base';

export class CloudBackup {
  // testCloud
  // MoneyBox
  static cloudBackup?: CloudBackup;
  static getInstance(update = false) {
    if (!CloudBackup.cloudBackup || update) {
      CloudBackup.cloudBackup = new CloudBackup();
    }
    return CloudBackup.cloudBackup;
  }
  // static destroyInstance() {
  //   CloudBackup.cloudBackup = undefined;
  // }

  session = rcp.createSession();
  textDecoder = util.TextDecoder.create('utf-8');
  textEncoder = util.TextEncoder.create('utf-8');

  // url = 'https://dav.jianguoyun.com/dav';
  // username = '442910864@qq.com';
  // password = 'a3buyzz4zv7mbc9a';
  url = '';
  username = '';
  password = '';
  folderName = '/HarmonyOsMoneyBox';
  authorization = '';
  conv = new convertxml.ConvertXML();
  convOptions: convertxml.ConvertOptions = {
    ignoreDeclaration: true,
    ignoreInstruction: true,
    ignoreAttributes: true,
    ignoreComment: true,
    ignoreCDATA: true,
    ignoreDoctype: true,
    // ignoreText: true,
    trim: true,
    declarationKey: '_declaration',
    instructionKey: '_instruction',
    attributesKey: '_attributes',
    textKey: 'value',
    cdataKey: '_cdata',
    doctypeKey: '_doctype',
    commentKey: '_comment',
    parentKey: '_parent',
    typeKey: 'type',
    nameKey: 'name',
    elementsKey: 'children',
  };

  // PROPFIND 获取列表          https://dav.jianguoyun.com/dav/MoneyBox/
  // MKCOL 创建文件夹            https://dav.jianguoyun.com/dav/MoneyBox/
  // PUT 上传文件 文件流         https://dav.jianguoyun.com/dav/MoneyBox/MoneyBox_2024-10-10.backup
  // PROPFIND 查询文件是否存在    https://dav.jianguoyun.com/dav/MoneyBox/MoneyBox_2024-10-10.backup
  // GET 下载文件               https://dav.jianguoyun.com/dav/MoneyBox/MoneyBox_2024-10-10.backup
  private constructor() {
    const data = Store.getData(CloudParamsData, 'webDavParams', () => new CloudParamsData());
    this.url = data.cloudUrl;
    this.username = data.cloudUserName;
    this.password = data.cloudPassword;
    this.authorization = this.toBase64();
  }

  /** 通知 */
  notificationError(text: string) {
    toast(text);
  }

  checkBaseData(showToast = true) {
    if (isEmpty(this.url) || isEmpty(this.username) || isEmpty(this.password)) {
      showToast && toast('请配置WebDav信息');
      return false;
    }
    return true
  }

  toBase64() {
    const base64 = new util.Base64Helper();
    return base64.encodeToStringSync(this.textEncoder.encodeInto(`${this.username}:${this.password}`));
  }

  /** 处理xml数据, flagStr 用于匹配路径，取值 */
  handlerXmlData(xml: string, flagStr: string = ['multistatus', 'response'].join()) {
    const result: ICloudListData = {
      children: [],
    };
    const jsonData = this.conv.convertToJSObject(xml, this.convOptions) as IXmlRoot;
    const each = (data: IXmlData[], tagArr: string[] = [], resultData?: ICloudListData) => {
      data.forEach((item) => {
        const newTagArr = tagArr.slice();
        newTagArr.push(item.name);

        if (flagStr === newTagArr.join()) {
          if (Array.isArray(item.children)) {
            const dateStr = item.children[1]?.children?.[0]?.children?.find(ii => ii.name === 'getlastmodified')?.children?.[0].value;
            const data: ICloudListData = {
              value: item.children[0]?.children?.[0].value,
              dateStr,
              isCollection: item.children[1]?.children?.[0]?.children?.find(ii => ii.name === 'resourcetype')?.children?.[0].name === 'collection',
              date: dateStr ? new Date(dateStr) : undefined,
            };
            result.children!.push(data);
          }
        }
        else if (Array.isArray(item.children)) {
          each(item.children, newTagArr);
        }
      });
    }
    each(jsonData.children);
    return result;
  }

  /** 上传文件 /MoneyBox_2024-10-10 */
  async uploadDbFile() {
    const fileName = `${this.folderName}_${new Date().toLocaleDateString().replaceAll('/', '-')}`;
    let url = this.url + this.folderName + fileName + '.backup';

    await this.createFolder();
    if (await this.queryExist(fileName + '.backup')) {
      url = this.url + this.folderName + fileName + '_' + Date.now() + '.backup';
    }

    const fileUrl = await getSqlObj().backup();
    const request = this.getRequest(url, 'PUT', new rcp.UploadFromFile(fileUrl));
    return this.responseUniformTreatment(request)
      .finally(() => {
        fs.unlink(fileUrl);
      })
      .then((rep: rcp.Response) => {
        return true;
      })
      .catch((err: BusinessError) => {
        this.notificationError('上传文件失败');
        return false;
      });
  }

  /** 创建文件夹 */
  async createFolder() {
    if (await this.queryExist('')) return;
    const request = this.getRequest(this.url + this.folderName, 'MKCOL');
    return this.responseUniformTreatment(request)
      .then((rep: rcp.Response) => {
        return true;
      })
      .catch((err: BusinessError) => {
        this.notificationError('文件夹创建失败');
        return false;
      });
  }

  /** 查询 文件/文件夹 是否存在 /MoneyBox_2024-10-10.backup */
  queryExist(fileName: string) {
    const request = this.getRequest(this.url + this.folderName + fileName, 'PROPFIND');
    return this.responseUniformTreatment(request).then(() => {
      return true;
    }).catch(() => {
      return false;
    });
  }

  /** 恢复备份文件 */
  restoreFileData(fileName: string) {
    const request = this.getRequest(this.url + this.folderName + fileName, 'GET');
    return this.responseUniformTreatment(request).then(async (rep) => {
      const fileUrl = getSqlObj().BACKUP_URL;
      try {
        fs.unlinkSync(fileUrl);
      } catch (err) {
      }
      const file = fs.openSync(fileUrl, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.write(file.fd, rep.body!);
      fs.close(file);
      await getSqlObj().restore();
      fs.unlink(fileUrl);
    }).catch((err: BusinessError) => {
      this.notificationError('备份文件获取失败');
      return Promise.reject(err);
    })
  }

  /** 获取备份列表 */
  getListV2() {
    const request = this.getRequest(this.url + this.folderName, 'PROPFIND');

    return this.responseUniformTreatment(request)
      .then((rep) => {
        try {
          const xml = this.textDecoder.decodeWithStream(new Uint8Array(rep.body));
          const result = this.handlerXmlData(xml);
          const arr = result.children!.slice();
          const index = arr.findIndex(ii => ii.isCollection)!;
          const rootData = arr[index];
          arr.splice(index, 1);
          rootData.children = arr;
          return rootData;
        } catch (err) {
          return Promise.reject({code: ErrorSet.errCode2, message: ErrorSet.errMsg2, data: rep});
        }
      })
      .catch((err: BusinessError) => {
        this.notificationError('获取历史备份数据失败');
        return Promise.reject(err);
      });
  }

  getRequest(url: string, method: string, content?: rcp.RequestContent) {
    const request = new rcp.Request(
      url,
      method,
      {
        Authorization: `Basic ${this.authorization}`
      },
      content
    );

    return request;
  }

  /** 响应统一处理 */
  responseUniformTreatment(request: rcp.Request) {
    return new Promise<rcp.Response>((rel, rej) => {
      try {
        const promise = this.session.fetch(request);
        promise
          .then((rep: rcp.Response) => {
            if (rep.statusCode.toString().startsWith('2')) {
              rel(rep);
              return rep;
            }
            else {
              return Promise.reject({code: ErrorSet.errCode1, message: ErrorSet.errMsg1, data: rep})
            }
          })
          .catch((err: BusinessError) => {
            console.error(`请求错误信息: Code is ${err.code}, message is ${err.message}.`);
            console.error(`~~~~~~~~~~~ ${JSON.stringify(err)}`);
            rej(err);
          });
      } catch (err) {
        console.error(`promise创建失败: Code is ${err.code}, message is ${err.message}.`);
        this.notificationError('网络请求失败，请检查参数');
        rej(err);
      }

    })
  }

  createTestFile(fileName: string) {
    const context = getContext();
    const cacheDir = context.cacheDir;
    const localFileUrl = cacheDir + fileName;

    try {
      fs.unlinkSync(localFileUrl);
    } catch (err) {
    }
    const file = fs.openSync(localFileUrl, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, 'qqqqqweqew', {
      encoding: 'utf-8'
    });
    fs.close(file);
    return localFileUrl;
  }

  getList() {
    const httpRequest = http.createHttp();
    httpRequest.request(this.url + 'MoneyBox', {
      method: http.RequestMethod.GET,
      header: {
        Authorization: `Basic ${this.authorization}`
      }
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析
        console.info('data:' + JSON.stringify(data));
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        console.info('type:' + JSON.stringify(data.resultType));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 自API version 8开始支持cookie
        // 取消订阅HTTP响应头事件
        // httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      } else {
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        // httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    })
  }
}

class ErrorSet {
  static errCode1 = -1;
  static errMsg1 = '非2xx错误';

  static errCode2 = -2;
  static errMsg2 = '内部程序处理错误';
}
