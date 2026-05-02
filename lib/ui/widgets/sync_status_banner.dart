import 'package:flutter/material.dart';

import '../../sync/sync_service.dart';
import '../../sync/sync_state.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncIndicatorSnapshot>(
      valueListenable: SyncService.instance.statusNotifier,
      builder: (context, snapshot, _) {
        final visual = _visual(snapshot.status);
        final compact = snapshot.status == SyncIndicatorStatus.online;

        return Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 8, right: 10),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF111826).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: visual.color.withValues(alpha: 0.45),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 7 : 8,
                    height: compact ? 7 : 8,
                    decoration: BoxDecoration(
                      color: visual.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    snapshot.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
                      fontSize: compact ? 11 : 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _VisualState _visual(SyncIndicatorStatus status) {
    switch (status) {
      case SyncIndicatorStatus.online:
        return const _VisualState(Color(0xFF35C759));
      case SyncIndicatorStatus.offline:
        return const _VisualState(Color(0xFFFF453A));
      case SyncIndicatorStatus.syncing:
        return const _VisualState(Color(0xFF0A84FF));
      case SyncIndicatorStatus.error:
        return const _VisualState(Color(0xFFFF9F0A));
    }
  }
}

class _VisualState {
  final Color color;
  const _VisualState(this.color);
}
