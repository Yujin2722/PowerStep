class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password;
  final int? age;
  final double? weight;
  final double? height;
  final int? steps;
  final double? calories;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    this.age,
    this.weight,
    this.height,
    this.steps,
    this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'weight': weight,
      'height': height,
      'steps': steps,
      'calories': calories,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      age: map['age'] as int?,
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      steps: map['steps'] as int?,
      calories: (map['calories'] as num?)?.toDouble(),
    );
  }
}