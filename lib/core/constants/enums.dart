enum University {
  UNRI('UNRI', 'Universitas Riau'),
  UIN_SUSKA('UIN_SUSKA', 'UIN Sultan Syarif Kasim'),
  PCR('PCR', 'Politeknik Caltex Riau'),
  UIR('UIR', 'Universitas Islam Riau'),
  UMRI('UMRI', 'Universitas Muhammadiyah Riau'),
  LAINNYA('LAINNYA', 'Lainnya');

  final String value;
  final String label;
  const University(this.value, this.label);

  static University fromValue(String v) =>
      University.values.firstWhere((e) => e.value == v, orElse: () => LAINNYA);
}

enum VideoCategory {
  MATERI('MATERI', 'Materi'),
  UTS('UTS', 'Bedah Soal UTS'),
  UAS('UAS', 'Bedah Soal UAS');

  final String value;
  final String label;
  const VideoCategory(this.value, this.label);
}

enum ExamType {
  UTS('UTS', 'UTS'),
  UAS('UAS', 'UAS');

  final String value;
  final String label;
  const ExamType(this.value, this.label);
}

enum PaymentStatus {
  PENDING('PENDING', 'Menunggu'),
  SUCCESS('SUCCESS', 'Berhasil'),
  FAILED('FAILED', 'Gagal'),
  EXPIRED('EXPIRED', 'Kedaluwarsa');

  final String value;
  final String label;
  const PaymentStatus(this.value, this.label);
}

enum UserRole {
  STUDENT('STUDENT', 'Mahasiswa'),
  TUTOR('TUTOR', 'Tutor'),
  ADMIN('ADMIN', 'Admin');

  final String value;
  final String label;
  const UserRole(this.value, this.label);
}
