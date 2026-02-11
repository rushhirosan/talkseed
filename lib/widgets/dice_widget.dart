import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/theme.dart';
import '../models/polyhedron_type.dart';
import '../utils/dice_3d_utils.dart';

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

  /// 正六面体の各面のデータを取得
  /// 現在は正六面体のみをサポートしています
  /// 正四面体・正八面体のコードは lib/polyhedrons/tetrahedron_octahedron_preserved.dart に保存されています
  List<Map<String, dynamic>> _getFaceData(double halfSize) {
        return _getCubeFaceData(halfSize);
  }

  /// 正六面体（立方体）の各面のデータ
  List<Map<String, dynamic>> _getCubeFaceData(double halfSize) {
    return [
      {'number': 1, 'x': 0.0, 'y': 0.0, 'z': halfSize, 'rot': vm.Matrix4.identity()},
      {'number': 6, 'x': 0.0, 'y': 0.0, 'z': -halfSize, 'rot': vm.Matrix4.identity()..rotateY(math.pi)},
      {'number': 4, 'x': halfSize, 'y': 0.0, 'z': 0.0, 'rot': vm.Matrix4.identity()..rotateY(math.pi / 2)},
      {'number': 3, 'x': -halfSize, 'y': 0.0, 'z': 0.0, 'rot': vm.Matrix4.identity()..rotateY(-math.pi / 2)},
      {'number': 2, 'x': 0.0, 'y': -halfSize, 'z': 0.0, 'rot': vm.Matrix4.identity()..rotateX(-math.pi / 2)},
      {'number': 5, 'x': 0.0, 'y': halfSize, 'z': 0.0, 'rot': vm.Matrix4.identity()..rotateX(math.pi / 2)},
    ];
  }

  // 注意: 正四面体と正八面体のコードは lib/polyhedrons/tetrahedron_octahedron_preserved.dart に保存されています
  // 将来的に使用する可能性があるため、削除せずに保存用ファイルに移動しました

  /// 3Dサイコロ全体を構築
  @override
  Widget build(BuildContext context) {
    const size = Dice3DUtils.diceSize;
    const halfSize = size / 2;

    // 回転マトリックスを作成
    final rotationMatrix = vm.Matrix4.identity()
      ..rotateY(rotY)
      ..rotateX(rotX)
      ..rotateZ(rotZ);

    // 各面の初期位置と回転を定義（多面体タイプに応じて）
    final faceData = _getFaceData(halfSize);

    // 各面のZ座標を計算して、深度順にソート（奥から手前へ）
    final m = rotationMatrix.storage;
    final facesWithDepth = faceData.map((face) {
      final x = face['x'] as double;
      final y = face['y'] as double;
      final z = face['z'] as double;
      
      // 回転後のZ座標を計算（Matrix4の要素に直接アクセス）
      // transformed = rotationMatrix * [x, y, z, 1]^T
      // Matrix4のstorageは列優先順序で格納されている
      // storage[2, 6, 10, 14]が3列目（Z座標）の要素
      final transformedZ = m[2] * x + m[6] * y + m[10] * z + m[14];
      
      return {
        'face': face,
        'depth': transformedZ,
      };
    }).toList();

    // Z座標でソート（奥から手前へ、小さい順）
    facesWithDepth.sort((a, b) => (a['depth'] as double).compareTo(b['depth'] as double));

    // 最大・最小のZ座標を取得して明るさの範囲を決定
    final depths = facesWithDepth.map((item) => item['depth'] as double).toList();
    final minDepth = depths.reduce((a, b) => a < b ? a : b);
    final maxDepth = depths.reduce((a, b) => a > b ? a : b);
    final depthRange = maxDepth - minDepth;

    // 各面を描画（奥から手前の順）
    final faces = facesWithDepth.map((item) {
      final face = item['face'] as Map<String, dynamic>;
      final number = face['number'] as int;
      final x = face['x'] as double;
      final y = face['y'] as double;
      final z = face['z'] as double;
      final faceRot = face['rot'] as vm.Matrix4;
      final depth = item['depth'] as double;
      
      // Z座標に基づいて明るさを計算（前面ほど明るく、背面ほど暗く）
      // depthRangeが0の場合は1.0を返す
      final normalizedDepth = depthRange > 0 
          ? (depth - minDepth) / depthRange 
          : 0.5;
      // 前面（大きいZ）ほど明るく、背面（小さいZ）ほど暗く
      // 0.6（背面）から1.0（前面）の範囲で調整
      final brightness = 0.6 + (normalizedDepth * 0.4);
      
      // 各面の変換マトリックスを作成
      // 正六面体の各面は独立しているため、シンプルに変換を適用
      final faceTransform = vm.Matrix4.identity()
        ..translate(x, y, z)
        ..multiply(faceRot);
      
      // 全体の回転マトリックスを適用
      final finalTransform = vm.Matrix4.identity()
        ..multiply(rotationMatrix)
        ..multiply(faceTransform);

      return _buildDiceFace(
        context,
        number,
        transform: finalTransform,
        brightness: brightness,
      );
    }).toList();

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

