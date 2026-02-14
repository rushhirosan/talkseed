import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;
import '../utils/dice_3d_utils.dart';

/// CustomPaint による 3D サイコロ描画（1 回の paint で 6 面を描画）。
/// ウィジェットツリーを軽くし、再描画コストを抑えるための代替実装。
/// 使用する場合は dice_page で DiceWidget の代わりに [DiceCustomPaint] を指定可能。

// 面データ（DiceWidget の _cubeFaceData と同一）
class _FaceInfo {
  const _FaceInfo(this.number, this.x, this.y, this.z, this.rot);
  final int number;
  final double x, y, z;
  final vm.Matrix4 rot;
}

final _cubeFaceData = _buildCubeFaceData();

List<_FaceInfo> _buildCubeFaceData() {
  const halfSize = Dice3DUtils.diceSize / 2;
  return [
    _FaceInfo(1, 0.0, 0.0, halfSize, vm.Matrix4.identity()),
    _FaceInfo(6, 0.0, 0.0, -halfSize, vm.Matrix4.identity()..rotateY(math.pi)),
    _FaceInfo(4, halfSize, 0.0, 0.0, vm.Matrix4.identity()..rotateY(math.pi / 2)),
    _FaceInfo(3, -halfSize, 0.0, 0.0, vm.Matrix4.identity()..rotateY(-math.pi / 2)),
    _FaceInfo(2, 0.0, -halfSize, 0.0, vm.Matrix4.identity()..rotateX(-math.pi / 2)),
    _FaceInfo(5, 0.0, halfSize, 0.0, vm.Matrix4.identity()..rotateX(math.pi / 2)),
  ];
}

const _faceColors = [
  Color(0xFFFFF9C4), // 1
  Color(0xFFB8E6B8), // 2
  Color(0xFFFFE5CC), // 3
  Color(0xFFCCE5E5), // 4
  Color(0xFFFFCCCC), // 5
  Color(0xFFFFEB3B), // 6
];

const _white = Colors.white;
const _black = Colors.black87;
const _borderRadius = 8.0;

class _FaceWithDepth {
  _FaceWithDepth(this.face, this.depth);
  final _FaceInfo face;
  final double depth;
}

/// CustomPaint 用の 3D サイコロ Painter
class DicePainter extends CustomPainter {
  DicePainter({
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.themes,
  });

  final double rotX, rotY, rotZ;
  final List<String> themes;

  @override
  void paint(Canvas canvas, Size size) {
    final rotationMatrix = vm.Matrix4.identity()
      ..rotateY(rotY)
      ..rotateX(rotX)
      ..rotateZ(rotZ);
    final m = rotationMatrix.storage;
    const faceCount = 6;

    final facesWithDepth = List<_FaceWithDepth>.filled(faceCount, _FaceWithDepth(_cubeFaceData[0], 0));
    double minDepth = double.infinity;
    double maxDepth = double.negativeInfinity;
    for (int i = 0; i < faceCount; i++) {
      final f = _cubeFaceData[i];
      final transformedZ = m[2] * f.x + m[6] * f.y + m[10] * f.z + m[14];
      if (transformedZ < minDepth) minDepth = transformedZ;
      if (transformedZ > maxDepth) maxDepth = transformedZ;
      facesWithDepth[i] = _FaceWithDepth(f, transformedZ);
    }
    facesWithDepth.sort((a, b) => a.depth.compareTo(b.depth));
    final depthRange = maxDepth - minDepth;

    final halfSize = size.width / 2;
    final center = Offset(halfSize, halfSize);

    for (int i = 0; i < faceCount; i++) {
      final item = facesWithDepth[i];
      final f = item.face;
      final depth = item.depth;
      final normalizedDepth = depthRange > 0 ? (depth - minDepth) / depthRange : 0.5;
      final brightness = 0.6 + (normalizedDepth * 0.4);

      final faceTransform = vm.Matrix4.identity()
        ..translateByDouble(f.x, f.y, f.z, 1.0)
        ..multiply(f.rot);
      final finalTransform = vm.Matrix4.identity()
        ..multiply(rotationMatrix)
        ..multiply(faceTransform);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.transform(Float64List.fromList(finalTransform.storage));
      canvas.translate(-center.dx, -center.dy);

      _drawFace(canvas, f.number, brightness, size);
      _drawFaceText(canvas, f.number, brightness, size);
      canvas.restore();
    }
  }

  void _drawFace(Canvas canvas, int number, double brightness, Size size) {
    final faceColor = _faceColors[(number - 1) % _faceColors.length];
    final baseColor = Color.lerp(faceColor, _white, 0.2 * brightness) ?? faceColor;
    final gradientColor = Color.lerp(faceColor, _white, 0.4 * (1.0 - brightness)) ?? faceColor;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_borderRadius));

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [baseColor, gradientColor],
      );
    canvas.drawRRect(rrect, fillPaint);

    final borderPaint = Paint()
      ..color = _black.withValues(alpha: 0.6 * brightness)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawFaceText(Canvas canvas, int number, double brightness, Size size) {
    final themeIndex = number - 1;
    final themeText = themeIndex >= 0 && themeIndex < themes.length ? themes[themeIndex] : '';

    final textPainter = TextPainter(
      text: TextSpan(
        text: themeText,
        style: TextStyle(
          color: _black.withValues(alpha: 0.95 * brightness),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 0.2,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 4,
      ellipsis: '…',
    );
    textPainter.layout(maxWidth: size.width - 24);

    // 面 2, 5 はテキスト上下補正のため X 軸 180 度
    final needTextFlip = number == 2 || number == 5;
    if (needTextFlip) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.transform(Float64List.fromList((vm.Matrix4.identity()..rotateX(math.pi)).storage));
      canvas.translate(-size.width / 2, -size.height / 2);
    }

    final x = (size.width - textPainter.width) / 2;
    final y = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(x, y));

    if (needTextFlip) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.rotZ != rotZ ||
        oldDelegate.themes != themes;
  }
}

/// CustomPaint を使った 3D サイコロウィジェット
class DiceCustomPaint extends StatelessWidget {
  const DiceCustomPaint({
    super.key,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    this.themes = const [],
  });

  final double rotX, rotY, rotZ;
  final List<String> themes;

  @override
  Widget build(BuildContext context) {
    const size = Dice3DUtils.diceSize;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CustomPaint(
          size: const Size(size, size),
          painter: DicePainter(rotX: rotX, rotY: rotY, rotZ: rotZ, themes: themes),
        ),
      ),
    );
  }
}
