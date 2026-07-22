import 'dart:async';

import 'package:flutter/material.dart';

class RelativeTimestamp extends StatefulWidget {
  const RelativeTimestamp({required this.dateTime, this.style, super.key});

  final DateTime dateTime;
  final TextStyle? style;

  @override
  State<RelativeTimestamp> createState() => _RelativeTimestampState();
}

class _RelativeTimestampState extends State<RelativeTimestamp> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.dateTime.toLocal();
    final exact = MaterialLocalizations.of(context).formatFullDate(local);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: false,
    );

    return Tooltip(
      message: '$exact at $time',
      child: Text(_label(context, local), style: widget.style),
    );
  }

  String _label(BuildContext context, DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.isNegative || difference.inSeconds < 5) return 'Just now';
    if (difference.inMinutes < 1) return '${difference.inSeconds} seconds ago';
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    final date = MaterialLocalizations.of(context).formatMediumDate(dateTime);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
    return '$date • $time';
  }
}
