// screens/workouts_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../services/local_db_service.dart';
import '../../models/workout_model.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final LocalDBService _dbService = LocalDBService();

  final TextEditingController durationController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String selectedType = 'Running';

  List<WorkoutModel> workouts = [];
  bool isLoading = true;
  bool showForm = false;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final data = await _dbService.getWorkouts();
    setState(() {
      workouts = data;
      isLoading = false;
    });
  }

  Future<void> _addWorkout() async {
    final workoutId = const Uuid().v4();
    final workout = WorkoutModel(
      workoutId: workoutId,
      type: selectedType,
      duration: int.tryParse(durationController.text) ?? 0,
      calories: double.tryParse(caloriesController.text) ?? 0.0,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(() {
      workouts.insert(0, workout);
      selectedType = 'Running';
      showForm = false;
    });

    await _dbService.addWorkout(workout);

    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await _dbService.upsertDailyStats(dateStr, workout.calories, 0.0);

    userIdController.clear();
    durationController.clear();
    caloriesController.clear();
    setState(() {
      selectedType = 'Running';
      showForm = false;
    });

    _loadWorkouts();
  }

  void _cancelForm() {
    userIdController.clear();
    durationController.clear();
    caloriesController.clear();
    setState(() {
      selectedType = 'Running';
      showForm = false;
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 0, 233, 119),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  Widget _workoutTypeSelector() {
    return InputDecorator(
      decoration: _inputDecoration('Workout Type'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          style: GoogleFonts.manrope(color: Colors.black, fontSize: 16),
          items: [
            DropdownMenuItem(
              value: 'Running',
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_run,
                    color: Color.fromARGB(255, 0, 233, 119),
                  ),
                  const SizedBox(width: 8),
                  Text('Running', style: GoogleFonts.manrope()),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Walking',
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_walk_outlined,
                    color: Color.fromARGB(255, 0, 233, 119),
                  ),
                  const SizedBox(width: 8),
                  Text('Walking', style: GoogleFonts.manrope()),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedType = value!;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'plan your workout,',
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
                  'plan your success.',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Make your workout plan",
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showForm = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 233, 119),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Add",
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (showForm)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _workoutTypeSelector(),
                        const SizedBox(height: 8),
                        TextField(
                          controller: durationController,
                          style: GoogleFonts.manrope(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Duration (minutes)'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: caloriesController,
                          style: GoogleFonts.manrope(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Target Calories'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _cancelForm,
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.manrope(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addWorkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  0,
                                  233,
                                  119,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Add Workout",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : workouts.isEmpty
                    ? const Center(
                        child: Text(
                          "Add your first workout plan!",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: workouts.length,
                          itemBuilder: (context, index) {
                            final workout =
                                workouts[workouts.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 2.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      233,
                                      119,
                                    ),
                                    width: 1.2,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: workout.type == 'Running'
                                      ? const Icon(
                                          Icons.directions_run,
                                          color: Color.fromARGB(
                                            255,
                                            0,
                                            233,
                                            119,
                                          ),
                                        )
                                      : workout.type == 'Jogging'
                                      ? const Icon(
                                          Icons.directions_walk,
                                          color: Color.fromARGB(
                                            255,
                                            0,
                                            233,
                                            119,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.directions_walk_outlined,
                                          color: Color.fromARGB(
                                            255,
                                            0,
                                            233,
                                            119,
                                          ),
                                        ),
                                  title: Text(
                                    workout.type,
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Duration: ${workout.duration} min',
                                        style: GoogleFonts.manrope(),
                                      ),
                                      Text(
                                        'Target Calories: ${workout.calories} kcal',
                                        style: GoogleFonts.manrope(),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 246, 77, 94),
                                    ),
                                    onPressed: () async {
                                      await _dbService.deleteWorkout(
                                        workout.workoutId,
                                      );
                                      _loadWorkouts();
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
