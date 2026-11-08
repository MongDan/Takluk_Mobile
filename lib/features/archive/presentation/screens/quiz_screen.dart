import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/mock_data.dart';
import '../../../../core/domain/models/archive_question_model.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String courseId;

  const QuizScreen({super.key, required this.courseId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<ArchiveQuestionModel> _questions;
  int _currentIndex = 0;
  String? _selectedKey;
  bool _isAnswered = false;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _questions = MockData.archiveQuestions
        .where((q) => q.courseId == widget.courseId)
        .toList();
    if (_questions.isEmpty) {
      _questions = MockData.archiveQuestions;
    }
  }

  void _selectOption(String key) {
    if (_isAnswered) return;
    setState(() {
      _selectedKey = key;
      _isAnswered = true;
      if (key == _questions[_currentIndex].correctKey) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedKey = null;
        _isAnswered = false;
      });
    } else {
      setState(() => _isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Scaffold(
        backgroundColor: TaklukColors.bg,
        appBar: const PushPageHeader(title: 'Hasil Latihan Soal'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: TaklukColors.tintWarm,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Latihan Selesai!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu menjawab benar $_score dari ${_questions.length} soal.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: TaklukColors.muted,
                  ),
                ),
                const SizedBox(height: 32),
                TaklukButton(
                  label: 'Ulangi Latihan',
                  variant: ButtonVariant.secondary,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _selectedKey = null;
                      _isAnswered = false;
                      _score = 0;
                      _isFinished = false;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TaklukButton(
                  label: 'Kembali ke Arsip',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: PushPageHeader(
        title: 'Soal ${_currentIndex + 1} dari ${_questions.length}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TaklukColors.tint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${q.universityTag.value} • ${q.examType.label} ${q.academicYear}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TaklukColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: MarkdownBody(
                data: q.questionMarkdown,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TaklukColors.ink,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            ...q.options.map((opt) {
              final isChosen = _selectedKey == opt.key;
              final isCorrect = opt.key == q.correctKey;

              Color borderColor = TaklukColors.line;
              Color bgColor = TaklukColors.surface;
              Color textColor = TaklukColors.ink;

              if (_isAnswered) {
                if (isCorrect) {
                  borderColor = TaklukColors.success;
                  bgColor = TaklukColors.success.withOpacity(0.1);
                  textColor = TaklukColors.success;
                } else if (isChosen && !isCorrect) {
                  borderColor = TaklukColors.error;
                  bgColor = TaklukColors.error.withOpacity(0.1);
                  textColor = TaklukColors.error;
                }
              } else if (isChosen) {
                borderColor = TaklukColors.primary;
                bgColor = TaklukColors.tint;
              }

              return GestureDetector(
                onTap: () => _selectOption(opt.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: TaklukRadius.cardBR,
                    border: Border.all(color: borderColor, width: isChosen || (_isAnswered && isCorrect) ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isChosen ? borderColor : TaklukColors.tint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            opt.key,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isChosen ? Colors.white : TaklukColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt.text,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (_isAnswered) ...[
                        if (isCorrect)
                          const Icon(LucideIcons.checkCircle, color: TaklukColors.success, size: 20)
                        else if (isChosen)
                          const Icon(LucideIcons.xCircle, color: TaklukColors.error, size: 20),
                      ],
                    ],
                  ),
                ),
              );
            }),

            // Explanation Section after answered
            if (_isAnswered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TaklukColors.surface,
                  borderRadius: TaklukRadius.cardBR,
                  border: Border.all(
                    color: _selectedKey == q.correctKey ? TaklukColors.success : TaklukColors.line,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedKey == q.correctKey ? LucideIcons.checkCircle : LucideIcons.helpCircle,
                          color: _selectedKey == q.correctKey ? TaklukColors.success : TaklukColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedKey == q.correctKey ? 'Jawaban Kamu Benar!' : 'Pembahasan Langkah Demi Langkah',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _selectedKey == q.correctKey ? TaklukColors.success : TaklukColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MarkdownBody(
                      data: q.explanationMd,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: TaklukColors.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (q.relatedVideoId != null) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          context.push('/player/${q.relatedVideoId}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: TaklukColors.tintWarm,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.playCircle, color: TaklukColors.accent, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Tonton Video Pembahasan Soal Ini →',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TaklukColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TaklukButton(
                label: _currentIndex < _questions.length - 1 ? 'Soal Berikutnya →' : 'Selesai Latihan',
                onPressed: _nextQuestion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

