import 'package:flutter/material.dart';

import '../models/lunar_date.dart';

/// Màn hình chuyển đổi hai chiều dương lịch ↔ âm lịch.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  bool _solarToLunar = true;
  int _day = DateTime.now().day;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  bool _leapMonth = false;

  LunarDate? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _convert() {
    setState(() {
      _error = null;
      if (_solarToLunar) {
        try {
          final date = DateTime(_year, _month, _day);
          if (date.day != _day || date.month != _month) {
            throw ArgumentError();
          }
          _result = LunarDate.fromSolar(date);
        } catch (_) {
          _result = null;
          _error = 'Ngày dương lịch không hợp lệ';
        }
      } else {
        final r = LunarDate.fromLunar(_day, _month, _year, _leapMonth);
        _result = r;
        if (r == null) {
          _error = _leapMonth
              ? 'Tháng $_month năm $_year không phải tháng nhuận, '
                  'hoặc ngày không tồn tại'
              : 'Ngày âm lịch không tồn tại';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi ngày âm - dương')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Dương → Âm')),
              ButtonSegment(value: false, label: Text('Âm → Dương')),
            ],
            selected: {_solarToLunar},
            onSelectionChanged: (s) {
              setState(() => _solarToLunar = s.first);
              _convert();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Ngày',
                  value: _day,
                  min: 1,
                  max: 31,
                  onChanged: (v) {
                    _day = v;
                    _convert();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _numberField(
                  label: 'Tháng',
                  value: _month,
                  min: 1,
                  max: 12,
                  onChanged: (v) {
                    _month = v;
                    _convert();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _numberField(
                  label: 'Năm',
                  value: _year,
                  min: 1900,
                  max: 2100,
                  onChanged: (v) {
                    _year = v;
                    _convert();
                  },
                ),
              ),
            ],
          ),
          if (!_solarToLunar)
            SwitchListTile(
              title: const Text('Tháng nhuận'),
              value: _leapMonth,
              onChanged: (v) {
                _leapMonth = v;
                _convert();
              },
            ),
          const SizedBox(height: 16),
          if (_error != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style:
                      TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            )
          else if (_result != null)
            _buildResult(theme, _result!),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (text) {
        final v = int.tryParse(text);
        if (v != null && v >= min && v <= max) {
          onChanged(v);
        }
      },
    );
  }

  Widget _buildResult(ThemeData theme, LunarDate r) {
    const weekdays = [
      'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm',
      'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật',
    ];
    final title = _solarToLunar
        ? 'Ngày ${r.day} tháng ${r.monthLabel} năm ${r.canChiYear}'
        : '${weekdays[r.solar.weekday - 1]}, ngày ${r.solar.day} '
            'tháng ${r.solar.month} năm ${r.solar.year}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _solarToLunar ? 'Âm lịch' : 'Dương lịch',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _row('Ngày', r.canChiDay),
            _row('Tháng', r.canChiMonth),
            _row('Năm', r.canChiYear),
            _row('Tiết khí', r.tietKhi),
            _row(
              'Trực thần',
              '${r.thanTrucNgay} — '
                  '${r.isHoangDao ? "Hoàng đạo" : "Hắc đạo"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
