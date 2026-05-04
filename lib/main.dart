import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/presentation/screen/video_kajian_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bittaqwa/presentation/screen/dashboard_screen.dart';
import 'package:flutter_bittaqwa/presentation/screen/doa_screen.dart';
import 'package:flutter_bittaqwa/presentation/screen/jadwal_sholat_screen.dart';
import 'package:flutter_bittaqwa/presentation/screen/zakat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); 
  runApp(const MyApp());
} 


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitaqwa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const DashboardScreen(),
        'doa': (context) => const DoaScreen(),
        'zakat': (context) => const ZakatScreen(),
        'sholat': (context) => const JadwalSholatScreen(),
        'kajian': (context) => const VideoKajianScreen(),
      },
    );
  }
}
