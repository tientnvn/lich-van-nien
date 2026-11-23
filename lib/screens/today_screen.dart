import 'package:flutter/material.dart';

import '../core/events.dart';
import '../models/lunar_date.dart';

const _weekdayNames = [
  'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm',
  'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật',
];

/// Màn hình chi tiết một ngày (mặc định là hôm nay).
class TodayScreen extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const TodayScreen({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lunar = LunarDate.fromSolar(date);
    final events = VnEvents.eventsOf(lunar);
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Vạn Niên'),
        actions: [
          if (!isToday)
            IconButton(
              tooltip: 'Về hôm nay',
              icon: const Icon(Icons.restore),
              onPressed: () => onDateChanged(DateTime.now()),
            ),
          IconButton(
            tooltip: 'Chọn ngày',
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDateChanged(picked);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -100) {
            onDateChanged(date.add(const Duration(days: 1)));
          } else if (v > 100) {
            onDateChanged(date.subtract(const Duration(days: 1)));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(theme, lunar, isToday),
            const SizedBox(height: 12),
            _buildCanChiCard(theme, lunar),
            const SizedBox(height: 12),
            _buildGioHoangDaoCard(theme, lunar),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildEventsCard(theme, events),
            ],
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Vuốt trái/phải để xem ngày kế tiếp / trước đó',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, LunarDate lunar, bool isToday) {
    final cs = theme.colorScheme;
    final weekday = _weekdayNames[date.weekday - 1];
    return Card(
      color: cs.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              '$weekday${isToday ? ' — Hôm nay' : ''}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tháng ${date.month} năm ${date.year}',
              style:
                  theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const Divider(color: Colors.white24, height: 24),
            Text(
              'Âm lịch: ngày ${lunar.day} tháng ${lunar.monthLabel} '
              'năm ${lunar.canChiYear}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFFE082),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanChiCard(ThemeData theme, LunarDate lunar) {
    final hoangDao = lunar.isHoangDao;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Can chi & Tiết khí', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _infoRow('Ngày', lunar.canChiDay),
            _infoRow('Tháng', lunar.canChiMonth),
            _infoRow('Năm', lunar.canChiYear),
            _infoRow('Tiết khí', lunar.tietKhi),
            _infoRow(
              'Trực thần',
              '${lunar.thanTrucNgay} — '
                  '${hoangDao ? "Ngày Hoàng đạo" : "Ngày Hắc đạo"}',
              valueColor: hoangDao ? Colors.green.shade700 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGioHoangDaoCard(ThemeData theme, LunarDate lunar) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giờ hoàng đạo', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lunar.gioHoangDao
                  .map((g) => Chip(
                        label: Text(g),
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard(ThemeData theme, List<VnEvent> events) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sự kiện', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        e.isLunar ? Icons.brightness_3 : Icons.flag,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.name)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
