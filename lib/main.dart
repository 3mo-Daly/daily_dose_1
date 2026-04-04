import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/profile_model.dart';
import 'models/medicine_model.dart';
import 'core/services/notification_service.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/add_medicine/cubit/add_medicine_cubit.dart';
import 'features/main/view/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daily_dose/l10n/app_localizations.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(MedicineAdapter());

  // Open Boxes
  await Hive.openBox<Profile>('profiles');
  await Hive.openBox<Medicine>('medicines');

  // Check if profiles exist, if not create default
  var profileBox = Hive.box<Profile>('profiles');
  var medicineBox = Hive.box<Medicine>('medicines');

  if (profileBox.isEmpty) {
    profileBox.put('default', Profile(id: 'default', name: 'Me'));
  }

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MyApp(
      profileBox: profileBox,
      medicineBox: medicineBox,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box<Profile> profileBox;
  final Box<Medicine> medicineBox;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.profileBox,
    required this.medicineBox,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProfileCubit(profileBox: profileBox)..loadProfiles(),
        ),
        BlocProvider(create: (context) => HomeCubit(medicineBox: medicineBox)),
        BlocProvider(
          create: (context) => AddMedicineCubit(
            medicineBox: medicineBox,
            notificationService: notificationService,
          ),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'The Daily Dose',
                debugShowCheckedModeBanner: false,
                locale: locale,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                theme:
                    appTheme, // Using customized light AppTheme from specifications
                darkTheme: darkAppTheme, // Using Modern Clinic Dark Theme
                themeMode: themeMode,
                home: const MainScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
