import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';
  String _nextPrayer = 'Memuat...';
  String _nextPrayerTime = '';
  String _timeRemaining = '';
  Map<String, String>? _jadwalSholat;
  String? _locationName;

  final Map<String, String> _cityMapping = {
    'jakarta': '1301',
    'bogor': '1302',
    'depok': '1303',
    'tangerang': '1304',
    'bekasi': '1305',
    'bandung': '1201',
    'surabaya': '1401',
    'yogyakarta': '1601',
  };

  @override
  void initState() {
    super.initState();
    _fetchLocationAndJadwalSholat();
    _updateTime();
    // Update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
      if (_jadwalSholat != null) {
        _checkNextPrayer();
      }
    });
  }

  Future<Map<String, String>> fetchJadwalSholat(String cityId) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final url =
        'https://api.aladhan.com/v1/timingsByCity/$formattedDate?city=$cityId&country=Indonesia&method=8';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return {
          'Subuh': timings['Fajr'],
          'Dzuhur': timings['Dhuhr'],
          'Ashar': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isya': timings['Isha'],
        };
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      return _getStaticPrayerTimes();
    }
  }

  Map<String, String> _getStaticPrayerTimes() {
    return {
      'Subuh': '04:30',
      'Dzuhur': '12:00',
      'Ashar': '15:00',
      'Maghrib': '18:00',
      'Isya': '19:00',
    };
  }

  String _getCityIdFromLocation(String cityName) {
    String normalizedCity = cityName.toLowerCase().trim();

    if (_cityMapping.containsKey(normalizedCity)) {
      return _cityMapping[normalizedCity]!;
    }

    return _cityMapping['bogor']!;
  }

  Future<void> _fetchLocationAndJadwalSholat() async {
    try {
      var status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        List<Placemark> placemark = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemark.isNotEmpty) {
          Placemark place = placemark.first;
          
          // Ambil kecamatan dan kota
          String kecamatan = place.subLocality ?? place.locality ?? 'Kecamatan Tidak Diketahui';
          String kota = place.locality ?? place.subAdministrativeArea ?? 'Bogor';
          
          String cityId = _getCityIdFromLocation(kota);

          Map<String, String> jadwalSholat = await fetchJadwalSholat(cityId);

          setState(() {
            _jadwalSholat = jadwalSholat;
            // Format: Kecamatan Jonggol, Bogor
            _locationName = "$kecamatan, $kota";
            _checkNextPrayer();
          });
        }
      } else {
        // Gunakan data default jika izin lokasi ditolak
        setState(() {
          _jadwalSholat = _getStaticPrayerTimes();
          _locationName = 'Kecamatan Jonggol, Bogor';
          _checkNextPrayer();
        });
      }
    } catch (e) {
      setState(() {
        _jadwalSholat = _getStaticPrayerTimes();
        _locationName = 'Kecamatan Jonggol, Bogor';
        _checkNextPrayer();
      });
    }
  }

  void _checkNextPrayer() {
    if (_jadwalSholat == null) return;

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    // List waktu sholat dalam urutan
    final prayers = [
      {'name': 'Subuh', 'time': _jadwalSholat!['Subuh']!},
      {'name': 'Dzuhur', 'time': _jadwalSholat!['Dzuhur']!},
      {'name': 'Ashar', 'time': _jadwalSholat!['Ashar']!},
      {'name': 'Maghrib', 'time': _jadwalSholat!['Maghrib']!},
      {'name': 'Isya', 'time': _jadwalSholat!['Isya']!},
    ];

    String nextPrayerName = '';
    String nextPrayerTime = '';
    Duration? shortestDuration;

    for (var prayer in prayers) {
      final prayerTimeParts = prayer['time']!.split(':');
      final prayerHour = int.parse(prayerTimeParts[0]);
      final prayerMinute = int.parse(prayerTimeParts[1]);

      var prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerHour,
        prayerMinute,
      );

      // Jika waktu sholat sudah lewat hari ini, tambahkan 1 hari
      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final duration = prayerDateTime.difference(now);

      if (shortestDuration == null || duration < shortestDuration) {
        shortestDuration = duration;
        nextPrayerName = prayer['name']!;
        nextPrayerTime = prayer['time']!;
      }
    }

    if (shortestDuration != null) {
      final hours = shortestDuration.inHours;
      final minutes = shortestDuration.inMinutes.remainder(60);
      final seconds = shortestDuration.inSeconds.remainder(60);

      String timeRemainingStr = '';
      if (hours > 0) {
        timeRemainingStr = '$hours jam $minutes menit';
      } else if (minutes > 0) {
        timeRemainingStr = '$minutes menit $seconds detik';
      } else {
        timeRemainingStr = '$seconds detik';
      }

      setState(() {
        _nextPrayer = nextPrayerName;
        _nextPrayerTime = nextPrayerTime;
        _timeRemaining = timeRemainingStr;
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      // Format jam: HH:mm:ss
      _currentTime = DateFormat('HH:mm:ss').format(now);
      // Format tanggal
      _currentDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Jangan lupa cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_header_dashboard_morning.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Text(
                  'Assalamualaikum Akhy',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PoppinsMedium',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Notifikasi Sholat Berikutnya
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Sholat Berikutnya: $_nextPrayer",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontFamily: 'PoppinsSemiBold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        _nextPrayerTime,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 16,
                          fontFamily: 'PoppinsBold',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _timeRemaining.isNotEmpty ? "($_timeRemaining lagi)" : "",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontFamily: 'PoppinsBold',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Jam Real-Time
            Text(
              _currentTime,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 36,
                fontFamily: 'PoppinsBold',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentDate,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'PoppinsSemiBold',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  _locationName ?? "Memuat lokasi...",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PoppinsBold',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget cardMenus() {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color.fromARGB(255, 206, 44, 44),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'doa');
                }, 
              child: Column(
                children: [
                  Image.asset('assets/images/ic_menu_doa.png'),
                  Text(
                    "Doa-doa",
                    style: TextStyle(
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(width: 12),
                GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'zakat');
                }, 
              child: Column(
                children: [
                  Image.asset('assets/images/ic_menu_zakat.png'),
                  Text(
                    "Zakat",
                    style: TextStyle(
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
             ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'sholat');
                }, 
              child: Column(
                children: [
                  Image.asset('assets/images/ic_menu_jadwal_sholat.png'),
                  Text(
                    "Jadwal Sholat",
                    style: TextStyle(
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'kajian');
                }, 
              child: Column(
                children: [
                  Image.asset('assets/images/ic_menu_video_kajian.png'),
                  Text(
                    "Video Kajian",
                    style: TextStyle(
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ),
            ]
          ),
        ),
      );
    }

    Widget cardInspiration() {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column (
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text (
                "Inspirasi",
                style: TextStyle(fontFamily: 'PoppinsSemiBold', fontSize: 20),
              ),
            ),
            SizedBox(height: 8),
            Image.asset('assets/images/p1.png'
            ),
            SizedBox(height: 8),
            Image.asset('assets/images/p2.png'
            ),
          ],
        )
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(children: [header(),cardMenus(), cardInspiration()]),
      ), 
    );
  }
}