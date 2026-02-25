import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upse_prep_app/features/auth/data/auth_repository.dart';
import 'package:upse_prep_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:upse_prep_app/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>(
        create: (_) => HiveAuthRepository(),
        child: BlocProvider(
          create: (context) => AuthCubit(context.read<AuthRepository>()),
          child: const MaterialApp(home: LoginScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
