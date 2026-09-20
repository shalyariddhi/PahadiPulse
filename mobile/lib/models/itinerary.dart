class ItineraryActivity {
  final String time;
  final String title;
  final String description;
  final String category;
  final String? providerName;
  final double costEstimateINR;

  ItineraryActivity({
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    this.providerName,
    required this.costEstimateINR,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'title': title,
      'description': description,
      'category': category,
      'providerName': providerName,
      'costEstimateINR': costEstimateINR,
    };
  }

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      providerName: json['providerName'],
      costEstimateINR: (json['costEstimateINR'] as num?)?.toDouble() ?? 200.0,
    );
  }
}

class ItineraryStay {
  final String name;
  final String type;
  final double costPerNightINR;
  final String? bookingContact;

  ItineraryStay({
    required this.name,
    required this.type,
    required this.costPerNightINR,
    this.bookingContact,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'costPerNightINR': costPerNightINR,
      'bookingContact': bookingContact,
    };
  }

  factory ItineraryStay.fromJson(Map<String, dynamic> json) {
    return ItineraryStay(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      costPerNightINR: (json['costPerNightINR'] as num?)?.toDouble() ?? 1800.0,
      bookingContact: json['bookingContact'],
    );
  }
}

class ItineraryDay {
  final int dayNumber;
  final String destinationId;
  final String destinationName;
  final String district;
  final String pressureLevel;
  final double pressureScore;
  final ItineraryStay stayRecommendation;
  final List<ItineraryActivity> activities;
  final String travelNote;

  ItineraryDay({
    required this.dayNumber,
    required this.destinationId,
    required this.destinationName,
    required this.district,
    required this.pressureLevel,
    required this.pressureScore,
    required this.stayRecommendation,
    required this.activities,
    required this.travelNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'district': district,
      'pressureLevel': pressureLevel,
      'pressureScore': pressureScore,
      'stayRecommendation': stayRecommendation.toJson(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'travelNote': travelNote,
    };
  }

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: json['dayNumber'] ?? 1,
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      district: json['district'] ?? '',
      pressureLevel: json['pressureLevel'] ?? 'LOW',
      pressureScore: (json['pressureScore'] as num?)?.toDouble() ?? 25.0,
      stayRecommendation: ItineraryStay.fromJson(json['stayRecommendation'] ?? {}),
      activities: (json['activities'] as List? ?? [])
          .map((a) => ItineraryActivity.fromJson(a))
          .toList(),
      travelNote: json['travelNote'] ?? '',
    );
  }
}

class GeneratedItinerary {
  final String id;
  final String title;
  final int daysCount;
  final int travellersCount;
  final double budgetPerPersonINR;
  final double totalEstimatedCostINR;
  final double pressureMitigationScore;
  final List<String> interests;
  final String startingRegion;
  final String rationale;
  final List<ItineraryDay> days;

  GeneratedItinerary({
    required this.id,
    required this.title,
    required this.daysCount,
    required this.travellersCount,
    required this.budgetPerPersonINR,
    required this.totalEstimatedCostINR,
    required this.pressureMitigationScore,
    required this.interests,
    required this.startingRegion,
    required this.rationale,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'daysCount': daysCount,
      'travellersCount': travellersCount,
      'budgetPerPersonINR': budgetPerPersonINR,
      'totalEstimatedCostINR': totalEstimatedCostINR,
      'pressureMitigationScore': pressureMitigationScore,
      'interests': interests,
      'startingRegion': startingRegion,
      'rationale': rationale,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }

  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) {
    return GeneratedItinerary(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      daysCount: json['daysCount'] ?? 4,
      travellersCount: json['travellersCount'] ?? 3,
      budgetPerPersonINR: (json['budgetPerPersonINR'] as num?)?.toDouble() ?? 10000.0,
      totalEstimatedCostINR: (json['totalEstimatedCostINR'] as num?)?.toDouble() ?? 28000.0,
      pressureMitigationScore: (json['pressureMitigationScore'] as num?)?.toDouble() ?? 64.0,
      interests: List<String>.from(json['interests'] ?? []),
      startingRegion: json['startingRegion'] ?? 'Dehradun',
      rationale: json['rationale'] ?? '',
      days: (json['days'] as List? ?? []).map((d) => ItineraryDay.fromJson(d)).toList(),
    );
  }
}
