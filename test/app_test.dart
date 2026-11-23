import 'package:flutter_test/flutter_test.dart';
import 'package:lich_van_nien/main.dart';

void main() {
  testWidgets('App khởi động và hiển thị 3 tab', (tester) async {
    await tester.pumpWidget(const LichVanNienApp());
    await tester.pumpAndSettle();

    expect(find.text('Lịch Vạn Niên'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.text('Lịch tháng'), findsOneWidget);
    expect(find.text('Đổi ngày'), findsOneWidget);
    expect(find.textContaining('Âm lịch: ngày'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Giờ hoàng đạo'), 200);
    expect(find.text('Giờ hoàng đạo'), findsOneWidget);
  });

  testWidgets('Chuyển sang tab Lịch tháng và Đổi ngày', (tester) async {
    await tester.pumpWidget(const LichVanNienApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lịch tháng'));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    expect(find.text('Tháng ${now.month}/${now.year}'), findsOneWidget);

    await tester.tap(find.text('Đổi ngày'));
    await tester.pumpAndSettle();
    expect(find.text('Dương → Âm'), findsOneWidget);
    expect(find.text('Âm lịch'), findsOneWidget);
  });
}
