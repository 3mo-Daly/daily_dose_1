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
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00695C),
                primary: const Color(0xFF00695C),
                onPrimary: const Color(0xFFFFFFFF),
                secondary: const Color(0xFFFF7043),
                onSecondary: const Color(0xFFFFFFFF),
                surface: const Color(0xFFFFFFFF),
                onSurface: const Color(0xFF263238),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF5F7F8),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF00695C),
                foregroundColor: Color(0xFFFFFFFF),
                iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFFFFFFFF),
                elevation: 1,
                shadowColor: const Color(0xFF263238).withOpacity(0.15),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFFFFFFFF),
                selectedItemColor: const Color(0xFF00695C),
                unselectedItemColor: const Color(0xFF263238).withOpacity(0.6),
                elevation: 8,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFFFF7043),
                foregroundColor: Color(0xFFFFFFFF),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: const Color(0xFFFFFFFF),
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF263238)),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4DB6AC),
                primary: const Color(0xFF4DB6AC),
                onPrimary: const Color(0xFF121212),
                secondary: const Color(0xFFFF8A65),
                onSecondary: const Color(0xFF121212),
                surface: const Color(0xFF263238),
                onSurface: const Color(0xFFF5F7F8),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF121212),
                foregroundColor: Color(0xFFF5F7F8),
                iconTheme: IconThemeData(color: Color(0xFFF5F7F8)),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF263238),
                elevation: 1,
                shadowColor: const Color(0xFF000000).withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFF263238),
                selectedItemColor: const Color(0xFF4DB6AC),
                unselectedItemColor: const Color(0xFFE0E0E0).withOpacity(0.7),
                elevation: 8,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFFFF8A65),
                foregroundColor: Color(0xFF121212),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  foregroundColor: const Color(0xFF121212),
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
            ),
            themeMode: themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
