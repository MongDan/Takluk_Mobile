import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/app_theme.dart';

/// Widget untuk merender teks yang mengandung rumus matematika / LaTeX.
///
/// Mendukung:
/// - Inline math: `$f(x) = \int_0^1 x^2 dx$`
/// - Block / Display math: `$$\lim_{x \to 0} \frac{\sin x}{x} = 1$$`
/// - Formula murni tanpa tanda `$` (jika `isPureFormula: true`).
class TaklukMathView extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? mathStyle;
  final bool isPureFormula;
  final TextAlign textAlign;

  const TaklukMathView({
    super.key,
    required this.text,
    this.textStyle,
    this.mathStyle,
    this.isPureFormula = false,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = textStyle ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: TaklukColors.ink,
          height: 1.5,
        );

    final mStyle = mathStyle ??
        defaultStyle.copyWith(
          color: TaklukColors.primary,
          fontWeight: FontWeight.w600,
        );

    if (isPureFormula) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            text.trim(),
            textStyle: mStyle,
            mathStyle: MathStyle.display,
            onErrorFallback: (err) => Text(
              text,
              style: defaultStyle,
            ),
          ),
        ),
      );
    }

    // Cek apakah string mengandung delimiter LaTeX '$'
    if (!text.contains(r'$')) {
      return Text(
        text,
        style: defaultStyle,
        textAlign: textAlign,
      );
    }

    final spans = _parseMixedContent(text, defaultStyle, mStyle);

    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: spans),
    );
  }

  /// Memecah string menjadi token teks biasa dan token rumus LaTeX
  List<InlineSpan> _parseMixedContent(
    String input,
    TextStyle normalStyle,
    TextStyle formulaStyle,
  ) {
    final List<InlineSpan> spans = [];
    final pattern = RegExp(r'(\$\$(.*?)\$\$|\$(.*?)\$)', dotAll: true);

    int lastIndex = 0;
    for (final match in pattern.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: input.substring(lastIndex, match.start),
            style: normalStyle,
          ),
        );
      }

      final isDisplay = match.group(2) != null;
      final rawFormula = (isDisplay ? match.group(2) : match.group(3))?.trim() ?? '';

      if (rawFormula.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: isDisplay ? 6.0 : 0.0,
              ),
              child: Math.tex(
                rawFormula,
                textStyle: formulaStyle,
                mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
                onErrorFallback: (err) => Text(
                  rawFormula,
                  style: formulaStyle,
                ),
              ),
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(
        TextSpan(
          text: input.substring(lastIndex),
          style: normalStyle,
        ),
      );
    }

    return spans;
  }
}

