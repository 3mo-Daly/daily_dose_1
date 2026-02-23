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
import 'core/theme/theme_cubit.dart';
import 'core/theme/app_theme.dart';

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
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'The Daily Dose',
            debugShowCheckedModeBanner: false,
            theme: appTheme, // Using customized light AppTheme from specifications
            darkTheme: ThemeData( // Keep dark theme distinct but using base Material 3 rules
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.accent,
                surface: const Color(0xFF1E1E1E),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF121212),
                foregroundColor: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            themeMode: themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
