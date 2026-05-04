import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bittaqwa/presentation/widgets/time.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class JadwalSholatScreen extends StatefulWidget {
  const JadwalSholatScreen({super.key});

  @override
  State<JadwalSholatScreen> createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  Map<String, String>? _jadwalSholat;
  String? _locationName;
  bool _isLoading = true;
  String? _errorMessage;

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
          'Fajr': timings['Fajr'],
          'Dhuhr': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isha': timings['Isha'],
        };
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      return await _fetchAlternativeAPI(cityId);
    }
  }

  Future<Map<String, String>> _fetchAlternativeAPI(String cityId) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final url =
        'https://api.aladhan.com/v1/timingsByCity/$formattedDate?city=$cityId&country=Indonesia&method=8';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['results']['datetime'][0]['times'];

        return {
          'Fajr': timings['Fajr'],
          'Dhuhr': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isha': timings['Isha'],
        };
      } else {
        throw Exception('Failed to load from alternative API');
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

  @override
  void initState() {
    super.initState();
    _fetchLocationAndJadwalSholat();
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
          String cityName =
              place.locality ?? place.subAdministrativeArea ?? 'Bogor';
          String cityId = _getCityIdFromLocation(cityName);

          Map<String, String> jadwalSholat = await fetchJadwalSholat(cityId);

          setState(() {
            _jadwalSholat = jadwalSholat;
            _locationName =
                "$cityName, ${place.administrativeArea ?? 'Indonesia'}";
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          throw Exception('Ga dapet nemuin Lokasi euy');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gamau kasih izin lokasi';
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal ngasih jadwal sholat cuy';
        _jadwalSholat = _getStaticPrayerTimes();
        _locationName = 'Bogor, Indonesia';
      });
    }
  }

  void _retryFetchData() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchLocationAndJadwalSholat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          'Jadwal Sholat',
          style: TextStyle(
            fontFamily: "PoppinsMedium",
            color: ColorConstant.colorWhite,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: ColorConstant.colorWhite,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Mengambil data jadwal sholat...",
                    style: TextStyle(fontFamily: 'PoppinsRegular'),
                  ),
                ],
              ),
            )
          : _jadwalSholat == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? "gagal memuat Jadwal Sholat",
                    style: const TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryFetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.colorPrimary,
                    ),
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(
                        fontFamily: 'PoppinsMedium',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.green[50],
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/bg_header_jadwal_sholat.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 48),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          DateFormat(
                            'EEEE, dd MMMM yyyy', 'id_ID'
                          ).format(DateTime.now()),
                          style: TextStyle(
                            color: ColorConstant.colorWhite,
                            fontFamily: 'PoppinsSemiBold',
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: ColorConstant.colorPrimary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _locationName ?? 'Mangambil Lokasi...',
                            style: TextStyle(
                              color: ColorConstant.colorWhite,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ColorConstant.colorWhite,
                          boxShadow: const [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Time(
                              pray: "Shubuh",
                              time: _jadwalSholat!['Subuh'] ?? "N/A",
                              image: "assets/images/img_clock.png",
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 16),
                            Time(
                              pray: "Dzuhur",
                              time: _jadwalSholat!['Dzuhur'] ?? "N/A",
                              image: "assets/images/img_clock.png",
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 16),
                            Time(
                              pray: "Ashar",
                              time: _jadwalSholat!['Ashar'] ?? "N/A",
                              image: "assets/images/img_clock.png",
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 16),
                            Time(
                              pray: "Maghrib",
                              time: _jadwalSholat!['Maghrib'] ?? "N/A",
                              image: "assets/images/img_clock.png",
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 16),
                            Time(
                              pray: "Isya",
                              time: _jadwalSholat!['Isya'] ?? "N/A",
                              image: "assets/images/img_clock.png",
                            ),
                          ],
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        const Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Menggunakan Data Real Time',
                            style: TextStyle(
                              fontFamily: 'PoppinsRegular',
                              fontSize: 12,
                              color: Colors.pink,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
