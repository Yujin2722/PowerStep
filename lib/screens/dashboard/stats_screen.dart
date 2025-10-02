import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '/services/bluetooth_service.dart';
import '/services/local_db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthStatsPage extends StatefulWidget {
  const HealthStatsPage({super.key});

  @override
  State<HealthStatsPage> createState() => _HealthStatsPageState();
}

class _HealthStatsPageState extends State<HealthStatsPage> {
  double _calories = 0;
  double _distanceKm = 0;

  Future<void> _refreshData() async {
    await _calculateStats();
  }

  Future<void> _calculateStats() async {
    final prefs = await SharedPreferences.getInstance();
    final double height = prefs.getDouble('height')?.toDouble() ?? 0.0;
    final double weight = prefs.getDouble('weight')?.toDouble() ?? 0.0;

    final stepsStr = BluetoothService().steps;
    final steps = int.tryParse(stepsStr) ?? 0;

    final double stepLength = (height * 0.413).toDouble();
    final double distanceKm = height > 0 ? (steps * stepLength) / 100000 : 0;

    final double calories = (weight > 0 && distanceKm > 0)
        ? distanceKm * weight
        : 0.0;

    setState(() {
      _calories = calories;
      _distanceKm = distanceKm;
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateStats();
    _saveDailyStats();
  }

  Future<void> _saveDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final double height = prefs.getDouble('height') ?? 0;
    final double weight = prefs.getDouble('weight') ?? 0;

    final stepsStr = BluetoothService().steps;
    final steps = int.tryParse(stepsStr) ?? 0;

    final double stepLength = (height * 0.413).toDouble();
    final double distanceKm = height > 0
        ? ((steps * stepLength) / 100000).toDouble()
        : 0.0;

    final double calories = (weight > 0 && distanceKm > 0)
        ? distanceKm * weight
        : 0.0;

    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await LocalDBService().upsertDailyStats(dateStr, calories, distanceKm);
  }

  @override
  Widget build(BuildContext context) {
    final stepsStr = BluetoothService().steps;
    final bpmStr = BluetoothService().bpm;
    final bpm = bpmStr.isNotEmpty ? bpmStr : "0";
    final batteryStr = BluetoothService().battery;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'track your stats,',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    color: const Color.fromARGB(255, 0, 233, 119),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'track battery level.',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Calories Burned
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 235, 200),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.flame,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Cals Burned",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _calories.toStringAsFixed(1),
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "kcal",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart Rate
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 205, 210),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monitor_heart,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Heart Rate",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bpm,
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "bpm",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance Walked
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 166, 239, 255),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Distance",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _distanceKm.toStringAsFixed(2),
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "km",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Steps
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 207, 233, 188),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_walk,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Steps",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            stepsStr,
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "count",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Battery Level
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 233, 119),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final level = int.tryParse(batteryStr) ?? 0;
                                    Color batteryColor;

                                    if (level > 75) {
                                      batteryColor = const Color.fromARGB(
                                        255,
                                        0,
                                        233,
                                        119,
                                      );
                                    } else if (level > 30) {
                                      batteryColor = Colors.orange;
                                    } else {
                                      batteryColor = Colors.red;
                                    }

                                    return Icon(
                                      CupertinoIcons.bolt,
                                      color: batteryColor,
                                      size: 18,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Battery",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "$batteryStr%",
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "level",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(221, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Device Image
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/device.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
