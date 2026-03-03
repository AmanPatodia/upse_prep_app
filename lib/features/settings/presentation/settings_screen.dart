import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/bloc/auth_cubit.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'bloc/app_preferences_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      builder: (context, prefs) {
        return SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const SectionHeader(title: 'Settings'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ThemeMode>(
                        value: prefs.themeMode,
                        decoration: const InputDecoration(
                          labelText: 'Theme Mode',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Auto (Smart)'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            context.read<AppPreferencesCubit>().setThemeMode(mode);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading Preferences',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Font Size (${prefs.fontScale.toStringAsFixed(2)}x)',
                      ),
                      Slider(
                        value: prefs.fontScale,
                        min: 0.85,
                        max: 1.4,
                        divisions: 11,
                        label: '${prefs.fontScale.toStringAsFixed(2)}x',
                        onChanged:
                            (value) => context
                                .read<AppPreferencesCubit>()
                                .setFontScale(value),
                      ),
                      Text(
                        'Line Spacing (${prefs.lineHeight.toStringAsFixed(2)})',
                      ),
                      Slider(
                        value: prefs.lineHeight,
                        min: 1.1,
                        max: 2.0,
                        divisions: 9,
                        label: prefs.lineHeight.toStringAsFixed(2),
                        onChanged:
                            (value) => context
                                .read<AppPreferencesCubit>()
                                .setLineHeight(value),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
                          onPressed: () async {
                            final authCubit = context.read<AuthCubit>();
                            final router = GoRouter.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text(
                                    'Are you sure you want to log out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(true);
                                      },
                                      child: const Text('Log Out'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed != true) return;
                            await authCubit.logout();
                            router.go('/onboarding');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
