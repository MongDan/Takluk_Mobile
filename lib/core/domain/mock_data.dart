import 'models/user_model.dart';
import 'models/course_model.dart';
import 'models/video_model.dart';
import 'models/watch_history_model.dart';
import 'models/archive_question_model.dart';
import '../constants/enums.dart';

class MockData {
  // Demo User
  static UserModel demoUser = UserModel(
    id: 'usr-demo-001',
    email: 'aisyah@demo.takluk.id',
    fullName: 'Aisyah Putri',
    nim: '12250312345',
    university: University.UIN_SUSKA,
    semester: 3,
    phoneNumber: '081234567890',
    role: UserRole.STUDENT,
    activeDeviceId: 'demo-device',
    referralCode: 'AISYAH23',
    subscriptionValidUntil: DateTime.now().add(const Duration(days: 25)),
    isActive: true,
    createdAt: DateTime(2026, 9, 1),
  );

  // Courses
  static final List<CourseModel> courses = [
    const CourseModel(
      id: 'crs-001',
      slug: 'kalkulus-dasar-1',
      title: 'Kalkulus',
      symbol: '∫',
      semesterTarget: 1,
      description: 'Kalkulus Dasar I - Limit, Turunan, dan Integral',
      sortOrder: 1,
      videoCount: 8,
      freeVideoCount: 1,
    ),
    const CourseModel(
      id: 'crs-002',
      slug: 'statistika-dasar',
      title: 'Statistika',
      symbol: 'σ',
      semesterTarget: 2,
      description: 'Statistika Dasar - Probabilitas dan Distribusi',
      sortOrder: 2,
      videoCount: 7,
      freeVideoCount: 1,
    ),
    const CourseModel(
      id: 'crs-003',
      slug: 'pemrograman-dasar',
      title: 'Pemrograman',
      symbol: '</>',
      semesterTarget: 1,
      description: 'Algoritma dan Pemrograman Dasar',
      sortOrder: 3,
      videoCount: 5,
      freeVideoCount: 1,
    ),
  ];

  // Videos
  static final List<VideoModel> videos = [
    // Kalkulus
    VideoModel(
      id: 'vid-001',
      courseId: 'crs-001',
      tutorId: 'ttr-001',
      title: 'Konsep Dasar Limit Fungsi',
      category: VideoCategory.MATERI,
      durationSeconds: 480,
      cfVideoUid: 'cf-vid-001',
      isFree: true,
      sortOrder: 1,
      tutorName: 'Rizky Aditya',
      courseName: 'Kalkulus',
      courseSymbol: '∫',
      summaryMarkdown: '## Ringkasan Limit Fungsi\n\nLimit fungsi \$f(x)\$ saat \$x \\to a\$ adalah nilai yang didekati \$f(x)\$ ketika \$x\$ mendekati \$a\$.\n\n### Rumus Penting\n- \$\\lim_{x \\to a} f(x) = L\$\n- \$\\lim_{x \\to a} [f(x) + g(x)] = \\lim_{x \\to a} f(x) + \\lim_{x \\to a} g(x)\$',
      chapters: [
        const VideoChapter(id: 'ch-001', videoId: 'vid-001', title: 'Pengantar Limit', startSecond: 0, sortOrder: 1),
        const VideoChapter(id: 'ch-002', videoId: 'vid-001', title: 'Definisi Formal Limit', startSecond: 120, sortOrder: 2),
        const VideoChapter(id: 'ch-003', videoId: 'vid-001', title: 'Contoh Soal', startSecond: 300, sortOrder: 3),
      ],
    ),
    VideoModel(
      id: 'vid-002',
      courseId: 'crs-001',
      tutorId: 'ttr-001',
      title: 'Bedah Soal UTS Kalkulus UNRI 2024/2025',
      category: VideoCategory.UTS,
      universityTag: University.UNRI,
      durationSeconds: 600,
      cfVideoUid: 'cf-vid-002',
      sortOrder: 2,
      tutorName: 'Rizky Aditya',
      courseName: 'Kalkulus',
      courseSymbol: '∫',
      summaryMarkdown: '## Pembahasan UTS Kalkulus UNRI\n\n### Soal 1: Limit\nHitung \$\\lim_{x \\to 2} \\frac{x^2 - 4}{x - 2}\$\n\n**Jawab:** Faktorkan: \$= \\lim_{x \\to 2} (x+2) = 4\$',
      chapters: [
        const VideoChapter(id: 'ch-010', videoId: 'vid-002', title: 'Soal 1: Limit Fungsi', startSecond: 0, sortOrder: 1),
        const VideoChapter(id: 'ch-011', videoId: 'vid-002', title: 'Soal 2: Turunan', startSecond: 180, sortOrder: 2),
        const VideoChapter(id: 'ch-012', videoId: 'vid-002', title: 'Soal 3: Integral', startSecond: 360, sortOrder: 3),
      ],
    ),
    VideoModel(
      id: 'vid-003',
      courseId: 'crs-001',
      tutorId: 'ttr-001',
      title: 'Rumus Turunan Rantai (Chain Rule)',
      category: VideoCategory.MATERI,
      durationSeconds: 420,
      cfVideoUid: 'cf-vid-003',
      sortOrder: 3,
      tutorName: 'Rizky Aditya',
      courseName: 'Kalkulus',
      courseSymbol: '∫',
    ),
    VideoModel(
      id: 'vid-004',
      courseId: 'crs-001',
      tutorId: 'ttr-001',
      title: 'Bedah Soal UAS Kalkulus UIN Suska',
      category: VideoCategory.UAS,
      universityTag: University.UIN_SUSKA,
      durationSeconds: 540,
      cfVideoUid: 'cf-vid-004',
      sortOrder: 4,
      tutorName: 'Rizky Aditya',
      courseName: 'Kalkulus',
      courseSymbol: '∫',
    ),
    // Statistika
    VideoModel(
      id: 'vid-005',
      courseId: 'crs-002',
      tutorId: 'ttr-002',
      title: 'Pengantar Probabilitas Dasar',
      category: VideoCategory.MATERI,
      durationSeconds: 450,
      cfVideoUid: 'cf-vid-005',
      isFree: true,
      sortOrder: 1,
      tutorName: 'Nadira Fitri',
      courseName: 'Statistika',
      courseSymbol: 'σ',
      summaryMarkdown: '## Probabilitas Dasar\n\n### Rumus\n- \$P(A) = \\frac{n(A)}{n(S)}\$\n- \$P(A \\cup B) = P(A) + P(B) - P(A \\cap B)\$',
    ),
    VideoModel(
      id: 'vid-006',
      courseId: 'crs-002',
      tutorId: 'ttr-002',
      title: 'Bedah Soal UTS Statistika PCR',
      category: VideoCategory.UTS,
      universityTag: University.PCR,
      durationSeconds: 550,
      cfVideoUid: 'cf-vid-006',
      sortOrder: 2,
      tutorName: 'Nadira Fitri',
      courseName: 'Statistika',
      courseSymbol: 'σ',
    ),
    VideoModel(
      id: 'vid-007',
      courseId: 'crs-002',
      tutorId: 'ttr-002',
      title: 'Distribusi Normal & Z-Score',
      category: VideoCategory.MATERI,
      durationSeconds: 380,
      cfVideoUid: 'cf-vid-007',
      sortOrder: 3,
      tutorName: 'Nadira Fitri',
      courseName: 'Statistika',
      courseSymbol: 'σ',
    ),
    // Pemrograman
    VideoModel(
      id: 'vid-008',
      courseId: 'crs-003',
      tutorId: 'ttr-003',
      title: 'Algoritma Sorting: Bubble & Selection',
      category: VideoCategory.MATERI,
      durationSeconds: 360,
      cfVideoUid: 'cf-vid-008',
      isFree: true,
      sortOrder: 1,
      tutorName: 'Farhan Pratama',
      courseName: 'Pemrograman',
      courseSymbol: '</>',
      summaryMarkdown: '## Algoritma Sorting\n\n### Bubble Sort\nKompleksitas: \$O(n^2)\$\n\n```python\ndef bubble_sort(arr):\n    n = len(arr)\n    for i in range(n):\n        for j in range(0, n-i-1):\n            if arr[j] > arr[j+1]:\n                arr[j], arr[j+1] = arr[j+1], arr[j]\n```',
    ),
    VideoModel(
      id: 'vid-009',
      courseId: 'crs-003',
      tutorId: 'ttr-003',
      title: 'Bedah Soal UTS Pemrograman UIR',
      category: VideoCategory.UTS,
      universityTag: University.UIR,
      durationSeconds: 480,
      cfVideoUid: 'cf-vid-009',
      sortOrder: 2,
      tutorName: 'Farhan Pratama',
      courseName: 'Pemrograman',
      courseSymbol: '</>',
    ),
    VideoModel(
      id: 'vid-010',
      courseId: 'crs-003',
      tutorId: 'ttr-003',
      title: 'Struktur Data: Stack & Queue',
      category: VideoCategory.MATERI,
      durationSeconds: 400,
      cfVideoUid: 'cf-vid-010',
      sortOrder: 3,
      tutorName: 'Farhan Pratama',
      courseName: 'Pemrograman',
      courseSymbol: '</>',
    ),
  ];

  // Watch Histories (demo data)
  static List<WatchHistoryModel> watchHistories = [
    WatchHistoryModel(
      id: 'wh-001',
      userId: 'usr-demo-001',
      videoId: 'vid-001',
      lastPositionSec: 240,
      totalWatchedSec: 240,
      isCompleted: false,
      isBookmarked: true,
      lastWatchedAt: DateTime.now().subtract(const Duration(hours: 2)),
      videoTitle: 'Konsep Dasar Limit Fungsi',
      courseSymbol: '∫',
      videoDurationSeconds: 480,
      courseName: 'Kalkulus',
    ),
    WatchHistoryModel(
      id: 'wh-002',
      userId: 'usr-demo-001',
      videoId: 'vid-005',
      lastPositionSec: 100,
      totalWatchedSec: 100,
      isCompleted: false,
      isBookmarked: false,
      lastWatchedAt: DateTime.now().subtract(const Duration(days: 1)),
      videoTitle: 'Pengantar Probabilitas Dasar',
      courseSymbol: 'σ',
      videoDurationSeconds: 450,
      courseName: 'Statistika',
    ),
  ];

  // Archive Questions
  static final List<ArchiveQuestionModel> archiveQuestions = [
    ArchiveQuestionModel(
      id: 'aq-001',
      courseId: 'crs-001',
      universityTag: University.UNRI,
      examType: ExamType.UTS,
      academicYear: '2024/2025',
      questionMarkdown: 'Hitung nilai dari \$\\lim_{x \\to 3} \\frac{x^2 - 9}{x - 3}\$',
      options: const [
        QuestionOption(key: 'A', text: '3'),
        QuestionOption(key: 'B', text: '6'),
        QuestionOption(key: 'C', text: '9'),
        QuestionOption(key: 'D', text: '0'),
      ],
      correctKey: 'B',
      explanationMd: '## Pembahasan\n\nFaktorkan pembilang:\n\n\$\\frac{x^2 - 9}{x - 3} = \\frac{(x+3)(x-3)}{x-3} = x + 3\$\n\nSubstitusi \$x = 3\$:\n\n\$= 3 + 3 = 6\$\n\n**Jawaban: B (6)**',
      relatedVideoId: 'vid-001',
    ),
    ArchiveQuestionModel(
      id: 'aq-002',
      courseId: 'crs-001',
      universityTag: University.UIN_SUSKA,
      examType: ExamType.UTS,
      academicYear: '2024/2025',
      questionMarkdown: 'Tentukan turunan dari \$f(x) = 3x^4 - 2x^2 + 5x - 1\$',
      options: const [
        QuestionOption(key: 'A', text: '\$12x^3 - 4x + 5\$'),
        QuestionOption(key: 'B', text: '\$12x^3 - 2x + 5\$'),
        QuestionOption(key: 'C', text: '\$3x^3 - 4x + 5\$'),
        QuestionOption(key: 'D', text: '\$12x^4 - 4x + 5\$'),
      ],
      correctKey: 'A',
      explanationMd: '## Pembahasan\n\nGunakan aturan pangkat:\n\n\$f\'(x) = 12x^3 - 4x + 5\$\n\n**Jawaban: A**',
      relatedVideoId: 'vid-003',
    ),
    ArchiveQuestionModel(
      id: 'aq-003',
      courseId: 'crs-002',
      universityTag: University.PCR,
      examType: ExamType.UTS,
      academicYear: '2024/2025',
      questionMarkdown: 'Jika \$P(A) = 0.4\$ dan \$P(B) = 0.3\$, dan A serta B saling lepas, maka \$P(A \\cup B) = \$',
      options: const [
        QuestionOption(key: 'A', text: '0.12'),
        QuestionOption(key: 'B', text: '0.58'),
        QuestionOption(key: 'C', text: '0.7'),
        QuestionOption(key: 'D', text: '0.1'),
      ],
      correctKey: 'C',
      explanationMd: '## Pembahasan\n\nKarena A dan B saling lepas (\$P(A \\cap B) = 0\$):\n\n\$P(A \\cup B) = P(A) + P(B) = 0.4 + 0.3 = 0.7\$\n\n**Jawaban: C (0.7)**',
      relatedVideoId: 'vid-005',
    ),
    ArchiveQuestionModel(
      id: 'aq-004',
      courseId: 'crs-003',
      universityTag: University.UIR,
      examType: ExamType.UTS,
      academicYear: '2024/2025',
      questionMarkdown: 'Apa kompleksitas waktu terburuk (worst-case) dari algoritma Bubble Sort?',
      options: const [
        QuestionOption(key: 'A', text: 'O(n)'),
        QuestionOption(key: 'B', text: 'O(n log n)'),
        QuestionOption(key: 'C', text: 'O(n²)'),
        QuestionOption(key: 'D', text: 'O(log n)'),
      ],
      correctKey: 'C',
      explanationMd: '## Pembahasan\n\nBubble Sort memiliki dua loop bersarang:\n- Loop luar: n kali\n- Loop dalam: n-1 kali (terburuk)\n\nTotal perbandingan: \$\\frac{n(n-1)}{2} \\approx O(n^2)\$\n\n**Jawaban: C (O(n²))**',
      relatedVideoId: 'vid-008',
    ),
  ];

  // UTS/UAS Exam schedule for countdown
  static DateTime get nextExamDate {
    final now = DateTime.now();
    // Find next UTS (around mid semester) or UAS
    final month = now.month;
    if (month >= 1 && month <= 3) {
      return DateTime(now.year, 3, 15); // UTS Genap
    } else if (month >= 4 && month <= 6) {
      return DateTime(now.year, 6, 10); // UAS Genap
    } else if (month >= 7 && month <= 9) {
      return DateTime(now.year, 10, 15); // UTS Ganjil
    } else {
      return DateTime(now.year + 1, 1, 10); // UAS Ganjil
    }
  }

  static String get nextExamLabel {
    final month = DateTime.now().month;
    if (month >= 1 && month <= 3) return 'UTS Genap';
    if (month >= 4 && month <= 6) return 'UAS Genap';
    if (month >= 7 && month <= 9) return 'UTS Ganjil';
    return 'UAS Ganjil';
  }
}
