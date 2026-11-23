import '../models/lunar_date.dart';

class VnEvent {
  final String name;
  final bool isLunar;
  const VnEvent(this.name, {this.isLunar = false});
}

/// Ngày lễ, sự kiện của Việt Nam theo dương lịch và âm lịch.
class VnEvents {
  /// key: 'dd/mm' dương lịch
  static const Map<String, String> solar = {
    '1/1': 'Tết Dương lịch',
    '9/1': 'Ngày truyền thống Học sinh - Sinh viên',
    '3/2': 'Ngày thành lập Đảng CSVN',
    '14/2': 'Lễ Tình nhân (Valentine)',
    '27/2': 'Ngày Thầy thuốc Việt Nam',
    '8/3': 'Quốc tế Phụ nữ',
    '26/3': 'Ngày thành lập Đoàn TNCS HCM',
    '30/4': 'Ngày Giải phóng miền Nam',
    '1/5': 'Quốc tế Lao động',
    '7/5': 'Chiến thắng Điện Biên Phủ',
    '19/5': 'Ngày sinh Chủ tịch Hồ Chí Minh',
    '1/6': 'Quốc tế Thiếu nhi',
    '28/6': 'Ngày Gia đình Việt Nam',
    '27/7': 'Ngày Thương binh - Liệt sĩ',
    '19/8': 'Cách mạng tháng Tám thành công',
    '2/9': 'Quốc khánh',
    '10/10': 'Ngày Giải phóng Thủ đô',
    '20/10': 'Ngày Phụ nữ Việt Nam',
    '20/11': 'Ngày Nhà giáo Việt Nam',
    '22/12': 'Ngày thành lập QĐND Việt Nam',
    '24/12': 'Lễ Giáng sinh (đêm)',
    '25/12': 'Lễ Giáng sinh',
  };

  /// key: 'dd/mm' âm lịch (không tính tháng nhuận)
  static const Map<String, String> lunar = {
    '1/1': 'Tết Nguyên Đán',
    '2/1': 'Mùng 2 Tết',
    '3/1': 'Mùng 3 Tết',
    '15/1': 'Rằm tháng Giêng (Tết Nguyên Tiêu)',
    '3/3': 'Tết Hàn Thực',
    '10/3': 'Giỗ Tổ Hùng Vương',
    '15/4': 'Lễ Phật Đản',
    '5/5': 'Tết Đoan Ngọ',
    '15/7': 'Lễ Vu Lan (Rằm tháng Bảy)',
    '15/8': 'Tết Trung Thu',
    '9/9': 'Tết Trùng Cửu',
    '10/10': 'Tết Thường Tân',
    '15/10': 'Tết Hạ Nguyên',
    '23/12': 'Ông Táo chầu trời',
  };

  /// Danh sách sự kiện của một ngày.
  static List<VnEvent> eventsOf(LunarDate date) {
    final result = <VnEvent>[];
    final s = solar['${date.solar.day}/${date.solar.month}'];
    if (s != null) result.add(VnEvent(s));
    if (!date.isLeapMonth) {
      final l = lunar['${date.day}/${date.month}'];
      if (l != null) result.add(VnEvent(l, isLunar: true));
    }
    // Ngày rằm, mùng 1 hàng tháng
    if (date.day == 1 && !(date.month == 1 && !date.isLeapMonth)) {
      result.add(const VnEvent('Mùng 1 (ngày Sóc)', isLunar: true));
    }
    if (date.day == 15 &&
        !const {'1', '4', '7', '8', '10'}.contains('${date.month}')) {
      result.add(const VnEvent('Ngày Rằm (ngày Vọng)', isLunar: true));
    }
    return result;
  }

  static bool hasEvent(LunarDate date) {
    if (solar.containsKey('${date.solar.day}/${date.solar.month}')) return true;
    if (!date.isLeapMonth && lunar.containsKey('${date.day}/${date.month}')) {
      return true;
    }
    return false;
  }
}
