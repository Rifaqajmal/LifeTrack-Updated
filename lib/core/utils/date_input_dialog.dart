import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

/// Opens a day-first date dialog (DD/MM/YYYY). Slashes are added while typing,
/// and a calendar button opens the normal picker. Returns null if cancelled.
Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initial,
  String title = 'Select date',
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _DateInputDialog(initial: initial, title: title),
  );
}

/// Turns digits into DD/MM/YYYY as the user types (max 8 digits).
class _DayFirstFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final typingForward = digits.length > oldDigits.length;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    // Add the slash right after the 2nd and 4th digit, but only while typing
    // forward, so backspace can still delete it.
    if (typingForward && (digits.length == 2 || digits.length == 4)) {
      buf.write('/');
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _DateInputDialog extends StatefulWidget {
  const _DateInputDialog({required this.initial, required this.title});

  final DateTime? initial;
  final String title;

  @override
  State<_DateInputDialog> createState() => _DateInputDialogState();
}

class _DateInputDialogState extends State<_DateInputDialog> {
  late final TextEditingController _controller;
  String? _error;

  static final DateTime _first = DateTime(1900);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.initial == null ? '' : _format(widget.initial!));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _format(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';

  /// Parses DD/MM/YYYY; returns null when it isn't a real date.
  DateTime? _parse(String text) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (m == null) return null;
    final d = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final y = int.parse(m.group(3)!);
    final date = DateTime(y, mo, d);
    // Rejects things like 31/02/2000 which DateTime would roll over.
    if (date.year != y || date.month != mo || date.day != d) return null;
    return date;
  }

  void _ok() {
    final date = _parse(_controller.text.trim());
    final today = DateTime.now();
    final last = DateTime(today.year, today.month, today.day);
    if (date == null) {
      setState(() => _error = 'Enter a real date like 26/12/2002');
    } else if (date.isBefore(_first) || date.isAfter(last)) {
      setState(() => _error = 'Date must be between 1900 and today');
    } else {
      Navigator.pop(context, date);
    }
  }

  Future<void> _openCalendar() async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final current = _parse(_controller.text.trim());
    final picked = await showDatePicker(
      context: context,
      firstDate: _first,
      lastDate: today,
      initialDate: current ?? widget.initial ?? DateTime(2000),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && mounted) {
      setState(() {
        _controller.text = _format(picked);
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [_DayFirstFormatter()],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _ok(),
            decoration: InputDecoration(
              labelText: 'Date (DD/MM/YYYY)',
              hintText: '26/12/2002',
              errorText: _error,
              suffixIcon: IconButton(
                tooltip: 'Open calendar',
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: _openCalendar,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type only the numbers, slashes are added for you.',
            style: TextStyle(color: lt.text2, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _ok, child: const Text('OK')),
      ],
    );
  }
}
