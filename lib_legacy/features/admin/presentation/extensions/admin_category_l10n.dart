import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

/// Localized label of the category a moderated product was filed under.
///
/// [AdminProduct.category] is recorded as free text by the submitter, so the
/// wording is matched against the catalogue categories — by enum name, and by
/// their label in the current language — rather than carried as an enum. A
/// category that names none of them keeps the wording it was recorded with: an
/// unknown category must stay readable in the queue rather than become an empty
/// chip.
String adminCategoryLabel(AppLocalizations l10n, String category) {
  final key = _fold(category);
  for (final value in CatalogCategory.values) {
    if (_fold(value.name) == key || _fold(value.label(l10n)) == key) {
      return value.label(l10n);
    }
  }
  return category;
}

/// Lowercases and drops the accents, so "Cereales", "céréales" and "Cereals"
/// are recognised as the same category whatever the input language.
String _fold(String value) {
  const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyy';
  final lower = value.trim().toLowerCase();
  final folded = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    final index = from.indexOf(character);
    folded.write(index == -1 ? character : to[index]);
  }
  return folded.toString();
}
