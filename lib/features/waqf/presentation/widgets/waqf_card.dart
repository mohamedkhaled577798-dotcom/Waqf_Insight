import 'package:flutter/material.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';

/// Reusable card widget for displaying a Waqf item summary.
class WaqfCard extends StatelessWidget {
  final WaqfEntity waqf;
  final VoidCallback? onTap;

  const WaqfCard({
    super.key,
    required this.waqf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      waqf.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      waqf.status,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                waqf.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer info
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(waqf.location, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Icon(Icons.category_outlined,
                      size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(waqf.type, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
