import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/profile_model.dart';
import 'models/medicine_model.dart';
import 'core/services/notification_service.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/add_medicine/cubit/add_medicine_cubit.dart';
import 'features/splash/view/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daily_dose/l10n/app_localizations.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_cubit.dart';
import 'core/settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load date/time symbol data for all locales so DateFormat renders correctly
  // in Arabic (Arabic-Indic digits, ص/م) as well as English.
  await initializeDateFormatting();

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

  await Hive.openBox('settings');
  var settingsBox = Hive.box('settings');

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MyApp(
      profileBox: profileBox,
      medicineBox: medicineBox,
      settingsBox: settingsBox,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final Box<Profile> profileBox;
  final Box<Medicine> medicineBox;
  final Box settingsBox;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.profileBox,
    required this.medicineBox,
    required this.settingsBox,
    required this.notificationService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // A stable key keeps the Navigator alive across MaterialApp rebuilds
  // (theme/locale changes). Without it, open bottom-sheets and dialogs
  // hold a stale BuildContext and crash when the Navigator is recreated.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProfileCubit(profileBox: widget.profileBox)..loadProfiles(),
        ),
        BlocProvider(
          create: (context) => HomeCubit(medicineBox: widget.medicineBox),
        ),
        BlocProvider(
          create: (context) => AddMedicineCubit(
            medicineBox: widget.medicineBox,
            notificationService: widget.notificationService,
          ),
        ),
        BlocProvider(create: (_) => ThemeCubit(widget.settingsBox)),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => SettingsCubit(widget.settingsBox)),
      ],
      // The app shell is a stable const-constructed widget: MultiBlocProvider
      // rebuilding never forces it to rebuild. Only the theme/locale watches
      // inside it drive rebuilds of the MaterialApp.
      child: _ElagyApp(navigatorKey: _navigatorKey),
    );
  }
}

class _ElagyApp extends StatelessWidget {
  const _ElagyApp({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    // A single rebuild scope for both theme and locale (flattened from two
    // nested BlocBuilders). Cubits only emit on an actual change, so this
    // rebuilds the MaterialApp only when the theme or locale really changes.
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Elagy',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: themeMode,
      // Swap themes in a single frame. The default 200ms cross-fade re-lerps
      // every themed widget (all the soft shadows/containers) each frame,
      // which is what was dropping frames on toggle.
      themeAnimationDuration: Duration.zero,
      builder: (context, child) {
        // Scoped to text-scale only: changing the slider rebuilds just this
        // MediaQuery wrapper, not the whole MaterialApp.
        final textScale = context.watch<SettingsCubit>().state;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
