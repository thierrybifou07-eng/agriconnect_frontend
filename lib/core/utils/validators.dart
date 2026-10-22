import 'package:agri_connect/core/localization/generated/app_localizations.dart';

/// Validator signature used by form fields across the app.
typedef FieldValidator = String? Function(String? value);

final class Validators {
  Validators._();

  static const int _passwordMinLength = 8;
  static const int _nameMinLength = 2;
  static const int _nameMaxLength = 80;
  static const int _productNameMaxLength = 80;

  static FieldValidator email(AppLocalizations l10n) => (value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.validationEmailRequired;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(input)) return l10n.validationEmailInvalid;
    return null;
  };

  static FieldValidator password(AppLocalizations l10n) => (value) {
    final input = value ?? '';
    if (input.isEmpty) return l10n.validationPasswordRequired;
    if (input.length < _passwordMinLength) {
      return l10n.validationPasswordTooShort;
    }
    return null;
  };

  static FieldValidator name(AppLocalizations l10n) => (value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.validationNameRequired;
    if (input.length < _nameMinLength) return l10n.validationNameTooShort;
    if (input.length > _nameMaxLength) return l10n.validationNameTooLong;
    return null;
  };

  static FieldValidator confirmPassword(
    String? Function() password,
    AppLocalizations l10n,
  ) => (value) {
    if ((value ?? '') != password()) return l10n.validationPasswordMismatch;
    return null;
  };

  static FieldValidator productName(AppLocalizations l10n) => (value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.validationProductNameRequired;
    if (input.length > _productNameMaxLength) {
      return l10n.validationProductNameTooLong;
    }
    return null;
  };

  static FieldValidator price(AppLocalizations l10n) => (value) {
    final input = (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.');
    if (input.isEmpty) return l10n.validationPriceInvalid;
    final parsed = double.tryParse(input);
    if (parsed == null) return l10n.validationPriceInvalid;
    if (parsed <= 0) return l10n.validationPricePositive;
    return null;
  };

  static FieldValidator stock(AppLocalizations l10n) => (value) {
    final input = (value ?? '').trim().replaceAll(' ', '');
    if (input.isEmpty) return l10n.validationStockInvalid;
    final parsed = int.tryParse(input);
    if (parsed == null || parsed < 0) return l10n.validationStockInvalid;
    return null;
  };

  static FieldValidator address(AppLocalizations l10n) => (value) {
    if ((value ?? '').trim().isEmpty) return l10n.validationAddressRequired;
    return null;
  };

  static FieldValidator phone(AppLocalizations l10n) => (value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return l10n.validationPhoneRequired;
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) return l10n.validationPhoneInvalid;
    return null;
  };
}
