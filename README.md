# Lịch Vạn Niên

Ứng dụng lịch vạn niên cho iOS & Android, viết bằng Flutter.

## Tính năng

- **Hôm nay** — xem chi tiết một ngày: ngày âm lịch, can chi ngày/tháng/năm,
  tiết khí, trực thần (ngày hoàng đạo / hắc đạo), giờ hoàng đạo, các ngày lễ
  dương lịch & âm lịch của Việt Nam. Vuốt trái/phải để chuyển ngày.
- **Lịch tháng** — lưới lịch tháng hiển thị kèm ngày âm, đánh dấu ngày
  hoàng đạo (chấm xanh) và ngày lễ (viền đỏ). Chạm vào ngày để xem chi tiết.
- **Đổi ngày** — chuyển đổi hai chiều dương lịch ↔ âm lịch, hỗ trợ tháng
  nhuận, phạm vi 1900–2100.

## Thuật toán

Chuyển đổi âm - dương lịch dùng thuật toán tính toán thiên văn của
Hồ Ngọc Đức (tính điểm sóc và kinh độ mặt trời), múi giờ +7 (Việt Nam).
Không phụ thuộc bảng tra cứu nên hoạt động chính xác với mọi năm trong
phạm vi hỗ trợ, kể cả tháng nhuận.

- `lib/core/lunar_core.dart` — đổi dương ↔ âm, tính điểm sóc, tiết khí
- `lib/core/can_chi.dart` — can chi, giờ hoàng đạo, trực thần
- `lib/core/events.dart` — ngày lễ dương lịch & âm lịch
- `lib/models/lunar_date.dart` — model gộp thông tin một ngày

## Chạy ứng dụng

```sh
flutter pub get
flutter run            # chạy trên thiết bị/emulator đang kết nối
flutter test           # chạy unit test + widget test
flutter build apk      # build Android
flutter build ios      # build iOS (cần Xcode)
```

## Ghi chú

Kết quả âm lịch tính theo múi giờ +7. Với các ngày lịch sử trước 6/1975,
lịch miền Nam dùng múi giờ +8 nên một số ngày có thể lệch 1 ngày so với
tài liệu cũ.
