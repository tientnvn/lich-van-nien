import 'package:flutter/material.dart';

import '../core/events.dart';
import '../models/lunar_date.dart';

/// Lưới lịch tháng: ngày dương lớn, ngày âm nhỏ bên dưới.
class MonthScreen extends StatefulWidget {
  final ValueChanged<DateTime> onDaySelected;

  const MonthScreen({super.key, required this.onDaySelected});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visibleMonth,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _visibleMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _pickMonth,
          child: Text('Tháng ${_visibleMonth.month}/${_visibleMonth.year}'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Về tháng hiện tại',
        onPressed: () {
          final now = DateTime.now();
          setState(() => _visibleMonth = DateTime(now.year, now.month));
        },
        child: const Icon(Icons.today),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -100) _changeMonth(1);
          if (v > 100) _changeMonth(-1);
        },
        child: Column(
          children: [
            _buildWeekdayHeader(theme),
            const Divider(height: 1),
            Expanded(child: _buildGrid(theme)),
            _buildLegend(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: i == 6 ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(ThemeData theme) {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = first.weekday - 1; // T2 = cột đầu
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: rows <= 5 ? 0.75 : 0.85,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayNum = index - leadingEmpty + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox.shrink();
        }
        final date =
            DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
        final lunar = LunarDate.fromSolar(date);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSunday = date.weekday == 7;
        final hasEvent = VnEvents.hasEvent(lunar);
        final lunarLabel = lunar.day == 1
            ? '${lunar.day}/${lunar.monthLabel}'
            : '${lunar.day}';

        return InkWell(
          onTap: () => widget.onDaySelected(date),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday ? theme.colorScheme.primary : null,
              border: hasEvent && !isToday
                  ? Border.all(color: theme.colorScheme.primary, width: 1)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isToday
                        ? Colors.white
                        : isSunday
                            ? theme.colorScheme.primary
                            : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lunarLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday
                        ? Colors.white70
                        : lunar.day == 1 || lunar.day == 15
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.outline,
                    fontWeight: lunar.day == 1 || lunar.day == 15
                        ? FontWeight.bold
                        : null,
                  ),
                ),
                if (lunar.isHoangDao)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? Colors.white : Colors.green,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 4),
          const Text('Ngày hoàng đạo', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          const Text('Ngày lễ', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
