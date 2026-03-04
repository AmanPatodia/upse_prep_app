import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/config/firebase_env_options.dart';
import 'core/logging/app_logger.dart';
import 'core/constants/app_constants.dart';
import 'core/network/logged_dio_factory.dart';
import 'core/storage/hive_boxes.dart';
import 'features/ai/data/ai_engine.dart';
import 'features/ai/presentation/bloc/ai_cubit.dart';
import 'features/analytics/presentation/bloc/analytics_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/current_affairs/data/current_affairs_repository.dart';
import 'features/current_affairs/data/firestore_current_affairs_repository.dart';
import 'features/current_affairs/data/hive_cached_current_affairs_repository.dart';
import 'features/current_affairs/presentation/bloc/current_affairs_cubit.dart';
import 'features/mcq/data/mcq_repository.dart';
import 'features/mcq/presentation/bloc/mcq_cubit.dart';
import 'features/news/data/news_repository.dart';
import 'features/news/presentation/bloc/news_cubit.dart';
import 'features/pyq/data/pyq_repository.dart';
import 'features/pyq/presentation/bloc/pyq_home_cubit.dart';
import 'features/pyq/presentation/bloc/pyq_test_cubit.dart';
import 'features/settings/presentation/bloc/app_preferences_cubit.dart';
import 'features/subjects/data/subjects_repository.dart';
import 'features/subjects/presentation/bloc/subjects_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveBoxes.openAll();
  FirebaseFirestore? firestore;
  final options = FirebaseEnvOptions.maybeFromEnvironment();
  try {
    if (options == null) {
      await Firebase.initializeApp();
      AppLogger.info(
        'Main',
        'Firebase initialized from native config (google-services/plist)',
      );
    } else {
      await Firebase.initializeApp(options: options);
      AppLogger.info(
        'Main',
        'Firebase initialized from dart-defines FirebaseOptions',
      );
    }
    firestore = FirebaseFirestore.instance;
  } catch (error, stackTrace) {
    AppLogger.error(
      'Main',
      'Firebase init failed, continuing with non-Firestore repositories',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => HiveAuthRepository()),
        RepositoryProvider<SubjectsRepository>(
          create: (_) => DemoSubjectsRepository(),
        ),
        RepositoryProvider<McqRepository>(create: (_) => DemoMcqRepository()),
        RepositoryProvider<NewsRepository>(
          create:
              (_) => RssNewsRepository(dio: LoggedDioFactory.create('News')),
        ),
        RepositoryProvider<CurrentAffairsRepository>(
          create: (_) {
            if (firestore != null) {
              AppLogger.info(
                'Main',
                'Current affairs repository initialized with Firestore + Hive cache',
              );
              return FirestoreCurrentAffairsRepository(firestore: firestore);
            }

            AppLogger.warn(
              'Main',
              'Firestore is disabled/unavailable. Current affairs will load from Hive cache only.',
            );
            return HiveCachedCurrentAffairsRepository();
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
          BlocProvider<AppPreferencesCubit>(
            create:
                (_) => AppPreferencesCubit(Hive.box(AppConstants.settingsBox)),
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
