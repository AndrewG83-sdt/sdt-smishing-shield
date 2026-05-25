import 'dart:convert';

import 'detected_indicator.dart';

class AnalysisResult {
  const AnalysisResult({
    this.id,
    required this.message,
    required this.riskLevel,
    required this.score,
    required this.indicators,
    required this.explanation,
    required this.recommendedAction,
    required this.safeReply,
    required this.createdAt,
    required this.source,
  });

  final int? id;
  final String message;
  final RiskLevel riskLevel;
  final int score;
  final List<DetectedIndicator> indicators;
  final String explanation;
  final String recommendedAction;
  final String safeReply;
  final DateTime createdAt;
  final AnalysisSource source;

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'LOW RISK';
      case RiskLevel.suspicious:
        return 'SUSPICIOUS';
      case RiskLevel.high:
        return 'HIGH RISK';
    }
  }

  AnalysisResult copyWith({int? id}) {
    return AnalysisResult(
      id: id ?? this.id,
      message: message,
      riskLevel: riskLevel,
      score: score,
      indicators: indicators,
      explanation: explanation,
      recommendedAction: recommendedAction,
      safeReply: safeReply,
      createdAt: createdAt,
      source: source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'riskLevel': riskLevel.name,
      'score': score,
      'indicators': jsonEncode(indicators.map((item) => item.toJson()).toList()),
      'explanation': explanation,
      'recommendedAction': recommendedAction,
      'safeReply': safeReply,
      'createdAt': createdAt.toIso8601String(),
      'source': source.name,
    };
  }

  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    final decodedIndicators = jsonDecode(map['indicators'] as String) as List<dynamic>;

    return AnalysisResult(
      id: map['id'] as int?,
      message: map['message'] as String,
      riskLevel: RiskLevel.values.firstWhere(
        (value) => value.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      score: map['score'] as int,
      indicators: decodedIndicators
          .map((item) => DetectedIndicator.fromJson(item as Map<String, dynamic>))
          .toList(),
      explanation: map['explanation'] as String,
      recommendedAction: map['recommendedAction'] as String,
      safeReply: map['safeReply'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      source: AnalysisSource.values.firstWhere(
        (value) => value.name == map['source'],
        orElse: () => AnalysisSource.manual,
      ),
    );
  }
}

enum RiskLevel { low, suspicious, high }

enum AnalysisSource { screenshot, manual }
