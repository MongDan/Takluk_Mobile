import 'package:flutter_test/flutter_test.dart';
import 'package:takluk/core/constants/enums.dart';
import 'package:takluk/core/domain/models/archive_question_model.dart';
import 'package:takluk/core/domain/models/course_model.dart';
import 'package:takluk/core/domain/models/hub_service_model.dart';
import 'package:takluk/core/domain/models/payment_status_model.dart';
import 'package:takluk/core/domain/models/profile_models.dart';
import 'package:takluk/core/domain/models/transaction_model.dart';
import 'package:takluk/core/domain/models/user_model.dart';
import 'package:takluk/core/domain/models/video_model.dart';
import 'package:takluk/core/domain/models/watch_history_model.dart';

/// Contoh payload diambil langsung dari respons backend Takluk
/// (campuran camelCase Drizzle & snake_case kontrak API).
void main() {
  group('CourseModel', () {
    test('membaca payload camelCase GET /api/courses', () {
      final course = CourseModel.fromJson({
        'id': '15042e32-9ee9-4130-b162-5456624ccb46',
        'slug': 'kalkulus-dasar-1',
        'title': 'Kalkulus',
        'symbol': '∫',
        'semesterTarget': 1,
        'description': 'Limit, turunan, integral',
        'sortOrder': 1,
      });

      expect(course.title, 'Kalkulus');
      expect(course.semesterTarget, 1);
      expect(course.sortOrder, 1);
      expect(course.isPublished, isTrue);
    });
  });

  group('VideoModel', () {
    test('membaca payload camelCase GET /api/courses/videos', () {
      final video = VideoModel.fromJson({
        'id': 'f713078f-11de-408d-9d01-6854b58e25f9',
        'courseId': '379842e0-ee02-454c-ba5e-d684a550fb69',
        'courseTitle': 'Pemrograman',
        'courseSymbol': '</>',
        'tutorName': 'Rizki Pratama',
        'title': 'Logika Percabangan & Array 2 Dimensi',
        'category': 'MATERI',
        'universityTag': null,
        'durationSeconds': 480,
        'isFree': true,
        'sortOrder': 1,
      });

      expect(video.courseName, 'Pemrograman');
      expect(video.category, VideoCategory.MATERI);
      expect(video.durationSeconds, 480);
      expect(video.isFree, isTrue);
      expect(video.universityTag, isNull);
      expect(video.formattedDuration, '08:00');
    });

    test('membaca bab tanpa video_id dari detail video', () {
      final video = VideoModel.fromJson({
        'id': 'a0e9e59b-2c43-4878-a24b-345cfa905c19',
        'courseId': '15042e32-9ee9-4130-b162-5456624ccb46',
        'courseTitle': 'Kalkulus',
        'title': 'Pengenalan Limit Fungsi',
        'category': 'MATERI',
        'durationSeconds': 450,
        'summaryMarkdown': '### Rangkuman',
        'chapters': [
          {'id': 'ch-1', 'title': 'Pengantar', 'start_second': 0, 'sort_order': 1},
        ],
      });

      expect(video.chapters, hasLength(1));
      expect(video.chapters.first.videoId, video.id);
      expect(video.chapters.first.formattedStart, '00:00');
    });
  });

  group('WatchHistoryModel', () {
    test('memetakan baris resume/bookmark berbentuk video', () {
      final history = WatchHistoryModel.fromProgressVideoJson(
        {
          'id': 'a0e9e59b-2c43-4878-a24b-345cfa905c19',
          'title': 'Pengenalan Limit Fungsi',
          'durationSeconds': 450,
          'courseTitle': 'Kalkulus',
          'courseSymbol': '∫',
          'lastPositionSec': 120,
          'isCompleted': false,
          'isFree': true,
          'lastWatchedAt': '2026-11-14T15:36:39.377Z',
        },
        isBookmarked: true,
      );

      expect(history.videoId, 'a0e9e59b-2c43-4878-a24b-345cfa905c19');
      expect(history.videoTitle, 'Pengenalan Limit Fungsi');
      expect(history.courseName, 'Kalkulus');
      expect(history.videoDurationSeconds, 450);
      expect(history.isBookmarked, isTrue);
      expect(history.progress, closeTo(120 / 450, 0.0001));
    });
  });

  group('ArchiveQuestionModel', () {
    test('payload arsip tidak menyertakan kunci jawaban', () {
      final question = ArchiveQuestionModel.fromJson({
        'id': 'fad7b3c5-a343-478f-926a-da1d5478e014',
        'courseId': '379842e0-ee02-454c-ba5e-d684a550fb69',
        'courseTitle': 'Pemrograman',
        'universityTag': 'PCR',
        'examType': 'UAS',
        'academicYear': '2024/2025',
        'questionMarkdown': 'Apa output kode berikut?',
        'optionsJson': [
          {'key': 'A', 'text': '[1, 3, 5]'},
          {'key': 'B', 'text': '[2, 4, 6]'},
        ],
      });

      expect(question.correctKey, isNull);
      expect(question.options, hasLength(2));
      expect(question.universityTag, University.PCR);
      expect(question.examType, ExamType.UAS);
    });

    test('withEvaluation melengkapi kunci & pembahasan', () {
      final question = ArchiveQuestionModel.fromJson({
        'id': 'q-1',
        'courseId': 'c-1',
        'universityTag': 'UNRI',
        'examType': 'UTS',
        'academicYear': '2024/2025',
        'questionMarkdown': 'Soal',
        'optionsJson': [
          {'key': 'A', 'text': '1'},
        ],
      });

      final evaluated = question.withEvaluation(
        ArchiveEvaluationModel.fromJson({
          'question_id': 'q-1',
          'selected_key': 'A',
          'is_correct': true,
          'correct_key': 'A',
          'explanation_md': '### Pembahasan',
          'related_video_id': null,
        }),
      );

      expect(evaluated.correctKey, 'A');
      expect(evaluated.explanationMd, '### Pembahasan');
    });
  });

  group('UserModel', () {
    test('membaca profil snake_case GET /api/profile/me', () {
      final user = UserModel.fromJson({
        'id': '779df7af-36bf-404f-b3e6-1a988b966251',
        'email': 'aisyah@takluk.dev',
        'full_name': 'Aisyah Putri',
        'nim': '12250312345',
        'university': 'UIN_SUSKA',
        'semester': 3,
        'phone_number': '081234567890',
        'referral_code': 'AISY1234',
        'active_device_id': 'device-1',
        'is_subscribed': false,
        'subscription_valid_until': null,
        'remaining_subscription_days': 0,
        'created_at': '2026-11-14T14:50:06.040Z',
      });

      expect(user.fullName, 'Aisyah Putri');
      expect(user.university, University.UIN_SUSKA);
      expect(user.referralCode, 'AISY1234');
      expect(user.isSubscribed, isFalse);
    });

    test('payload verify-otp tanpa referral_code tetap aman', () {
      final user = UserModel.fromJson({
        'id': '779df7af-36bf-404f-b3e6-1a988b966251',
        'email': 'aisyah@takluk.dev',
        'full_name': 'Aisyah Putri',
        'nim': '12250312345',
        'university': 'UIN_SUSKA',
        'semester': 3,
        'role': 'STUDENT',
        'subscription_valid_until': null,
        'is_new_user': false,
      });

      expect(user.referralCode, '');
      expect(user.role, UserRole.STUDENT);
    });
  });

  group('Payment', () {
    test('membaca respons POST /api/payments/qris', () {
      final tx = TransactionModel.fromJson({
        'invoice_number': 'INV-TKL-20261114-UPH55',
        'base_amount': 25000,
        'discount_amount': 10000,
        'final_amount': 15000,
        'voucher_code': 'PANAM10',
        'payment_status': 'PENDING',
        'qris_string': '000201...',
        'expires_at': '2026-11-14T15:51:47.437Z',
        'expires_in_seconds': 900,
      });

      expect(tx.id, tx.invoiceNumber);
      expect(tx.finalAmount, 15000);
      expect(tx.discountAmount, 10000);
      expect(tx.paymentStatus, PaymentStatus.PENDING);
      expect(tx.qrisString, isNotNull);
    });

    test('membaca polling status pembayaran', () {
      final status = PaymentStatusModel.fromJson({
        'invoice_number': 'INV-TKL-20261114-UPH55',
        'payment_status': 'SUCCESS',
        'is_paid': true,
        'paid_at': '2026-11-14T15:36:47.464Z',
        'final_amount': 15000,
        'expires_at': '2026-11-14T15:51:47.437Z',
        'subscription_valid_until': '2026-12-14T15:36:47.467Z',
      });

      expect(status.isPaid, isTrue);
      expect(status.paymentStatus, PaymentStatus.SUCCESS);
      expect(status.subscriptionValidUntil, isNotNull);
    });
  });

  group('Profil & Hub', () {
    test('membaca statistik referral', () {
      final referral = ReferralModel.fromJson({
        'referral_code': 'AISY1234',
        'share_message': 'Ayo gabung Takluk!',
        'total_referred_users': 2,
        'bonus_days_earned': 14,
        'reward_rule': '7 hari per teman',
      });

      expect(referral.referralCode, 'AISY1234');
      expect(referral.totalReferredUsers, 2);
      expect(referral.bonusDaysEarned, 14);
    });

    test('membaca katalog layanan Panam Hub', () {
      final catalog = HubCatalogModel.fromJson({
        'hub_name': 'Panam Academy Hub (O2O Learning Hub)',
        'address': 'Jl. HR. Soebrantas, Panam',
        'operational_hours': 'Setiap Hari 08:00 - 22:00 WIB',
        'services': [
          {
            'id': 'svc-crash-course-h7',
            'name': 'Crash Course H-7 Ujian',
            'tagline': 'Review intensif',
            'category': 'EXAM_PREP',
            'price_idr': 150000,
            'price_formatted': 'Rp150.000',
            'unit': 'per paket / matkul',
            'location': 'Panam',
            'features': ['3x sesi'],
            'is_available': true,
          },
        ],
      });

      expect(catalog.services, hasLength(1));
      expect(catalog.services.first.category, 'EXAM_PREP');
      expect(catalog.services.first.priceFormatted, 'Rp150.000');
    });

    test('membaca status device binding', () {
      final device = DeviceBindingModel.fromJson({
        'active_device_id': 'device-1',
        'device_updated_at': '2026-11-14T15:36:22.499Z',
        'policy': '1 akun = 1 perangkat',
        'can_reset': true,
      });

      expect(device.activeDeviceId, 'device-1');
      expect(device.canReset, isTrue);
    });
  });
}
