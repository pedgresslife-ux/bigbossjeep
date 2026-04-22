import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const TeslaApp());
}

class TeslaApp extends StatelessWidget {
  const TeslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  // Mock weather data
  String _temp = "24°C";
  String _weatherDesc = "Cloudy";
  IconData _weatherIcon = Icons.cloud_outlined;

  // Mock Sensor Data for Jeep Features
  double _pitch = 2.0; // Front/Back tilt
  double _roll = -1.5; // Left/Right tilt
  double _heading = 42.0; // Degrees (NE)

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          // Subtle movement simulation for gauges
          _pitch += (math.Random().nextDouble() - 0.5) * 0.2;
          _roll += (math.Random().nextDouble() - 0.5) * 0.2;
          _heading = (_heading + 0.1) % 360;
        });
      }
    });
  }

  void _refreshWeather() {
    setState(() {
      _temp = "26°C";
      _weatherDesc = "Sunny";
      _weatherIcon = Icons.wb_sunny_outlined;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLargeTablet = size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // 1. LEFT PANEL: DRIVING & OFF-ROAD DATA
          Container(
            width: isLargeTablet ? 400 : 320,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text("BIG BOSS JEEP",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        fontSize: 18,
                        color: Colors.white)),
                const Text("OFF-ROAD EDITION",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 10, letterSpacing: 2)),

                const SizedBox(height: 40),

                // Gear Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _gearIndicator("P"),
                    _gearIndicator("R"),
                    _gearIndicator("N"),
                    _gearIndicator("D", isActive: true),
                  ],
                ),

                const SizedBox(height: 10),

                // Speedometer
                Column(
                  children: [
                    Text("72",
                        style: TextStyle(
                            fontSize: isLargeTablet ? 140 : 100,
                            fontWeight: FontWeight.w200,
                            height: 0.9,
                            color: Colors.white)),
                    const Text("km/h",
                        style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w300)),
                  ],
                ),

                const SizedBox(height: 30),

                // OFF-ROAD GAUGES (Compass & Inclinometer)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _offRoadGauge("PITCH", "${_pitch.toStringAsFixed(1)}°", Icons.height),
                      _offRoadGauge("ROLL", "${_roll.toStringAsFixed(1)}°", Icons.rotate_right),
                      _offRoadGauge("HEADING", "${_heading.toInt()}°", Icons.explore),
                    ],
                  ),
                ),

                const Spacer(),

                // Vehicle Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      _statRow(Icons.battery_charging_full, "84%", Colors.greenAccent),
                      const SizedBox(height: 12),
                      _statRow(Icons.speed, "342 km range", Colors.white70),
                      const SizedBox(height: 12),
                      _statRow(Icons.terrain, "4WD AUTO", Colors.blueAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. RIGHT PANEL: MAPS & MEDIA
          Expanded(
            child: Column(
              children: [
                // TOP STATUS BAR
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.wifi, color: Colors.white54, size: 20),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: _refreshWeather,
                        child: Row(
                          children: [
                            Icon(_weatherIcon, color: Colors.white54, size: 22),
                            const SizedBox(width: 8),
                            Text(_temp, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      Text(DateFormat('HH:mm').format(_now),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
                    child: Column(
                      children: [
                        // MAP
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.map_outlined, color: Colors.white10, size: 120),
                                ),
                                Positioned(
                                  top: 30, left: 30,
                                  child: _navCard(),
                                ),
                                // Mini Compass Overlay on Map
                                Positioned(
                                  bottom: 30, right: 30,
                                  child: _miniCompass(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // MULTIMEDIA
                        Expanded(
                          flex: 3,
                          child: _mediaPlayer(),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM DOCK
                _bottomDock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offRoadGauge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, letterSpacing: 1)),
      ],
    );
  }

  Widget _miniCompass() {
    return Transform.rotate(
      angle: -_heading * (math.pi / 180),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: const Icon(Icons.navigation, color: Colors.blueAccent, size: 30),
      ),
    );
  }

  Widget _navCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("NAVIGATING TO", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text("Avenida Paulista, 1000", style: TextStyle(color: Colors.white, fontSize: 18)),
          Text("12 mins • 4.2 km", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _mediaPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueGrey, Colors.black]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.music_note, color: Colors.white24, size: 40),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Thunderstruck", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("AC/DC", style: TextStyle(fontSize: 16, color: Colors.white54)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: 0.6, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation(Colors.blueAccent), borderRadius: BorderRadius.circular(10), minHeight: 4),
              ],
            ),
          ),
          const SizedBox(width: 30),
          _mediaIcon(Icons.skip_previous_rounded),
          const SizedBox(width: 20),
          const Icon(Icons.pause_circle_filled, color: Colors.white, size: 60),
          const SizedBox(width: 20),
          _mediaIcon(Icons.skip_next_rounded),
        ],
      ),
    );
  }

  Widget _bottomDock() {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dockIcon(Icons.directions_car_filled_rounded),
          _dockIcon(Icons.ac_unit_rounded, color: Colors.blueAccent),
          const VerticalDivider(color: Colors.white10, indent: 20, endIndent: 20),
          const Text("22°C", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const VerticalDivider(color: Colors.white10, indent: 20, endIndent: 20),
          _dockIcon(Icons.phone_enabled_rounded),
          _dockIcon(Icons.grid_view_rounded),
          _dockIcon(Icons.settings_suggest_rounded),
        ],
      ),
    );
  }

  Widget _gearIndicator(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40, height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.blueAccent : Colors.white10),
      ),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.white24)),
    );
  }

  Widget _statRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 15),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.white70)),
      ],
    );
  }

  Widget _offRoadGauge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, letterSpacing: 1)),
      ],
    );
  }

  Widget _mediaIcon(IconData icon) => Icon(icon, color: Colors.white, size: 35);

  Widget _dockIcon(IconData icon, {Color color = Colors.white70}) {
    return IconButton(icon: Icon(icon, color: color, size: 28), onPressed: () {});
  }
}
