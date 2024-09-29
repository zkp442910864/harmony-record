
export class DateUtils {
  private constructor() {}

  /** 获取月份的开始-结束，时间戳 */
  static getMonthRang(currentMonth?: number, currentYear?: number) {
    const date = new Date();
    const curYear = currentYear ?? date.getUTCFullYear();
    const curMonth = currentMonth ?? date.getUTCMonth() + 1;
    const startDate = new Date(`${curYear}/${curMonth}/01 00:00:00`);
    const endDate = new Date(`${curYear}/${curMonth + 1}/01 23:59:59`);
    endDate.setDate(endDate.getDate() - 1);

    return [startDate.getTime(), endDate.getTime()];
  }

  /** 时间对象 转utc时间戳 */
  static toUTCTime(value: Date | number) {
    const date = new Date(value);
    const offset = date.getTimezoneOffset() * 60 * 1000;
    return date.getTime() + offset;
  }

  /** utc时间戳 转 时间对象 */
  static toLocalDate(time: number) {
    const date = new Date();
    const offset = date.getTimezoneOffset() * 60 * 1000;
    return new Date(time - offset);
  }
}
