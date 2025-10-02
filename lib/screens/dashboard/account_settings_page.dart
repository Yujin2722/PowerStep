// screens/account_settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/local_db_service.dart';
import '../../models/user_model.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool isLoading = true;
  String? uid;

  final LocalDBService db = LocalDBService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('loggedInUserId');
    if (uid != null) {
      final users = await db.getUsers();
      final user = users.firstWhere(
        (u) => u.uid == uid,
        orElse: () => UserModel(uid: '', name: '', email: '', password: ''),
      );
      if (user.uid.isNotEmpty) {
        emailController.text = user.email;
        nameController.text = user.name;
        ageController.text = user.age?.toString() ?? '';
        weightController.text = user.weight?.toString() ?? '';
        heightController.text = user.height?.toString() ?? '';
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', emailController.text);
    await prefs.setString('name', nameController.text);
    await prefs.setInt('age', int.tryParse(ageController.text) ?? 0);
    await prefs.setDouble(
      'weight',
      double.tryParse(weightController.text) ?? 0,
    );
    await prefs.setDouble(
      'height',
      double.tryParse(heightController.text) ?? 0,
    );

    if (passwordController.text.isNotEmpty) {
      await prefs.setString('password', passwordController.text);
    }

    // Save to database
    if (uid != null && uid!.isNotEmpty) {
      final user = UserModel(
        uid: uid!,
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text.isNotEmpty
            ? passwordController.text
            : (await prefs.getString('password') ?? ''),
        age: int.tryParse(ageController.text),
        weight: double.tryParse(weightController.text),
        height: double.tryParse(heightController.text),
      );
      await db.addUser(user);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );

    passwordController.clear();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'edit your info',
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
              'stay in control.',
              style: GoogleFonts.manrope(
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          TextField(
            controller: nameController,
            style: GoogleFonts.manrope(),
            decoration: _inputDecoration('Name'),
          ),
          const SizedBox(height: 12),
          // Age
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(),
            decoration: _inputDecoration('Age'),
          ),
          const SizedBox(height: 12),
          // Weight
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(),
            decoration: _inputDecoration('Weight (kg)'),
          ),
          const SizedBox(height: 12),
          // Height
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(),
            decoration: _inputDecoration('Height (cm)'),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color.fromARGB(255, 0, 233, 119),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'We only use your age, weight, and height to ensure accurate calculations of calories burned and distance traveled.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your information is kept private and is never shared.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 246, 77, 94),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color.fromARGB(255, 0, 233, 119),
                    size: 42,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 233, 119),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Save",
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('loggedInUserId');
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 246, 77, 94),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
