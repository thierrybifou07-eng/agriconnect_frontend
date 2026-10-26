import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/catalog_controller.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';

class ListingDetailPage extends GetView<ListingDetailController> {
  const ListingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogListingDetail)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<CatalogListing> || state is Idle<CatalogListing>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Failure<CatalogListing>) {
          final message = state.failure.status == 404
              ? l10n.catalogListingUnavailable
              : AppNotifier.failureMessage(state.failure, l10n);
          return _DetailError(
            message: message,
            retry: state.failure.status == 404 ? null : controller.load,
          );
        }
        final listing = (state as Success<CatalogListing>).data;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ListingImages(images: listing.images),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(listing.reference),
                  const SizedBox(height: 12),
                  Text(
                    '${Money.format(listing.unitPrice)} / ${listing.unit.label}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.catalogProductStock(
                      _quantity(listing.quantityAvailable),
                      listing.unit.label,
                    ),
                  ),
                  Text(
                    '${listing.category.label} · ${listing.zone.name}, ${listing.zone.city}',
                  ),
                  if (listing.expiresAt != null)
                    Text(
                      l10n.catalogExpiry(
                        MaterialLocalizations.of(
                          context,
                        ).formatShortDate(listing.expiresAt!.toLocal()),
                      ),
                    ),
                  if (listing.qualityGrade != null)
                    Text(l10n.catalogQualityGrade(listing.qualityGrade!)),
                  if (listing.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Text(listing.description!),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _requestQuote(context, listing),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(l10n.catalogRequestQuote),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _requestQuote(
    BuildContext context,
    CatalogListing listing,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<(double, String?)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuoteRequestSheet(listing: listing),
    );
    if (result == null) return;
    final message = l10n.quoteRequestMessage(
      _quantity(result.$1),
      listing.unit.label,
      listing.title,
      listing.reference,
    );
    final content = result.$2?.trim().isNotEmpty == true
        ? '$message\n\n${result.$2!.trim()}'
        : message;
    try {
      await ChatLauncher.openForListing(listing.id, prefill: content);
    } on ApiFailure catch (failure) {
      AppNotifier.error(
        failure.status == 404
            ? l10n.catalogListingUnavailable
            : AppNotifier.failureMessage(failure, l10n),
      );
    }
  }

  static String _quantity(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}

class _ListingImages extends StatelessWidget {
  const _ListingImages({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox(
        height: 240,
        child: ColoredBox(
          color: Color(0xFFE8F0E8),
          child: Center(child: Icon(Icons.image_outlined, size: 56)),
        ),
      );
    }
    return SizedBox(
      height: 280,
      child: PageView(
        children: [
          for (final path in images)
            Builder(
              builder: (_) {
                final url = MediaUrl.resolve(path);
                return url == null
                    ? const Center(child: Icon(Icons.image_not_supported))
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      );
              },
            ),
        ],
      ),
    );
  }
}

class _QuoteRequestSheet extends StatefulWidget {
  const _QuoteRequestSheet({required this.listing});

  final CatalogListing listing;

  @override
  State<_QuoteRequestSheet> createState() => _QuoteRequestSheetState();
}

class _QuoteRequestSheetState extends State<_QuoteRequestSheet> {
  final _quantity = TextEditingController();
  final _message = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _quantity.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.catalogRequestQuote,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.quoteQuantityHint,
              suffixText: widget.listing.unit.label,
              border: const OutlineInputBorder(),
              errorText: _validationMessage,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            maxLength: 4500,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.quoteMessageHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(
                _quantity.text.trim().replaceAll(',', '.'),
              );
              if (amount == null || !amount.isFinite || amount <= 0) {
                setState(() {
                  _validationMessage = l10n.quoteRequestInvalidQuantity;
                });
                return;
              }
              Navigator.of(context).pop((amount, _message.text));
            },
            child: Text(l10n.catalogRequestQuote),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, this.retry});

  final String message;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
        if (retry != null)
          TextButton(
            onPressed: retry,
            child: Text(AppLocalizations.of(context).retry),
          ),
      ],
    ),
  );
}
