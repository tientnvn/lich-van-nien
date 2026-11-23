import 'lunar_core.dart';

/// Tính Can Chi, giờ hoàng đạo, ngày hoàng đạo/hắc đạo, tiết khí.
class CanChi {
  static const List<String> can = [
    'Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu',
    'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý',
  ];

  static const List<String> chi = [
    'Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ',
    'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi',
  ];

  static const List<String> tietKhi = [
    'Xuân phân', 'Thanh minh', 'Cốc vũ', 'Lập hạ', 'Tiểu mãn', 'Mang chủng',
    'Hạ chí', 'Tiểu thử', 'Đại thử', 'Lập thu', 'Xử thử', 'Bạch lộ',
    'Thu phân', 'Hàn lộ', 'Sương giáng', 'Lập đông', 'Tiểu tuyết', 'Đại tuyết',
    'Đông chí', 'Tiểu hàn', 'Đại hàn', 'Lập xuân', 'Vũ thủy', 'Kinh trập',
  ];

  /// Khung giờ tương ứng 12 chi (giờ Tý = 23h-1h, ...).
  static const List<String> gioRange = [
    '23-1', '1-3', '3-5', '5-7', '7-9', '9-11',
    '11-13', '13-15', '15-17', '17-19', '19-21', '21-23',
  ];

  /// Bảng giờ hoàng đạo theo chi của ngày (nhóm theo cặp chi).
  /// Mỗi chuỗi 12 ký tự: 1 = giờ hoàng đạo, theo thứ tự 12 chi.
  static const List<String> _gioHoangDaoMask = [
    '110100101100', // Tý, Ngọ
    '001101001011', // Sửu, Mùi
    '110011010010', // Dần, Thân
    '101100110100', // Mão, Dậu
    '001011001101', // Thìn, Tuất
    '010010110011', // Tỵ, Hợi
  ];

  /// 12 vị thần theo vòng Hoàng đạo - Hắc đạo, bắt đầu từ Thanh Long.
  static const List<String> _thapNhiThan = [
    'Thanh Long', 'Minh Đường', 'Thiên Hình', 'Chu Tước',
    'Kim Quỹ', 'Bảo Quang', 'Bạch Hổ', 'Ngọc Đường',
    'Thiên Lao', 'Huyền Vũ', 'Tư Mệnh', 'Câu Trận',
  ];

  /// Vị trí các thần hoàng đạo trong vòng 12 thần.
  static const Set<int> _hoangDaoIndex = {0, 1, 4, 5, 7, 10};

  /// Can chi của năm âm lịch.
  static String ofYear(int lunarYear) {
    return '${can[(lunarYear + 6) % 10]} ${chi[(lunarYear + 8) % 12]}';
  }

  /// Can chi của tháng âm lịch (tháng 1 = Dần).
  static String ofMonth(int lunarMonth, int lunarYear, {bool leap = false}) {
    final c = can[(lunarYear * 12 + lunarMonth + 3) % 10];
    final ch = chi[(lunarMonth + 1) % 12];
    return leap ? '$c $ch (nhuận)' : '$c $ch';
  }

  /// Can chi của ngày theo số ngày Julius.
  static String ofDay(int jd) {
    return '${can[(jd + 9) % 10]} ${chi[(jd + 1) % 12]}';
  }

  /// Chỉ số chi của ngày (0 = Tý).
  static int dayChiIndex(int jd) => (jd + 1) % 12;

  /// Can chi của giờ Tý ngày jd (dùng cho giờ đầu ngày).
  static String ofHour(int jd, int hourChiIndex) {
    final canGioTy = ((jd + 9) % 10 * 2) % 10;
    return '${can[(canGioTy + hourChiIndex) % 10]} ${chi[hourChiIndex]}';
  }

  /// Danh sách giờ hoàng đạo của ngày jd, ví dụ: "Tý (23-1)".
  static List<String> gioHoangDao(int jd) {
    final mask = _gioHoangDaoMask[dayChiIndex(jd) % 6];
    final result = <String>[];
    for (var i = 0; i < 12; i++) {
      if (mask[i] == '1') {
        result.add('${chi[i]} (${gioRange[i]})');
      }
    }
    return result;
  }

  /// Tên vị thần trực ngày (Thanh Long, Minh Đường...).
  static String thanTrucNgay(int jd, int lunarMonth) {
    // Ngày khởi Thanh Long: tháng Giêng từ Tý, mỗi tháng lùi 2 chi, chu kỳ 6 tháng.
    final startChi = ((lunarMonth - 1) % 6) * 2;
    final godIndex = (dayChiIndex(jd) - startChi + 12) % 12;
    return _thapNhiThan[godIndex];
  }

  /// Ngày hoàng đạo hay hắc đạo.
  static bool isNgayHoangDao(int jd, int lunarMonth) {
    final startChi = ((lunarMonth - 1) % 6) * 2;
    final godIndex = (dayChiIndex(jd) - startChi + 12) % 12;
    return _hoangDaoIndex.contains(godIndex);
  }

  /// Tên tiết khí của ngày jd.
  static String tietKhiOfDay(int jd) {
    return tietKhi[LunarCore.getTietKhiIndex(jd)];
  }
}
