import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class UpscPrepApp extends StatelessWidget {
  const UpscPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: createAppRouter(isLoggedIn: authState.isLoggedIn),
        );
      },
    );
  }
}
