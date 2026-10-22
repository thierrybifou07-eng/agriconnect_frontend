import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/shared/widgets/welcome_page_layout.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final selected = ref.watch(
      welcomeControllerProvider.select((s) => s.languageCode),
    );

    final languages = [
      (
        code: 'fr',
        label: l10n.languageFrench,
        mark: 'FR',
        markColor: colorScheme.primaryContainer,
      ),
      (
        code: 'en',
        label: l10n.languageEnglish,
        mark: 'EN',
        markColor: colorScheme.primaryContainer,
      ),
    ];

    return WelcomePageLayout(
      title: l10n.languageTitle,
      subtitle: l10n.languageSubtitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < languages.length; index++) ...[
            _LanguageCard(
              language: languages[index],
              selected: selected == languages[index].code,
              onTap: () => ref
                  .read(welcomeControllerProvider.notifier)
                  .selectLanguage(languages[index].code),
            ),
            if (index != languages.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final ({String code, String label, String mark, Color markColor}) language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: language.markColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    language.mark,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
