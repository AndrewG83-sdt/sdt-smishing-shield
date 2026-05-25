import '../models/analysis_result.dart';
import '../models/detected_indicator.dart';

class RiskEngine {
  AnalysisResult analyze(String message, {required AnalysisSource source}) {
    final normalized = _normalize(message);
    final indicators = <DetectedIndicator>[];

    void add({
      required String title,
      required String description,
      required int points,
      required IndicatorSeverity severity,
    }) {
      if (!indicators.any((item) => item.title == title)) {
        indicators.add(
          DetectedIndicator(
            title: title,
            description: description,
            points: points,
            severity: severity,
          ),
        );
      }
    }

    if (_containsAny(normalized, _passwordRequests)) {
      add(
        title: 'Password request',
        description: 'The message asks for a password or login credential.',
        points: 40,
        severity: IndicatorSeverity.high,
      );
    }

    if (_containsAny(normalized, _otpRequests)) {
      add(
        title: 'OTP request',
        description: 'The message asks for a one-time code, which should never be shared.',
        points: 45,
        severity: IndicatorSeverity.high,
      );
    }

    if (_hasShortenedUrl(normalized)) {
      add(
        title: 'Shortened URL',
        description: 'Short links can hide the final destination.',
        points: 25,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_hasSuspiciousDomain(normalized)) {
      add(
        title: 'Suspicious domain',
        description: 'A link appears to use a risky domain pattern or unusual top-level domain.',
        points: 30,
        severity: IndicatorSeverity.high,
      );
    }

    if (_containsAny(normalized, _urgentThreats)) {
      add(
        title: 'Urgent threat',
        description: 'The message pressures the recipient to act immediately.',
        points: 20,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_containsAny(normalized, _paymentRequests)) {
      add(
        title: 'Payment request',
        description: 'The message asks for payment, fees, refunds, or billing updates.',
        points: 20,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_hasUnknownSenderClue(normalized)) {
      add(
        title: 'Unknown sender',
        description: 'The sender identity is vague, generic, or not verifiable from the text.',
        points: 10,
        severity: IndicatorSeverity.low,
      );
    }

    if (_hasBrandImpersonation(normalized)) {
      add(
        title: 'Brand impersonation',
        description: 'The wording appears to impersonate a bank, courier, platform, or public institution.',
        points: 25,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_hasGrammarAnomalies(message)) {
      add(
        title: 'Grammar anomalies',
        description: 'The message has unusual grammar, spacing, capitalization, or punctuation.',
        points: 10,
        severity: IndicatorSeverity.low,
      );
    }

    if (_containsAny(normalized, _accountSuspension)) {
      add(
        title: 'Account suspension threat',
        description: 'The message claims an account will be blocked or suspended.',
        points: 25,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_containsAny(normalized, _deliveryLures)) {
      add(
        title: 'Delivery lure',
        description: 'The message uses a package, courier, customs, or delivery claim.',
        points: 20,
        severity: IndicatorSeverity.medium,
      );
    }

    if (_containsAny(normalized, _bankDetailRequests)) {
      add(
        title: 'Bank detail request',
        description: 'The message asks for payment card, banking, or account details.',
        points: 45,
        severity: IndicatorSeverity.high,
      );
    }

    if (_containsAny(normalized, _linkClickRequests)) {
      add(
        title: 'Link click request',
        description: 'The message tries to move the recipient to a link inside the message.',
        points: 20,
        severity: IndicatorSeverity.medium,
      );
    }

    final score = indicators.fold<int>(0, (sum, item) => sum + item.points).clamp(0, 100);
    final level = _classify(score);

    return AnalysisResult(
      message: message.trim(),
      riskLevel: level,
      score: score,
      indicators: indicators,
      explanation: _buildExplanation(level, indicators),
      recommendedAction: _recommendedAction(level),
      safeReply: _safeReply(level, indicators),
      createdAt: DateTime.now(),
      source: source,
    );
  }

  RiskLevel _classify(int score) {
    if (score >= 60) return RiskLevel.high;
    if (score >= 30) return RiskLevel.suspicious;
    return RiskLevel.low;
  }

  String _buildExplanation(RiskLevel level, List<DetectedIndicator> indicators) {
    if (indicators.isEmpty) {
      return 'No strong scam indicators were detected in the provided text. This does not prove the message is safe; it only means the local rule engine did not find high-signal warning signs.';
    }

    final names = indicators.map((item) => item.title.toLowerCase()).join(', ');
    final prefix = switch (level) {
      RiskLevel.high => 'This message contains multiple high-risk signals',
      RiskLevel.suspicious => 'This message contains suspicious signals',
      RiskLevel.low => 'This message contains limited warning signals',
    };
    return '$prefix, including $names. The assessment is based on local rules and should be used as support, not absolute proof.';
  }

  String _recommendedAction(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'Do not click any link. Do not reply. Do not provide personal data, passwords, OTP codes or payment details. Verify the message only through the official app or official website of the service.';
      case RiskLevel.suspicious:
        return 'Do not use the link inside the message. Verify independently through the official website, app or customer support.';
      case RiskLevel.low:
        return 'No strong scam indicators were detected, but always verify the sender before sharing personal or financial information.';
    }
  }

  String _safeReply(RiskLevel level, List<DetectedIndicator> indicators) {
    if (indicators.any((item) => item.title == 'OTP request' || item.title == 'Password request' || item.title == 'Bank detail request')) {
      return 'I will not share OTP codes, passwords or banking information through messages.';
    }
    if (level == RiskLevel.high) {
      return 'I do not verify personal or payment information through links received by message. I will check through the official channel.';
    }
    return 'Please contact me through the official customer support channel.';
  }

  bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _hasShortenedUrl(String text) {
    return RegExp(r'\b(bit\.ly|tinyurl\.com|t\.co|goo\.gl|ow\.ly|is\.gd|buff\.ly|cutt\.ly|rebrand\.ly|s\.id)\b').hasMatch(text);
  }

  bool _hasSuspiciousDomain(String text) {
    final domainPattern = RegExp(r'\b[a-z0-9-]+\.(zip|mov|top|click|support|rest|cam|cyou|quest|work|icu)\b');
    final hyphenatedBrand = RegExp(r'\b(paypal|apple|amazon|google|microsoft|dhl|fedex|ups|poste|bank|visa|mastercard)-[a-z0-9-]+\.');
    final deceptiveSubdomain = RegExp(r'\b(?:login|verify|secure|account)\.[a-z0-9-]+\.(?:com|net|org)\b');
    return domainPattern.hasMatch(text) || hyphenatedBrand.hasMatch(text) || deceptiveSubdomain.hasMatch(text);
  }

  bool _hasUnknownSenderClue(String text) {
    return _containsAny(text, ['dear user', 'dear customer', 'valued customer', 'account holder', 'client notice']);
  }

  bool _hasBrandImpersonation(String text) {
    return _containsAny(text, _impersonatedBrands) || _containsAny(text, _misspelledBrands);
  }

  bool _hasGrammarAnomalies(String original) {
    final repeatedPunctuation = RegExp(r'[!?]{3,}').hasMatch(original);
    final oddSpacing = RegExp(r'\s[,.!?]').hasMatch(original);
    final allCapsWords = RegExp(r'\b[A-Z]{5,}\b').allMatches(original).length >= 3;
    final commonErrors = RegExp(r'\b(kindly|expire soonest|your informations|verify informations|account has been limit)\b', caseSensitive: false).hasMatch(original);
    return repeatedPunctuation || oddSpacing || allCapsWords || commonErrors;
  }

  static const List<String> _passwordRequests = [
    'send password',
    'provide your password',
    'confirm your password',
    'enter your password',
    'password required',
    'login credential',
  ];

  static const List<String> _otpRequests = [
    'send otp',
    'share otp',
    'otp code',
    'one time password',
    'one-time password',
    'verification code',
    'security code',
  ];

  static const List<String> _urgentThreats = [
    'verify immediately',
    'urgent action required',
    'final warning',
    'act now',
    'immediate action',
    'within 24 hours',
    'last chance',
    'security alert',
  ];

  static const List<String> _paymentRequests = [
    'payment failed',
    'customs fee required',
    'pay now',
    'billing update',
    'refund pending',
    'unpaid fee',
    'delivery fee',
  ];

  static const List<String> _accountSuspension = [
    'your account will be blocked',
    'account will be blocked',
    'bank account suspended',
    'account suspended',
    'account locked',
    'account limited',
    'suspend your account',
  ];

  static const List<String> _deliveryLures = [
    'your package is waiting',
    'delivery failed',
    'missed delivery',
    'package pending',
    'parcel waiting',
    'customs fee required',
    'reschedule delivery',
  ];

  static const List<String> _bankDetailRequests = [
    'update your banking details',
    'banking details',
    'bank account',
    'card number',
    'credit card',
    'debit card',
    'sort code',
    'iban',
    'routing number',
  ];

  static const List<String> _linkClickRequests = [
    'click here',
    'tap here',
    'open this link',
    'follow the link',
    'click here to confirm',
    'confirm your identity',
    'verify your account',
    'update your details',
  ];

  static const List<String> _impersonatedBrands = [
    'bank',
    'paypal',
    'apple',
    'amazon',
    'google',
    'microsoft',
    'netflix',
    'dhl',
    'fedex',
    'ups',
    'poste',
    'tax office',
    'revenue service',
    'public institution',
    'courier',
    'unusual activity detected',
  ];

  static const List<String> _misspelledBrands = [
    'paypa1',
    'pay-pal',
    'arnazon',
    'amaz0n',
    'app1e',
    'micros0ft',
    'g00gle',
    'd h l',
    'postepay security',
  ];
}
