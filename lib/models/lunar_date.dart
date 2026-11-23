import '../core/can_chi.dart';
import '../core/lunar_core.dart';

/// Thông tin đầy đủ về một ngày: dương lịch + âm lịch + can chi.
class LunarDate {
  final DateTime solar;
  final int day;
  final int month;
  final int year;
  final bool isLeapMonth;
  final int jd;

  LunarDate._({
    required this.solar,
    required this.day,
    required this.month,
    required this.year,
    required this.isLeapMonth,
    required this.jd,
  });

  factory LunarDate.fromSolar(DateTime date) {
    final l = LunarCore.solarToLunar(date.day, date.month, date.year);
    return LunarDate._(
      solar: DateTime(date.year, date.month, date.day),
      day: l[0],
      month: l[1],
      year: l[2],
      isLeapMonth: l[3] == 1,
      jd: LunarCore.jdFromDate(date.day, date.month, date.year),
    );
  }

  /// Trả về null nếu ngày âm không hợp lệ.
  static LunarDate? fromLunar(int day, int month, int year, bool leap) {
    final s = LunarCore.lunarToSolar(day, month, year, leap ? 1 : 0);
    if (s[0] == 0) return null;
    final solar = DateTime(s[2], s[1], s[0]);
    // Kiểm tra ngược lại để loại ngày âm không tồn tại (vd 30 của tháng thiếu).
    final back = LunarCore.solarToLunar(s[0], s[1], s[2]);
    if (back[0] != day || back[1] != month || back[2] != year) return null;
    return LunarDate.fromSolar(solar);
  }

  String get canChiYear => CanChi.ofYear(year);
  String get canChiMonth =>
      CanChi.ofMonth(month, year, leap: isLeapMonth);
  String get canChiDay => CanChi.ofDay(jd);
  String get tietKhi => CanChi.tietKhiOfDay(jd);
  bool get isHoangDao => CanChi.isNgayHoangDao(jd, month);
  String get thanTrucNgay => CanChi.thanTrucNgay(jd, month);
  List<String> get gioHoangDao => CanChi.gioHoangDao(jd);

  String get monthLabel => isLeapMonth ? '$month (nhuận)' : '$month';
}
