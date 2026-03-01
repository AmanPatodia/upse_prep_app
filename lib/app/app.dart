import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/settings/presentation/bloc/app_preferences_cubit.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class UpscPrepApp extends StatefulWidget {
  const UpscPrepApp({super.key});

  @override
  State<UpscPrepApp> createState() => _UpscPrepAppState();
}

class _UpscPrepAppState extends State<UpscPrepApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(authCubit: context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      builder: (context, prefs) {
        final resolvedThemeMode = prefs.themeMode == ThemeMode.system
            ? AppTheme.smartMode()
            : prefs.themeMode;
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: resolvedThemeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
