import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/installed_app_info.dart';

/// A single row in the App Lock app picker: icon, app name, lock switch.
class AppLockTile extends StatelessWidget {
  final InstalledAppInfo app;
  final bool isLocked;
  final ValueChanged<bool> onChanged;

  const AppLockTile({
    super.key,
    required this.app,
    required this.isLocked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: app.iconBytes != null
                ? Image.memory(
                    app.iconBytes!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.apps_rounded,
                      color: AppColors.textDisabled,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              app.appName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isLocked,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveTrackColor: AppColors.cardBorder,
            inactiveThumbColor: AppColors.textDisabled,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
