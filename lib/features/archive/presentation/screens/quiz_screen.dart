import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/models/archive_question_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../data/archive_repository.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String courseId;

  const QuizScreen({super.key, required this.courseId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<ArchiveQuestionModel> _questions = [];
  List<ArchiveQuestionModel> _originalQuestions = [];
  int _currentIndex = 0;
  String? _selectedKey;
  bool _isAnswered = false;
  bool _isEvaluating = false;
  bool _isLoading = true;
  String? _error;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final questions = await ref
          .read(archiveRepositoryProvider)
          .getQuestions(courseId: widget.courseId);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _originalQuestions = List.of(questions);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectOption(String key) async {
    if (_isAnswered || _isEvaluating) return;

    setState(() {
      _selectedKey = key;
      _isEvaluating = true;
    });

    try {
      final evaluation = await ref
          .read(archiveRepositoryProvider)
          .evaluate(questionId: _questions[_currentIndex].id, selectedKey: key);
      if (!mounted) return;
      setState(() {
        _questions[_currentIndex] = _questions[_currentIndex].withEvaluation(
          evaluation,
        );
        if (evaluation.isCorrect) _score++;
        _isAnswered = true;
        _isEvaluating = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isEvaluating = false;
        _selectedKey = null;
      });
      TaklukToast.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isEvaluating = false;
        _selectedKey = null;
      });
      TaklukToast.show(context, 'Gagal memeriksa jawaban', isError: true);
    }
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: TaklukColors.bg,
        appBar: const PushPageHeader(title: 'Latihan Soal'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: TaklukColors.bg,
        appBar: const PushPageHeader(title: 'Latihan Soal'),
        body: EmptyState(
          useLottie: _error == null,
          icon: LucideIcons.fileQuestion,
          title: _error != null ? 'Gagal Memuat Soal' : 'Belum Ada Soal',
          subtitle: _error ?? 'Bank soal untuk mata kuliah ini belum tersedia.',
          actionLabel: _error != null ? 'Coba Lagi' : null,
          onAction: _error != null ? _loadQuestions : null,
        ),
      );
    }

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
                    child: Icon(
                      LucideIcons.partyPopper,
                      size: 44,
                      color: TaklukColors.accent,
                    ),
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
                      _questions = List.of(_originalQuestions);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                    border: Border.all(
                      color: borderColor,
                      width: isChosen || (_isAnswered && isCorrect) ? 2 : 1,
                    ),
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
                              color: isChosen
                                  ? Colors.white
                                  : TaklukColors.primary,
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
                          const Icon(
                            LucideIcons.checkCircle,
                            color: TaklukColors.success,
                            size: 20,
                          )
                        else if (isChosen)
                          const Icon(
                            LucideIcons.xCircle,
                            color: TaklukColors.error,
                            size: 20,
                          ),
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
                    color: _selectedKey == q.correctKey
                        ? TaklukColors.success
                        : TaklukColors.line,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedKey == q.correctKey
                              ? LucideIcons.checkCircle
                              : LucideIcons.helpCircle,
                          color: _selectedKey == q.correctKey
                              ? TaklukColors.success
                              : TaklukColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedKey == q.correctKey
                              ? 'Jawaban Kamu Benar!'
                              : 'Pembahasan Langkah Demi Langkah',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _selectedKey == q.correctKey
                                ? TaklukColors.success
                                : TaklukColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MarkdownBody(
                      data: q.explanationMd ?? '',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: TaklukColors.tintWarm,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.playCircle,
                                color: TaklukColors.accent,
                                size: 16,
                              ),
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
                label: _currentIndex < _questions.length - 1
                    ? 'Soal Berikutnya →'
                    : 'Selesai Latihan',
                onPressed: _isEvaluating ? null : _nextQuestion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
