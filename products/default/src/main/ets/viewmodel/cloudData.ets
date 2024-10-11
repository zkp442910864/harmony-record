
@ObservedV2
export class CloudParamsData {
  cloudUrl: string = '';
  cloudUserName: string = '';
  cloudPassword: string = '';


  constructor(cloudUrl: string = '', cloudUserName: string = '', cloudPassword: string = '') {
    this.cloudUrl = cloudUrl;
    this.cloudUserName = cloudUserName;
    this.cloudPassword = cloudPassword;
  }

  copy() {
    return new CloudParamsData(this.cloudUrl, this.cloudUserName, this.cloudPassword);
  }
}

