class Lawyer {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int casesWon;
  final double pricePerHour;
  final int experienceYears;
  final String imageUrl;
  final String about;
  final bool isVerified;
  final List<String> certifications;
  final List<String> specializations;

  const Lawyer({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.casesWon,
    required this.pricePerHour,
    required this.experienceYears,
    required this.imageUrl,
    required this.about,
    this.isVerified = false,
    this.certifications = const [],
    this.specializations = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'location': location,
      'rating': rating,
      'casesWon': casesWon,
      'pricePerHour': pricePerHour,
      'experienceYears': experienceYears,
      'imageUrl': imageUrl,
      'about': about,
      'isVerified': isVerified,
      'certifications': certifications,
      'specializations': specializations,
    };
  }

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      casesWon: json['casesWon'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      about: json['about'] ?? '',
      isVerified: json['isVerified'] ?? false,
      certifications: List<String>.from(json['certifications'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
    );
  }

  Lawyer copyWith({
    String? id,
    String? name,
    String? specialty,
    String? location,
    double? rating,
    int? casesWon,
    double? pricePerHour,
    int? experienceYears,
    String? imageUrl,
    String? about,
    bool? isVerified,
    List<String>? certifications,
    List<String>? specializations,
  }) {
    return Lawyer(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      casesWon: casesWon ?? this.casesWon,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      experienceYears: experienceYears ?? this.experienceYears,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      isVerified: isVerified ?? this.isVerified,
      certifications: certifications ?? this.certifications,
      specializations: specializations ?? this.specializations,
    );
  }
}