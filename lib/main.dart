import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';
import 'core/network/logged_dio_factory.dart';
import 'core/storage/hive_boxes.dart';
import 'features/ai/data/ai_engine.dart';
import 'features/ai/presentation/bloc/ai_cubit.dart';
import 'features/analytics/presentation/bloc/analytics_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/current_affairs/data/current_affairs_repository.dart';
import 'features/current_affairs/presentation/bloc/current_affairs_cubit.dart';
import 'features/mcq/data/mcq_repository.dart';
import 'features/mcq/presentation/bloc/mcq_cubit.dart';
import 'features/news/data/news_repository.dart';
import 'features/news/presentation/bloc/news_cubit.dart';
import 'features/pyq/data/pyq_repository.dart';
import 'features/pyq/presentation/bloc/pyq_home_cubit.dart';
import 'features/pyq/presentation/bloc/pyq_test_cubit.dart';
import 'features/subjects/data/subjects_repository.dart';
import 'features/subjects/presentation/bloc/subjects_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveBoxes.openAll();
  const currentAffairsApiBaseUrl = String.fromEnvironment(
    'CURRENT_AFFAIRS_API_BASE_URL',
  );
  const enableDemoCurrentAffairs = bool.fromEnvironment(
    'ENABLE_DEMO_CURRENT_AFFAIRS',
    defaultValue: false,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => HiveAuthRepository()),
        RepositoryProvider<SubjectsRepository>(
          create: (_) => DemoSubjectsRepository(),
        ),
        RepositoryProvider<McqRepository>(create: (_) => DemoMcqRepository()),
        RepositoryProvider<NewsRepository>(
          create: (_) => RssNewsRepository(dio: LoggedDioFactory.create('News')),
        ),
        RepositoryProvider<CurrentAffairsRepository>(
          create: (_) {
            final currentAffairsDio = LoggedDioFactory.create('CurrentAffairs');
            final apiDio = LoggedDioFactory.create('CurrentAffairsApi');
            final openRss = OpenRssCurrentAffairsRepository(dio: currentAffairsDio);
            final fallback = enableDemoCurrentAffairs
                ? FallbackCurrentAffairsRepository(
                    primary: openRss,
                    fallback: DemoCurrentAffairsRepository(),
                  )
                : openRss;
            AppLogger.info(
              'Main',
              'Current affairs repository initialized. '
              'apiBase=${currentAffairsApiBaseUrl.isEmpty ? 'none' : 'configured'} '
              'demoFallback=${enableDemoCurrentAffairs ? 'enabled' : 'disabled'}',
            );
            if (currentAffairsApiBaseUrl.isEmpty) {
              return fallback;
            }
            return FallbackCurrentAffairsRepository(
              primary: ApiCurrentAffairsRepository(
                dio: apiDio,
                baseUrl: currentAffairsApiBaseUrl,
              ),
              fallback: fallback,
            );
          },
        ),
        RepositoryProvider<AiEngine>(create: (_) => DemoAiEngine()),
        RepositoryProvider<PyqRepository>(create: (_) => DemoPyqRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<SubjectsCubit>(
            create:
                (context) => SubjectsCubit(context.read<SubjectsRepository>()),
          ),
          BlocProvider<McqCubit>(
            create: (context) => McqCubit(context.read<McqRepository>()),
          ),
          BlocProvider<NewsCubit>(
            create: (context) => NewsCubit(context.read<NewsRepository>()),
          ),
          BlocProvider<CurrentAffairsCubit>(
            create:
                (context) => CurrentAffairsCubit(
                  context.read<CurrentAffairsRepository>(),
                ),
          ),
          BlocProvider<AiCubit>(
            create: (context) => AiCubit(context.read<AiEngine>()),
          ),
          BlocProvider<AnalyticsCubit>(create: (_) => AnalyticsCubit()),
          BlocProvider<PyqHomeCubit>(
            create: (context) => PyqHomeCubit(context.read<PyqRepository>()),
          ),
          BlocProvider<PyqTestCubit>(
            create: (context) => PyqTestCubit(context.read<PyqRepository>()),
          ),
        ],
        child: const UpscPrepApp(),
      ),
    ),
  );
}
