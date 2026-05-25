import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/risk_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_card.dart';
import 'result_screen.dart';

class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({super.key});

  @override
  State<ManualAnalysisScreen> createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  final RiskEngine _riskEngine = RiskEngine();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a message to analyze.')),
      );
      return;
    }

    final result = _riskEngine.analyze(text, source: AnalysisSource.manual);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual analysis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 34),
        children: [
          const Text(
            'Paste the message exactly as received.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
          ),
          const SizedBox(height: 12),
          const Text(
            'The text stays on this device and is checked against local scam indicators.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 22),
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 12,
              minLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Example: Your account will be blocked. Verify immediately...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _analyze,
            icon: const Icon(Icons.radar_rounded),
            label: const Text('Analyze message'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
