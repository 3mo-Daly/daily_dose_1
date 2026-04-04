import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_dose/l10n/app_localizations.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/settings/settings_cubit.dart';
import '../../report/view/report_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.navMore),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: Text(loc.navReport, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportPage()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              loc.settings,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: Text(loc.darkMode, style: const TextStyle(fontWeight: FontWeight.w500)),
                secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                value: isDark,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool value) {
                  context.read<ThemeCubit>().toggleTheme(!value);
                },
              );
            },
          ),
          BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              final isEnglish = locale.languageCode == 'en';
              return ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(loc.language, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(loc.english)),
                    ButtonSegment(value: 'ar', label: Text(loc.arabic)),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (Set<String> selection) {
                    if (selection.first != locale.languageCode) {
                      context.read<LocaleCubit>().toggleLocale();
                    }
                  },
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              loc.textSize,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<SettingsCubit, double>(
            builder: (context, textScale) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.text_decrease_rounded, size: 20),
                    Expanded(
                      child: Slider(
                        value: textScale,
                        min: 1.0,
                        max: 1.4,
                        divisions: 4,
                        activeColor: Theme.of(context).colorScheme.primary,
                        label: "${textScale}x",
                        onChanged: (val) {
                          context.read<SettingsCubit>().updateTextScale(val);
                        },
                      ),
                    ),
                    const Icon(Icons.text_increase_rounded, size: 30),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
