import 'package:flutter/material.dart';
import 'package:progetto/methods/theme.dart';
import 'package:progetto/models/db.dart';
import 'package:progetto/provider/homeprovider.dart';
import 'package:progetto/screens/splash.dart';
import 'package:progetto/services/impact.dart';
import 'package:progetto/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(Provider<AppDatabase>.value(value: db, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => Preferences()..init(), 
          lazy: false,
        ),
        Provider(
            create: (context) => ImpactService(
                  // We pass the newly created preferences to the service
                  Provider.of<Preferences>(context, listen: false),
                )),
          ChangeNotifierProvider<HomeProvider>(
        create: (context) => HomeProvider(
            Provider.of<ImpactService>(context, listen: false),
            Provider.of<AppDatabase>(context, listen: false),
             Provider.of<Preferences>(context, listen: false),))
      ],
      child: MaterialApp(
        home: const Splash(),
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: FitnessAppTheme.lightPurple)),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: FitnessAppTheme.lightPurple,
          ),
          scaffoldBackgroundColor: FitnessAppTheme.background,
        ),
      ),
    );
  }
}
