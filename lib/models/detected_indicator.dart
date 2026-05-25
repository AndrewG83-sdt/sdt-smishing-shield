class DetectedIndicator {
  const DetectedIndicator({
    required this.title,
    required this.description,
    required this.points,
    required this.severity,
  });

  final String title;
  final String description;
  final int points;
  final IndicatorSeverity severity;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'points': points,
      'severity': severity.name,
    };
  }

  factory DetectedIndicator.fromJson(Map<String, dynamic> json) {
    return DetectedIndicator(
      title: json['title'] as String,
      description: json['description'] as String,
      points: json['points'] as int,
      severity: IndicatorSeverity.values.firstWhere(
        (value) => value.name == json['severity'],
        orElse: () => IndicatorSeverity.medium,
      ),
    );
  }
}

enum IndicatorSeverity { low, medium, high }
