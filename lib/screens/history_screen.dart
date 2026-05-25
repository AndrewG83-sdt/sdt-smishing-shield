import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_card.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<AnalysisResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseService.instance.fetchAnalyses();
  }

  void _reload() {
    setState(() => _future = DatabaseService.instance.fetchAnalyses());
  }

  Future<void> _delete(int id) async {
    await DatabaseService.instance.deleteAnalysis(id);
    _reload();
  }

  Future<void> _deleteAll() async {
    await DatabaseService.instance.deleteAll();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis history'),
        actions: [
          IconButton(
            tooltip: 'Delete all history',
            onPressed: _deleteAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AnalysisResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final analyses = snapshot.data ?? [];
          if (analyses.isEmpty) {
            return const _EmptyHistory();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 34),
            itemBuilder: (context, index) {
              final item = analyses[index];
              return _HistoryItem(
                result: item,
                onDelete: item.id == null ? null : () => _delete(item.id!),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResultScreen(result: item)),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemCount: analyses.length,
          );
        },
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  final AnalysisResult result;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(result.riskLabel);
    final preview = result.message.length > 96 ? '${result.message.substring(0, 96)}...' : result.message;

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.34)),
            ),
            child: Center(
              child: Text(
                result.score.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.riskLabel, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  _formatDate(result.createdAt),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textPrimary, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete record',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 50, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('No saved analyses yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
              'Saved reports will appear here and remain stored locally on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
