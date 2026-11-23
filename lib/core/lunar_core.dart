import 'dart:math';

/// Thuật toán chuyển đổi âm - dương lịch dựa trên tính toán thiên văn
/// (thuật toán của Hồ Ngọc Đức), múi giờ mặc định +7 (Việt Nam).
class LunarCore {
  static const double timeZone = 7.0;

  /// Số ngày Julius từ ngày dương lịch.
  static int jdFromDate(int dd, int mm, int yy) {
    final a = (14 - mm) ~/ 12;
    final y = yy + 4800 - a;
    final m = mm + 12 * a - 3;
    var jd = dd +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    return jd;
  }

  /// Ngày dương lịch [dd, mm, yy] từ số ngày Julius.
  static List<int> jdToDate(int jd) {
    int a, b, c;
    if (jd > 2299160) {
      // Lịch Gregory
      a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      // Lịch Julius
      b = 0;
      c = jd + 32082;
    }
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = b * 100 + d - 4800 + m ~/ 10;
    return [day, month, year];
  }

  /// Thời điểm sóc (new moon) thứ k tính từ 1/1/1900, theo ngày Julius.
  static double _newMoon(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    const dr = pi / 180;
    var jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 += 0.00033 * sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);
    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    var c1 = (0.1734 - 0.000393 * t) * sin(m * dr) + 0.0021 * sin(2 * dr * m);
    c1 = c1 - 0.4068 * sin(mpr * dr) + 0.0161 * sin(dr * 2 * mpr);
    c1 = c1 - 0.0004 * sin(dr * 3 * mpr);
    c1 = c1 + 0.0104 * sin(dr * 2 * f) - 0.0051 * sin(dr * (m + mpr));
    c1 = c1 - 0.0074 * sin(dr * (m - mpr)) + 0.0004 * sin(dr * (2 * f + m));
    c1 = c1 - 0.0004 * sin(dr * (2 * f - m)) - 0.0006 * sin(dr * (2 * f + mpr));
    c1 = c1 + 0.0010 * sin(dr * (2 * f - mpr)) + 0.0005 * sin(dr * (2 * mpr + m));
    double deltat;
    if (t < -11) {
      deltat = 0.001 +
          0.000839 * t +
          0.0002261 * t2 -
          0.00000845 * t3 -
          0.000000081 * t * t3;
    } else {
      deltat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    return jd1 + c1 - deltat;
  }

  /// Kinh độ mặt trời (radian) tại thời điểm jdn.
  static double _sunLongitude(double jdn) {
    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;
    const dr = pi / 180;
    final m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    var dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * sin(dr * m);
    dl += (0.019993 - 0.000101 * t) * sin(dr * 2 * m) + 0.000290 * sin(dr * 3 * m);
    var l = (l0 + dl) * dr;
    l = l - pi * 2 * (l / (pi * 2)).floorToDouble();
    return l;
  }

  /// Chỉ số cung kinh độ mặt trời (0-11), dùng xác định tháng nhuận.
  static int getSunLongitudeIndex(int dayNumber, double tz) {
    return (_sunLongitude(dayNumber - 0.5 - tz / 24) / pi * 6).floor();
  }

  /// Chỉ số tiết khí (0-23) của một ngày Julius.
  static int getTietKhiIndex(int jd, [double tz = timeZone]) {
    return (_sunLongitude(jd + 0.5 - tz / 24) / pi * 12).floor();
  }

  /// Ngày Julius chứa điểm sóc thứ k (theo múi giờ tz).
  static int getNewMoonDay(int k, double tz) {
    return (_newMoon(k) + 0.5 + tz / 24).floor();
  }

  /// Ngày sóc của tháng 11 âm lịch của năm yy.
  static int getLunarMonth11(int yy, double tz) {
    final off = jdFromDate(31, 12, yy) - 2415021;
    final k = (off / 29.530588853).floor();
    var nm = getNewMoonDay(k, tz);
    final sunLong = getSunLongitudeIndex(nm, tz);
    if (sunLong >= 9) {
      nm = getNewMoonDay(k - 1, tz);
    }
    return nm;
  }

  /// Vị trí tháng nhuận sau tháng 11 âm lịch (a11).
  static int getLeapMonthOffset(int a11, double tz) {
    final k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    var i = 1;
    var last = 0;
    var arc = getSunLongitudeIndex(getNewMoonDay(k + i, tz), tz);
    do {
      last = arc;
      i++;
      arc = getSunLongitudeIndex(getNewMoonDay(k + i, tz), tz);
    } while (arc != last && i < 14);
    return i - 1;
  }

  /// Đổi ngày dương sang âm: trả về [ngày, tháng, năm, nhuận(0/1)].
  static List<int> solarToLunar(int dd, int mm, int yy, [double tz = timeZone]) {
    final dayNumber = jdFromDate(dd, mm, yy);
    final k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    var monthStart = getNewMoonDay(k + 1, tz);
    if (monthStart > dayNumber) {
      monthStart = getNewMoonDay(k, tz);
    }
    var a11 = getLunarMonth11(yy, tz);
    var b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = getLunarMonth11(yy - 1, tz);
    } else {
      lunarYear = yy + 1;
      b11 = getLunarMonth11(yy + 1, tz);
    }
    final lunarDay = dayNumber - monthStart + 1;
    final diff = ((monthStart - a11) / 29).floor();
    var lunarLeap = 0;
    var lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      final leapMonthDiff = getLeapMonthOffset(a11, tz);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) {
          lunarLeap = 1;
        }
      }
    }
    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }
    return [lunarDay, lunarMonth, lunarYear, lunarLeap];
  }

  /// Đổi ngày âm sang dương: trả về [ngày, tháng, năm],
  /// hoặc [0,0,0] nếu ngày âm không hợp lệ (ví dụ tháng nhuận sai).
  static List<int> lunarToSolar(int lunarDay, int lunarMonth, int lunarYear,
      int lunarLeap, [double tz = timeZone]) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = getLunarMonth11(lunarYear - 1, tz);
      b11 = getLunarMonth11(lunarYear, tz);
    } else {
      a11 = getLunarMonth11(lunarYear, tz);
      b11 = getLunarMonth11(lunarYear + 1, tz);
    }
    final k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    var off = lunarMonth - 11;
    if (off < 0) {
      off += 12;
    }
    if (b11 - a11 > 365) {
      final leapOff = getLeapMonthOffset(a11, tz);
      var leapMonth = leapOff - 2;
      if (leapMonth < 0) {
        leapMonth += 12;
      }
      if (lunarLeap != 0 && lunarMonth != leapMonth) {
        return [0, 0, 0];
      } else if (lunarLeap != 0 || off >= leapOff) {
        off += 1;
      }
    }
    final monthStart = getNewMoonDay(k + off, tz);
    return jdToDate(monthStart + lunarDay - 1);
  }
}
