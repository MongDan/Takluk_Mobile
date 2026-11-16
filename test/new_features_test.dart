import 'package:flutter_test/flutter_test.dart';
import 'package:takluk/core/widgets/takluk_math_view.dart';
import 'package:takluk/core/widgets/takluk_shimmer.dart';
import 'package:takluk/features/hub/presentation/widgets/hub_seat_map.dart';

void main() {
  group('TaklukMathView', () {
    test('menginstansiasi pure formula dan mixed LaTeX string', () {
      const pureMath = TaklukMathView(
        text: r'\int_0^1 x^2 dx = \frac{1}{3}',
        isPureFormula: true,
      );
      expect(pureMath.isPureFormula, isTrue);

      const mixedMath = TaklukMathView(
        text: r'Tentukan nilai dari $\lim_{x \to 0} \frac{\sin x}{x}$!',
      );
      expect(mixedMath.text.contains(r'$'), isTrue);
    });
  });

  group('TaklukShimmer', () {
    test('membuat builder skeleton shimmer', () {
      final box = TaklukShimmer.box(width: 100, height: 20);
      expect(box, isNotNull);

      final courses = TaklukShimmer.courseCards();
      expect(courses, isNotNull);

      final videos = TaklukShimmer.videoRows();
      expect(videos, isNotNull);
    });
  });

  group('HubSeatMapSelector', () {
    test('SeatItem model dan amenities', () {
      const seat = SeatItem(
        id: 'A3',
        code: 'A3',
        label: 'Meja Fokus A3',
        type: SeatType.focus,
        description: 'Sisi Jendela',
        amenities: ['2x Colokan', 'Wi-Fi 100 Mbps'],
      );

      expect(seat.code, 'A3');
      expect(seat.type, SeatType.focus);
      expect(seat.status, SeatStatus.available);
      expect(seat.amenities.length, 2);

      final updated = seat.copyWith(status: SeatStatus.selected);
      expect(updated.status, SeatStatus.selected);
    });
  });
}

