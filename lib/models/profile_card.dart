import 'package:uuid/uuid.dart';

class ProfileCard {
  final String id;
  final String name;
  final int age;
  final String mbti;
  final String introduction;
  final String? imagePath;
  final String backgroundId;
  final double filterIntensity;
  final String fontFamily;
  final DateTime createdAt;

  ProfileCard({
    String? id,
    required this.name,
    required this.age,
    required this.mbti,
    required this.introduction,
    this.imagePath,
    required this.backgroundId,
    required this.filterIntensity,
    required this.fontFamily,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  ProfileCard copyWith({
    String? name,
    int? age,
    String? mbti,
    String? introduction,
    String? imagePath,
    String? backgroundId,
    double? filterIntensity,
    String? fontFamily,
  }) {
    return ProfileCard(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      mbti: mbti ?? this.mbti,
      introduction: introduction ?? this.introduction,
      imagePath: imagePath ?? this.imagePath,
      backgroundId: backgroundId ?? this.backgroundId,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      fontFamily: fontFamily ?? this.fontFamily,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'mbti': mbti,
      'introduction': introduction,
      'imagePath': imagePath,
      'backgroundId': backgroundId,
      'filterIntensity': filterIntensity,
      'fontFamily': fontFamily,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProfileCard.fromJson(Map<String, dynamic> json) {
    return ProfileCard(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      mbti: json['mbti'],
      introduction: json['introduction'],
      imagePath: json['imagePath'],
      backgroundId: json['backgroundId'],
      filterIntensity: json['filterIntensity'],
      fontFamily: json['fontFamily'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory ProfileCard.empty() {
    return ProfileCard(
      name: '',
      age: 20,
      mbti: 'INFP',
      introduction: '',
      backgroundId: 'bg1',
      filterIntensity: 0.5,
      fontFamily: 'Pretendard',
    );
  }
}
