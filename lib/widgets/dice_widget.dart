import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/polyhedron_type.dart';
import '../utils/dice_3d_utils.dart';

/// 正六面体の面データ1件（深度ソート・描画用の軽量表現）
class _FaceInfo {
  const _FaceInfo(this.number, this.x, this.y, this.z, this.rot);
  final int number;
  final double x, y, z;
  final vm.Matrix4 rot;
}

/// 深度付き面（ソート済みリスト用）
class _FaceWithDepth {
  _FaceWithDepth(this.face, this.depth);
  final _FaceInfo face;
  final double depth;
}

/// 正六面体の静的な面データ（ビルドごとの再生成を避ける）
final _cubeFaceData = _buildCubeFaceDataOnce();

List<_FaceInfo> _buildCubeFaceDataOnce() {
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

/// 3Dサイコロウィジェット
class DiceWidget extends StatelessWidget {
  final double rotX;
  final double rotY;
  final double rotZ;
  final List<String> themes;
  final PolyhedronType polyhedronType;

  const DiceWidget({
    super.key,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.polyhedronType,
    this.themes = const [],
  });

  /// 3Dサイコロ全体を構築
  @override
  Widget build(BuildContext context) {
    const size = Dice3DUtils.diceSize;

    // 回転マトリックスを作成
    final rotationMatrix = vm.Matrix4.identity()
      ..rotateY(rotY)
      ..rotateX(rotX)
      ..rotateZ(rotZ);

    final m = rotationMatrix.storage;
    const int faceCount = 6;

    // 1パス: 深度計算 + min/max 同時取得（余計な List を生成しない）
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

    // 各面を描画（奥から手前の順）
    final faces = List<Widget>.filled(faceCount, const SizedBox.shrink());
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

      faces[i] = _buildDiceFace(context, f.number, transform: finalTransform, brightness: brightness);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: faces,
        ),
      ),
    );
  }

  /// 3Dサイコロの各面を描画
  /// 現在は正六面体のみをサポートしています
  Widget _buildDiceFace(
    BuildContext context,
    int number, {
    required vm.Matrix4 transform,
    double brightness = 1.0,
  }) {
    // X軸回転が関与する面（面2と面5）のテキストを補正
    // これらの面でテキストが上下逆になるのを防ぐため、X軸で180度回転を追加
    final vm.Matrix4 textCorrection;
    if (number == 2 || number == 5) {
      textCorrection = vm.Matrix4.identity()..rotateX(math.pi);
    } else {
      textCorrection = vm.Matrix4.identity();
    }
    
    final faceWidget = _buildSquareFace(
            context,
            number,
            brightness: brightness,
            textCorrection: textCorrection,
    );
    
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: faceWidget,
    );
  }

  // カラーパレット（設定画面と統一）
  static const Color _mustardYellow = Color(0xFFFFEB3B); // マスタードイエロー
  static const Color _lightGreen = Color(0xFFB8E6B8); // ライトグリーン
  static const Color _lightOrange = Color(0xFFFFE5CC); // ライトオレンジ
  static const Color _lightPink = Color(0xFFFFCCCC); // ライトピンク
  static const Color _lightBlueGreen = Color(0xFFCCE5E5); // ライトブルーグリーン
  static const Color _lightYellow = Color(0xFFFFF9C4); // ライトイエロー
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  /// 面番号に基づいてパステルカラーを取得
  Color _getFaceColor(int number) {
    final colors = [
      _lightYellow,     // 面1
      _lightGreen,      // 面2
      _lightOrange,     // 面3
      _lightBlueGreen,  // 面4
      _lightPink,       // 面5
      _mustardYellow,   // 面6
    ];
    return colors[(number - 1) % colors.length];
  }

  /// 正方形の面を描画（正六面体用）
  Widget _buildSquareFace(BuildContext context, int number, {required double brightness, required vm.Matrix4 textCorrection}) {
    final baseBrightness = brightness;
    
    // 面番号に基づいてパステルカラーを取得
    final faceColor = _getFaceColor(number);
    
    // パステルカラーでグラデーションを構成
    final baseColor = Color.lerp(
      faceColor,
      _white,
      0.2 * baseBrightness,
    )?.withOpacity(0.98 * baseBrightness) ?? faceColor;
    
    final gradientColor = Color.lerp(
      faceColor,
      _white,
      0.4 * (1.0 - baseBrightness),
    )?.withOpacity(0.95 * baseBrightness) ?? faceColor;
    
    // 角の丸みを小さくして、3D変換時に面同士がしっかり接するようにする
    const borderRadius = 8.0;
    
    return Container(
      width: Dice3DUtils.diceSize,
      height: Dice3DUtils.diceSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            gradientColor,
          ],
          stops: const [0.0, 1.0],
        ),
        border: Border.all(
          color: _black.withOpacity(0.6 * baseBrightness),
          width: 1.5,
        ),
        boxShadow: [
          // メインシャドウ
          BoxShadow(
            color: _black.withOpacity(0.2 * baseBrightness),
            blurRadius: 16,
            offset: const Offset(4, 4),
            spreadRadius: 0,
          ),
          // ソフトシャドウ
          BoxShadow(
            color: _black.withOpacity(0.1 * baseBrightness),
            blurRadius: 8,
            offset: const Offset(2, 2),
            spreadRadius: -1,
          ),
          // ハイライト（前面のエッジ）
          BoxShadow(
            color: _white.withOpacity(0.5 * baseBrightness),
            blurRadius: 6,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 軽いハイライトオーバーレイ
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _white.withOpacity(0.3 * baseBrightness),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // コンテンツ
          Transform(
            transform: textCorrection,
            alignment: Alignment.center,
            child: _buildDiceFaceContent(context, number, brightness: brightness),
          ),
        ],
      ),
    );
  }

  // 注意: 正三角形の面を描画するコード（_buildTriangleFace）は削除されました
  // 正六面体のみをサポートするため、正方形の面のみを使用します
  // 正四面体・正八面体のコードは lib/polyhedrons/tetrahedron_octahedron_preserved.dart に保存されています

  /// サイコロの面にテーマテキストを描画
  Widget _buildDiceFaceContent(BuildContext context, int number, {double brightness = 1.0}) {
    // 数字（1-6）に対応するテーマを取得（インデックスは0-5）
    final themeIndex = number - 1;
    final themeText = themeIndex >= 0 && themeIndex < themes.length 
        ? themes[themeIndex] 
        : '';
    
    // テキスト色を黒で統一
    final textColor = _black.withOpacity(0.95 * brightness);
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          themeText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: 0.2,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// 注意: TriangleClipper と _TetrahedronPainter は削除されました
// 正六面体のみをサポートするため、これらは不要になりました
// 正四面体・正八面体のコードは lib/polyhedrons/tetrahedron_octahedron_preserved.dart に保存されています

