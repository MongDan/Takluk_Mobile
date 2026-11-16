import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

enum SeatType { focus, booth, pod }

enum SeatStatus { available, occupied, selected }

class SeatItem {
  final String id;
  final String code;
  final String label;
  final SeatType type;
  final SeatStatus status;
  final String description;
  final List<String> amenities;

  const SeatItem({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
    this.status = SeatStatus.available,
    required this.description,
    this.amenities = const [],
  });

  SeatItem copyWith({SeatStatus? status}) {
    return SeatItem(
      id: id,
      code: code,
      label: label,
      type: type,
      status: status ?? this.status,
      description: description,
      amenities: amenities,
    );
  }
}

/// Denah Interaktif Pemilihan Kursi Fisik Quiet Study Space Panam Academy Hub
class HubSeatMapSelector extends StatefulWidget {
  final String? initialSelectedSeatId;
  final ValueChanged<SeatItem>? onSeatSelected;

  const HubSeatMapSelector({
    super.key,
    this.initialSelectedSeatId,
    this.onSeatSelected,
  });

  @override
  State<HubSeatMapSelector> createState() => _HubSeatMapSelectorState();
}

class _HubSeatMapSelectorState extends State<HubSeatMapSelector> {
  late List<SeatItem> _seats;
  String? _selectedSeatId;

  @override
  void initState() {
    super.initState();
    _selectedSeatId = widget.initialSelectedSeatId ?? 'A3';
    _initSeats();
  }

  void _initSeats() {
    // Daftar kursi denah Lantai 2 Panam Academy Hub
    _seats = [
      // Baris A (Meja Fokus Jendela)
      const SeatItem(
        id: 'A1',
        code: 'A1',
        label: 'Meja Fokus A1',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Sisi Jendela • Cahaya Alami • Meja Partisi Kayu',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps', 'Kursi Ergonomis'],
      ),
      const SeatItem(
        id: 'A2',
        code: 'A2',
        label: 'Meja Fokus A2',
        type: SeatType.focus,
        status: SeatStatus.occupied,
        description: 'Sisi Jendela • Sedang Digunakan Mahasiswa UIN',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'A3',
        code: 'A3',
        label: 'Meja Fokus A3',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Sisi Jendela • Favorit Menghadap Jalan HR. Soebrantas',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps', 'Kursi Ergonomis'],
      ),
      const SeatItem(
        id: 'A4',
        code: 'A4',
        label: 'Meja Fokus A4',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Fokus Dekat Rak Buku Referensi',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'A5',
        code: 'A5',
        label: 'Meja Fokus A5',
        type: SeatType.focus,
        status: SeatStatus.occupied,
        description: 'Sedang Terisi (Sesi Belajar Skripsi)',
        amenities: ['2x Colokan', 'Lampu Meja LED'],
      ),
      const SeatItem(
        id: 'A6',
        code: 'A6',
        label: 'Meja Fokus A6',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Fokus Sudut Hening',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),

      // Baris B (Meja Fokus Tengah)
      const SeatItem(
        id: 'B1',
        code: 'B1',
        label: 'Meja Fokus B1',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Partisi Tinggi Akustik',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'B2',
        code: 'B2',
        label: 'Meja Fokus B2',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Partisi Tinggi Akustik',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'B3',
        code: 'B3',
        label: 'Meja Fokus B3',
        type: SeatType.focus,
        status: SeatStatus.occupied,
        description: 'Sedang Terisi',
        amenities: ['2x Colokan', 'Lampu Meja LED'],
      ),
      const SeatItem(
        id: 'B4',
        code: 'B4',
        label: 'Meja Fokus B4',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Partisi Tinggi Dekat AC',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'B5',
        code: 'B5',
        label: 'Meja Fokus B5',
        type: SeatType.focus,
        status: SeatStatus.available,
        description: 'Meja Single Partisi Tinggi Dekat AC',
        amenities: ['2x Colokan', 'Lampu Meja LED', 'Wi-Fi 100 Mbps'],
      ),
      const SeatItem(
        id: 'B6',
        code: 'B6',
        label: 'Meja Fokus B6',
        type: SeatType.focus,
        status: SeatStatus.occupied,
        description: 'Sedang Terisi',
        amenities: ['2x Colokan', 'Lampu Meja LED'],
      ),

      // Baris C (Acoustic Soundproof Booth)
      const SeatItem(
        id: 'C1',
        code: 'C1',
        label: 'Booth Kedap Suara C1',
        type: SeatType.booth,
        status: SeatStatus.available,
        description: 'Booth Tertutup Peredam Suara • Cocok Bimbingan Online/Zoom',
        amenities: ['Ring Light', 'Peredam Akustik', '3x Colokan', 'LAN RJ-45'],
      ),
      const SeatItem(
        id: 'C2',
        code: 'C2',
        label: 'Booth Kedap Suara C2',
        type: SeatType.booth,
        status: SeatStatus.occupied,
        description: 'Sedang Dipakai Sesi Mock Seminar Proposal',
        amenities: ['Ring Light', 'Peredam Akustik'],
      ),
      const SeatItem(
        id: 'C3',
        code: 'C3',
        label: 'Booth Kedap Suara C3',
        type: SeatType.booth,
        status: SeatStatus.available,
        description: 'Booth Tertutup Peredam Suara • Private Space',
        amenities: ['Ring Light', 'Peredam Akustik', '3x Colokan'],
      ),
      const SeatItem(
        id: 'C4',
        code: 'C4',
        label: 'Booth Kedap Suara C4',
        type: SeatType.booth,
        status: SeatStatus.available,
        description: 'Booth Tertutup Peredam Suara • Private Space',
        amenities: ['Ring Light', 'Peredam Akustik', '3x Colokan'],
      ),

      // Baris D (Discussion Pods 2-4 pax)
      const SeatItem(
        id: 'D1',
        code: 'D1',
        label: 'Pod Diskusi D1',
        type: SeatType.pod,
        status: SeatStatus.available,
        description: 'Sofa Semi-Tertutup • Kapasitas 2-4 Orang Belajar Kelompok',
        amenities: ['Whiteboard Kecil', '4x Colokan', 'Meja Bundar'],
      ),
      const SeatItem(
        id: 'D2',
        code: 'D2',
        label: 'Pod Diskusi D2',
        type: SeatType.pod,
        status: SeatStatus.occupied,
        description: 'Sedang Terisi Belajar Kelompok Kalkulus',
        amenities: ['Whiteboard Kecil', '4x Colokan'],
      ),
    ];
  }

  SeatItem? get _selectedSeat {
    if (_selectedSeatId == null) return null;
    return _seats.firstWhere(
      (s) => s.id == _selectedSeatId,
      orElse: () => _seats.first,
    );
  }

  void _onSeatTap(SeatItem seat) {
    if (seat.status == SeatStatus.occupied) return;
    setState(() => _selectedSeatId = seat.id);
    widget.onSeatSelected?.call(seat);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedSeat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.armchair, size: 18, color: TaklukColors.primary),
                SizedBox(width: 8),
                Text(
                  'Pilih Kursi (Lantai 2)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TaklukColors.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Quiet Zone 🔇',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: TaklukColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: TaklukColors.surface,
              borderColor: TaklukColors.primary.withOpacity(0.4),
              label: 'Tersedia',
            ),
            const SizedBox(width: 14),
            _buildLegendItem(
              color: TaklukColors.accent,
              borderColor: TaklukColors.accent,
              label: 'Terpilih',
              textColor: Colors.white,
            ),
            const SizedBox(width: 14),
            _buildLegendItem(
              color: const Color(0xFFE5E7EB),
              borderColor: const Color(0xFFD1D5DB),
              label: 'Terisi',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Floor Plan Canvas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TaklukColors.line),
          ),
          child: Column(
            children: [
              // Ruang Depan & Pintu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TaklukColors.line),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.doorOpen, size: 14, color: TaklukColors.muted),
                    SizedBox(width: 6),
                    Text(
                      'Pintu Masuk & Bar Kopi / Dispenser',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: TaklukColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section: Meja Fokus (Baris A)
              _buildSectionTitle('Zona Meja Fokus Sisi Jendela (A)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _seats
                    .where((s) => s.id.startsWith('A'))
                    .map(_buildSeatNode)
                    .toList(),
              ),
              const SizedBox(height: 14),

              // Section: Meja Fokus Tengah (Baris B)
              _buildSectionTitle('Zona Meja Fokus Tengah (B)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _seats
                    .where((s) => s.id.startsWith('B'))
                    .map(_buildSeatNode)
                    .toList(),
              ),
              const SizedBox(height: 14),

              // Section: Acoustic Booth & Pod Diskusi (C & D)
              _buildSectionTitle('Booth Mandiri (C) & Pod Diskusi (D)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _seats
                    .where((s) => s.id.startsWith('C') || s.id.startsWith('D'))
                    .map(_buildSeatNode)
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Selected Seat Detail Card
        if (selected != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TaklukColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TaklukColors.accent.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: TaklukColors.accent.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected.label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TaklukColors.ink,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFFD97706)),
                          SizedBox(width: 4),
                          Text(
                            'Kursi Siap Dipesan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  selected.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: TaklukColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: selected.amenities
                      .map(
                        (amenity) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F0FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '✓ $amenity',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: TaklukColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: TaklukColors.muted,
        ),
      ),
    );
  }

  Widget _buildSeatNode(SeatItem seat) {
    final isSelected = seat.id == _selectedSeatId;
    final isOccupied = seat.status == SeatStatus.occupied;

    Color bg;
    Color border;
    Color textCol;

    if (isSelected) {
      bg = TaklukColors.accent;
      border = TaklukColors.accent;
      textCol = Colors.white;
    } else if (isOccupied) {
      bg = const Color(0xFFE5E7EB);
      border = const Color(0xFFD1D5DB);
      textCol = const Color(0xFF9CA3AF);
    } else {
      bg = Colors.white;
      border = TaklukColors.primary.withOpacity(0.35);
      textCol = TaklukColors.primary;
    }

    return GestureDetector(
      onTap: isOccupied ? null : () => _onSeatTap(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TaklukColors.accent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seat.type == SeatType.booth
                  ? LucideIcons.mic
                  : seat.type == SeatType.pod
                      ? LucideIcons.users
                      : LucideIcons.laptop,
              size: 14,
              color: textCol,
            ),
            const SizedBox(height: 2),
            Text(
              seat.code,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: TaklukColors.muted,
          ),
        ),
      ],
    );
  }
}

