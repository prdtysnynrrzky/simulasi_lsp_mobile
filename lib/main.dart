import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simulasi_lsp_praditya/screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/transfer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATM Mobile Sederhana',
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        TransferScreen.routeName: (context) => const TransferScreen(),
        SettingScreen.routeName: (context) => const SettingScreen(),
      },
    );
  }
}
