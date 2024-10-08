
export class DateUtils {
  private constructor() {}

  static fillZero(value: string | number) {
    return value.toString().padStart(2, '0');
  }

  /** 获取开始时间 */
  static getStartDate(type: 'year' | 'month', value: Date = new Date()) {
    if (type === 'year') {
      const date = new Date(value);
      date.setMonth(0, 1);
      date.setHours(0, 0, 0, 0);
      return date;
    }

    if (type === 'month') {
      const date = new Date(value);
      date.setDate(1);
      date.setHours(0, 0, 0, 0);
      return date;
    }

    throw new Error('getStartDate 请正确传入参数');
  }

  /** 获取结束时间 */
  static getEndDate(type: 'year' | 'month', value: Date = new Date()) {
    if (type === 'year') {
      const date = new Date(value);
      date.setFullYear(date.getFullYear() + 1)
      date.setMonth(0, 0);
      date.setHours(23, 59, 59, 59);
      return date;
    }

    if (type === 'month') {
      const date = new Date(value);
      date.setMonth(date.getMonth() + 1, 0);
      date.setHours(23, 59, 59, 59);
      return date;
    }

    throw new Error('getEndDate 请正确传入参数');
  }

  /** 获取两个时间范围, 包含当天，当月，当年 */
  static getTwoDateRang(type: 'year' | 'month' | 'date', date1: Date, date2: Date) {
    if (type === 'date') {
      // 天的基数
      const base = 24 * 60 * 60 * 1000;
      const diff = Math.abs(date1.getTime() - date2.getTime());
      return Math.floor(diff / base) + 1;
    }

    if (type === 'month' || type === 'year') {
      let count = 0;
      let start = new Date(date1);
      let end = new Date(date2);

      if (start.getTime() > end.getTime()) {
        const cache = start;
        start = end;
        end = cache;
      }

      while (start.getTime() <= end.getTime()) {
        if (type === 'month') {
          start.setMonth(start.getMonth() + 1);
        }
        else {
          start.setFullYear(start.getFullYear() + 1);
        }
        count++;
      }

      return count;
    }

    throw new Error('getTwoDateRang 请正确传入参数');
  }

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

  static toTimeString(date?: Date) {
    if (date) {
      return `${DateUtils.fillZero(date.getHours())}:${DateUtils.fillZero(date.getMinutes())}`;
    }
    return '';
  }
}
