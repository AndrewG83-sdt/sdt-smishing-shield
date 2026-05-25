import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/analysis_result.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/indicator_chip.dart';
import '../widgets/premium_card.dart';
import '../widgets/risk_score_ring.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _saved = widget.result.id != null;
  }

  Future<void> _copyReply() async {
    await Clipboard.setData(ClipboardData(text: widget.result.safeReply));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safe reply copied.')),
    );
  }

  Future<void> _save() async {
    if (_saved || _saving) return;
    setState(() => _saving = true);
    await DatabaseService.instance.saveAnalysis(widget.result);
    if (!mounted) return;
    setState(() {
      _saved = true;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analysis saved locally.')),
    );
  }

  Future<void> _exportReport() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/sdt_smishing_shield_report.txt');
    await file.writeAsString(_reportText());
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'SDT Smishing Shield risk report',
      text: 'Local risk assessment report from SDT Smishing Shield.',
    );
  }

  String _reportText() {
    final result = widget.result;
    final indicators = result.indicators.isEmpty
        ? 'None detected'
        : result.indicators.map((item) => '- ${item.title}: ${item.description} (+${item.points})').join('\n');

    return '''
SDT Smishing Shield Report

Date: ${result.createdAt.toLocal()}
Source: ${result.source.name}
Risk level: ${result.riskLabel}
Risk score: ${result.score}/100

Detected indicators:
$indicators

Explanation:
${result.explanation}

Recommended action:
${result.recommendedAction}

Safe reply:
${result.safeReply}

Original message:
${result.message}

Disclaimer:
This tool supports risk assessment but does not guarantee absolute detection.
''';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(widget.result.riskLabel);

    return Scaffold(
      appBar: AppBar(title: const Text('Risk result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 34),
        children: [
          PremiumCard(
            child: Column(
              children: [
                RiskScoreRing(score: widget.result.score, color: color),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withOpacity(0.38)),
                  ),
                  child: Text(
                    widget.result.riskLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'This tool supports risk assessment but does not guarantee absolute detection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Detected indicators', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                if (widget.result.indicators.isEmpty)
                  const Text(
                    'No strong indicators were detected.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  )
                else
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: widget.result.indicators.map((item) => IndicatorChip(indicator: item)).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(title: 'Explanation', body: widget.result.explanation, icon: Icons.analytics_rounded),
          _InfoCard(
            title: 'Recommended action',
            body: widget.result.recommendedAction,
            icon: Icons.verified_user_rounded,
            accent: color,
          ),
          PremiumCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.reply_rounded, color: AppTheme.accent),
                    SizedBox(width: 10),
                    Text('Safe reply suggestion', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(widget.result.safeReply, style: const TextStyle(height: 1.45)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyReply,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy safe reply'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: Icon(_saved ? Icons.check_rounded : Icons.bookmark_add_rounded),
                  label: Text(_saved ? 'Saved' : 'Save analysis'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Export report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    this.accent = AppTheme.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(body, style: const TextStyle(height: 1.45, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
