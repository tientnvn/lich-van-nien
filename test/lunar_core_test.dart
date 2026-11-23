import 'package:flutter_test/flutter_test.dart';
import 'package:lich_van_nien/core/can_chi.dart';
import 'package:lich_van_nien/core/lunar_core.dart';
import 'package:lich_van_nien/models/lunar_date.dart';

void main() {
  group('Đổi dương sang âm', () {
    test('Tết Nguyên Đán các năm', () {
      // Mùng 1 Tết Giáp Thìn 2024 = 10/02/2024
      expect(LunarCore.solarToLunar(10, 2, 2024), [1, 1, 2024, 0]);
      // Mùng 1 Tết Ất Tỵ 2025 = 29/01/2025
      expect(LunarCore.solarToLunar(29, 1, 2025), [1, 1, 2025, 0]);
      // Mùng 1 Tết Bính Ngọ 2026 = 17/02/2026
      expect(LunarCore.solarToLunar(17, 2, 2026), [1, 1, 2026, 0]);
    });

    test('Tháng nhuận', () {
      // Năm 2023 nhuận tháng 2: 22/03/2023 là 1/2 nhuận
      expect(LunarCore.solarToLunar(22, 3, 2023), [1, 2, 2023, 1]);
      // Năm 2025 nhuận tháng 6: 25/07/2025 là 1/6 nhuận
      expect(LunarCore.solarToLunar(25, 7, 2025), [1, 6, 2025, 1]);
    });

    test('Ngày thường', () {
      // 30/04/1975 = 20/3 Ất Mão theo múi giờ +7
      // (lịch miền Nam thời đó dùng múi giờ +8 nên ghi 19/3)
      expect(LunarCore.solarToLunar(30, 4, 1975), [20, 3, 1975, 0]);
      // 02/09/1945 = 26/7 Ất Dậu
      expect(LunarCore.solarToLunar(2, 9, 1945), [26, 7, 1945, 0]);
    });
  });

  group('Đổi âm sang dương', () {
    test('Giỗ Tổ Hùng Vương 10/3/2025 = 07/04/2025', () {
      expect(LunarCore.lunarToSolar(10, 3, 2025, 0), [7, 4, 2025]);
    });

    test('Tháng nhuận 1/6 nhuận 2025 = 25/07/2025', () {
      expect(LunarCore.lunarToSolar(1, 6, 2025, 1), [25, 7, 2025]);
    });

    test('Tháng nhuận sai trả về [0,0,0]', () {
      expect(LunarCore.lunarToSolar(1, 5, 2025, 1), [0, 0, 0]);
    });
  });

  group('Chuyển đổi hai chiều nhất quán', () {
    test('Quét toàn bộ 2020-2030', () {
      var d = DateTime(2020, 1, 1);
      final end = DateTime(2030, 12, 31);
      while (!d.isAfter(end)) {
        final l = LunarCore.solarToLunar(d.day, d.month, d.year);
        final s = LunarCore.lunarToSolar(l[0], l[1], l[2], l[3]);
        expect(s, [d.day, d.month, d.year],
            reason: 'Sai tại ${d.day}/${d.month}/${d.year} -> $l');
        d = d.add(const Duration(days: 1));
      }
    });
  });

  group('Can chi', () {
    test('Năm', () {
      expect(CanChi.ofYear(2024), 'Giáp Thìn');
      expect(CanChi.ofYear(2025), 'Ất Tỵ');
      expect(CanChi.ofYear(1945), 'Ất Dậu');
    });

    test('Ngày', () {
      // Mốc chuẩn: 01/01/2000 là ngày Mậu Ngọ (jd 2451545)
      expect(CanChi.ofDay(LunarCore.jdFromDate(1, 1, 2000)), 'Mậu Ngọ');
      expect(CanChi.ofDay(LunarCore.jdFromDate(1, 1, 2025)), 'Canh Ngọ');
    });
  });

  group('LunarDate model', () {
    test('Ngày âm không tồn tại trả về null', () {
      // Tháng 2/2025 âm là tháng thiếu (29 ngày)
      expect(LunarDate.fromLunar(30, 2, 2025, false), isNull);
      // Tháng 1/2025 âm là tháng đủ (30 ngày)
      expect(LunarDate.fromLunar(30, 1, 2025, false), isNotNull);
    });

    test('Giờ hoàng đạo luôn có 6 khung giờ', () {
      final d = LunarDate.fromSolar(DateTime(2025, 7, 7));
      expect(d.gioHoangDao.length, 6);
    });
  });
}
