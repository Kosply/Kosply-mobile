/// @title AI history tile
/// @notice One Home AI thread row used in the overlay and the Home list.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/ai_thread.dart';
import '../theme/kosply_colors.dart';

/// @title AiHistoryTile
/// @notice Title, preview, and time for one AI thread.
class AiHistoryTile extends StatelessWidget {
  /// @notice Creates the history row.
  /// @param thread Thread to render.
  /// @param onTap Opens that thread in the AI overlay.
  /// @return A new {AiHistoryTile} instance.
  const AiHistoryTile({required this.thread, required this.onTap, super.key});

  /// @dev Thread to render.
  final AiThread thread;

  /// @dev Opens that thread in the AI overlay.
  final VoidCallback onTap;

  /// @notice Builds the row.
  /// @param context The build context.
  /// @return The row widget.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: KosplyColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              thread.timeLabel,
              style: TextStyle(
                fontSize: 12,
                color: KosplyColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
