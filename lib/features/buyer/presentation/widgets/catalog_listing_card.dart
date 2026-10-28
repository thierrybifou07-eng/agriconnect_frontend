import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';

class CatalogListingCard extends StatelessWidget {
  const CatalogListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  final CatalogListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final image = listing.images.isEmpty
        ? null
        : MediaUrl.resolve(listing.images.first);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.7,
              child: image == null
                  ? const ColoredBox(
                      color: Color(0xFFE8F0E8),
                      child: Center(
                        child: Icon(Icons.image_outlined, size: 40),
                      ),
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Color(0xFFE8F0E8),
                        child: Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${Money.format(listing.unitPrice)} / ${listing.unit.label}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    l10n.catalogProductStock(
                      _quantity(listing.quantityAvailable),
                      listing.unit.label,
                    ),
                  ),
                  Text('${listing.zone.name}, ${listing.zone.city}'),
                  if (listing.expiresAt != null)
                    Text(
                      l10n.catalogExpiry(
                        MaterialLocalizations.of(context)
                            .formatShortDate(listing.expiresAt!.toLocal()),
                      ),
                    ),
                  if (listing.qualityGrade != null)
                    Text(l10n.catalogQualityGrade(listing.qualityGrade!)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _quantity(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}
