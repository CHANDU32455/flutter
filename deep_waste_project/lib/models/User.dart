class User {
  final int id;
  final String name;
  User({required this.id, required this.name});

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name};
  }

  static User empty() {
    return User(id: 0, name: 'Guest');  // Default ID and name
  }
}
