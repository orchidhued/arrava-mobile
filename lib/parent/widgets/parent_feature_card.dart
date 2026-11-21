import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ParentFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String? metric;
  final bool showArrow;
  final VoidCallback? onTap;

  const ParentFeatureCard({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    this.metric,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow3D, offset: Offset(0, 4)),
        ],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: showArrow ? 172 : 126),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: showArrow
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(icon, size: 21, color: color),
                        ),
                      ),
                      if (metric != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  metric!,
                                  textAlign: TextAlign.center,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (showArrow) ...[
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: color,
                        size: 19,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParentFeatureGrid extends StatelessWidget {
  final List<ParentFeatureCard> children;
  final int maxColumns;

  const ParentFeatureGrid({
    super.key,
    required this.children,
    this.maxColumns = 2,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + gap) / (138 * textScale + gap))
            .floor()
            .clamp(1, maxColumns);
        return Column(
          spacing: gap,
          children: [
            for (var start = 0; start < children.length; start += columns)
              IntrinsicHeight(
                child: Row(
                  spacing: gap,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0; column < columns; column++)
                      Expanded(
                        child: start + column < children.length
                            ? children[start + column]
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
