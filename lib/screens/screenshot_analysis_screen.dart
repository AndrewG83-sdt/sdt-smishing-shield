import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/analysis_result.dart';
import '../services/ocr_service.dart';
import '../services/risk_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_card.dart';
import 'result_screen.dart';

class ScreenshotAnalysisScreen extends StatefulWidget {
  const ScreenshotAnalysisScreen({super.key});

  @override
  State<ScreenshotAnalysisScreen> createState() => _ScreenshotAnalysisScreenState();
}

class _ScreenshotAnalysisScreenState extends State<ScreenshotAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final RiskEngine _riskEngine = RiskEngine();

  File? _image;
  String _extractedText = '';
  bool _isReading = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _extractedText = '';
    });
  }

  Future<void> _runOcr() async {
    final image = _image;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a screenshot first.')),
      );
      return;
    }

    setState(() => _isReading = true);
    try {
      final text = await _ocrService.extractText(image);
      setState(() => _extractedText = text);
      if (text.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No readable text was found in this screenshot.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OCR failed. Try a clearer screenshot.')),
      );
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  void _analyze() {
    final text = _extractedText.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run OCR before analyzing.')),
      );
      return;
    }

    final result = _riskEngine.analyze(text, source: AnalysisSource.screenshot);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screenshot analysis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 34),
        children: [
          const Text(
            'Extract text from a message screenshot.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
          ),
          const SizedBox(height: 12),
          const Text(
            'OCR runs on-device. Screenshots are not uploaded to a server.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 22),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: AspectRatio(
              aspectRatio: 0.78,
              child: _image == null
                  ? const _EmptyImageState()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectImage,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Select image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isReading ? null : _runOcr,
                  icon: _isReading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.document_scanner_rounded),
                  label: Text(_isReading ? 'Reading' : 'Run OCR'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Extracted text', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _extractedText.isEmpty
                      ? const Text(
                          'OCR output will appear here.',
                          key: ValueKey('empty'),
                          style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
                        )
                      : Text(
                          _extractedText,
                          key: const ValueKey('text'),
                          style: const TextStyle(height: 1.45),
                        ),
                ),
              ],
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

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_rounded, size: 44, color: AppTheme.textSecondary),
          SizedBox(height: 12),
          Text('Select a screenshot', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
