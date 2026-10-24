import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

extension ProductStatusColorX on ProductStatus {
  Color color(BuildContext context) => switch (this) {
    ProductStatus.onSale => AppColors.success,
    ProductStatus.outOfStock => AppColors.warning,
  };
}

extension DeclarationStatusColorX on DeclarationStatus {
  Color color(BuildContext context) => switch (this) {
    DeclarationStatus.draft => AppColors.neutral,
    DeclarationStatus.pendingReview => AppColors.warning,
    DeclarationStatus.additionalInfoRequired => AppColors.warm,
    DeclarationStatus.underDiscussion => AppColors.violet,
    DeclarationStatus.approvedForPublication => AppColors.success,
    DeclarationStatus.rejected => AppColors.danger,
  };
}

extension OrderStatusColorX on OrderStatus {
  Color color(BuildContext context) => switch (this) {
    OrderStatus.pending => AppColors.warning,
    OrderStatus.confirmed => AppColors.success,
    OrderStatus.cancelled => AppColors.danger,
  };
}

/// Small pill used to surface a status in lists and cards.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // The label and glyph are darkened from the status colour so the pair keeps
    // a readable contrast on the pale tinted background, whatever tone the
    // caller hands over. The tinted fill itself stays light, so a wall of
    // badges never shouts.
    final foreground = Color.lerp(color, Colors.black, 0.28)!;
    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: 4),
              ],
              // The label gives up characters before it gives up its box, so a
              // badge squeezed by a narrow list never overflows.
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
