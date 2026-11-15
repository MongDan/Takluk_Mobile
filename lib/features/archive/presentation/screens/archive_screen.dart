import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/domain/models/archive_question_model.dart';
import '../../../../core/domain/models/course_model.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_chip.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/archive_provider.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  University? _selectedUniversity;
  ExamType? _selectedExamType;

  @override
  Widget build(BuildContext context) {
    final courses =
        ref.watch(coursesProvider).valueOrNull ?? const <CourseModel>[];
    final questionsAsync = ref.watch(
      archiveQuestionsProvider((
        university: _selectedUniversity,
        examType: _selectedExamType,
      )),
    );
    final allQuestions =
        questionsAsync.valueOrNull ?? const <ArchiveQuestionModel>[];

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bank Arsip Soal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Arsip soal UTS/UAS asli dari dosen kampus Pekanbaru',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kampus filter chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TaklukChip(
                    label: 'Semua Kampus',
                    isActive: _selectedUniversity == null,
                    onTap: () => setState(() => _selectedUniversity = null),
                  ),
                  const SizedBox(width: 8),
                  ...[University.UNRI, University.UIN_SUSKA, University.PCR, University.UIR].map(
                    (u) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TaklukChip(
                        label: u.label,
                        isActive: _selectedUniversity == u,
                        onTap: () => setState(
                          () => _selectedUniversity = _selectedUniversity == u ? null : u,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // UTS/UAS filter chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TaklukChip(
                    label: 'Semua Ujian',
                    isActive: _selectedExamType == null,
                    onTap: () => setState(() => _selectedExamType = null),
                  ),
                  const SizedBox(width: 8),
                  ...ExamType.values.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TaklukChip(
                        label: e.label,
                        isActive: _selectedExamType == e,
                        onTap: () => setState(
                          () => _selectedExamType = _selectedExamType == e ? null : e,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (questionsAsync.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (questionsAsync.hasError)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'Gagal memuat arsip soal: ${questionsAsync.error}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: TaklukColors.error,
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, TaklukSpacing.bottomSafe),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final questions = allQuestions
                      .where((q) => q.courseId == course.id)
                      .toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TaklukColors.surface,
                      borderRadius: TaklukRadius.cardBR,
                      border: Border.all(color: TaklukColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: TaklukGradients.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  course.symbol,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: TaklukColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${questions.length} Bank Soal Tersedia',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: TaklukColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: TaklukColors.line),
                        const SizedBox(height: 8),

                        ...questions.take(2).map((q) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TaklukColors.tint,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${q.universityTag.value} • ${q.examType.label}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: TaklukColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.questionMarkdown.replaceAll(RegExp(r'[\$]'), ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: TaklukColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                        const SizedBox(height: 14),
                        TaklukButton(
                          label: 'Mulai Latihan Soal Interaktif',
                          icon: LucideIcons.checkSquare,
                          onPressed: () {
                            context.push('/quiz/${course.id}');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

