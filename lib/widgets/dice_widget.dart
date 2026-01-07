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
    this.themes = ThemeModel.defaultThemes,
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
      child: Stack(
        children: faces,
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

  /// 正方形の面を描画（正六面体用）
  Widget _buildSquareFace(BuildContext context, int number, {required double brightness, required vm.Matrix4 textCorrection}) {
    return Container(
      width: Dice3DUtils.diceSize,
      height: Dice3DUtils.diceSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.95 * brightness),
        border: Border.all(
          color: Colors.grey.shade400.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25 * brightness),
            blurRadius: 12,
            offset: const Offset(3, 3),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9 * brightness),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Transform(
        transform: textCorrection,
        alignment: Alignment.center,
        child: _buildDiceFaceContent(context, number, brightness: brightness),
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
    
    final textColor = Colors.black87.withOpacity(0.9 * brightness);
    
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Text(
          themeText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
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

