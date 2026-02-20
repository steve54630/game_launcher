import 'package:flutter/material.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:intl/intl.dart';

class GameReleaseDate extends StatelessWidget {
  final DateTime? date;

  const GameReleaseDate({super.key, this.date});

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 12,
          color: AppColors.textPrimary.withAlpha(128),
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('yyyy').format(date!),
          style: TextStyle(
            color: AppColors.textPrimary.withAlpha(128),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
