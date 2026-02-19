import 'package:flutter/material.dart';
import 'dart:math';

/// 3Dサイコロの計算ユーティリティ
class Dice3DUtils {
  /// サイコロの面のサイズ（各面の一辺の長さ）
  static const double diceSize = 150.0;

  /// 回転時に角がクリップされないよう、描画領域を拡張したサイズ
  /// 立方体の対角線投影 2 * (halfSize * sqrt(2)) ≈ 212 にマージンを加えた値
  static const double diceDisplaySize = 230.0;

  /// 現在の回転状態から正面を向いている面の番号を取得
  /// 
  /// [rotX] X軸の回転角度（ラジアン）
  /// [rotY] Y軸の回転角度（ラジアン）
  /// [rotZ] Z軸の回転角度（ラジアン）
  /// 
  /// 戻り値: 正面を向いている面の番号（1-6）
  static int getFrontFace(double rotX, double rotY, double rotZ) {
    const halfSize = diceSize / 2;

    // 回転マトリックスを作成
    final rotationMatrix = Matrix4.identity()
      ..rotateY(rotY)
      ..rotateX(rotX)
      ..rotateZ(rotZ);

    // 各面の初期位置を定義
    final faceData = [
      {'number': 1, 'x': 0.0, 'y': 0.0, 'z': halfSize},
      {'number': 6, 'x': 0.0, 'y': 0.0, 'z': -halfSize},
      {'number': 4, 'x': halfSize, 'y': 0.0, 'z': 0.0},
      {'number': 3, 'x': -halfSize, 'y': 0.0, 'z': 0.0},
      {'number': 2, 'x': 0.0, 'y': -halfSize, 'z': 0.0},
      {'number': 5, 'x': 0.0, 'y': halfSize, 'z': 0.0},
    ];

    // 各面のZ座標を計算
    final m = rotationMatrix.storage;
    int frontFaceNumber = 1;
    double maxDepth = double.negativeInfinity;

    for (final face in faceData) {
      final x = face['x'] as double;
      final y = face['y'] as double;
      final z = face['z'] as double;
      
      // 回転後のZ座標を計算（最も手前にある面が正面）
      // Matrix4のstorageは列優先順序で格納されている
      // storage[2, 6, 10, 14]が3列目（Z座標）の要素
      final transformedZ = m[2] * x + m[6] * y + m[10] * z + m[14];
      
      if (transformedZ > maxDepth) {
        maxDepth = transformedZ;
        frontFaceNumber = face['number'] as int;
      }
    }

    return frontFaceNumber;
  }

  /// ランダムな回転値を生成（回転アニメーション用）
  /// 
  /// [currentX] 現在のX軸回転値
  /// [currentY] 現在のY軸回転値
  /// [currentZ] 現在のZ軸回転値
  /// [random] Randomインスタンス
  /// 
  /// 戻り値: 新しい回転値のマップ {'x': double, 'y': double, 'z': double}
  static Map<String, double> generateRandomRotation(
    double currentX,
    double currentY,
    double currentZ,
    Random random,
  ) {
    return {
      'x': currentX + 2 * pi + random.nextDouble() * 4 * pi,
      'y': currentY + 2 * pi + random.nextDouble() * 4 * pi,
      'z': currentZ + 2 * pi + random.nextDouble() * 4 * pi,
    };
  }

  /// 指定された面が正面を向くように回転値を計算
  /// 
  /// [targetFaceNumber] 正面を向かせたい面の番号（1-6）
  /// [random] Randomインスタンス（追加のランダム回転用）
  /// 
  /// 戻り値: 回転値のマップ {'x': double, 'y': double, 'z': double}
  /// 
  /// 各面が正面を向くための回転値：
  /// - 面1: (0, 0, 0) - 初期状態
  /// - 面2: (pi/2, 0, 0) - X軸90度回転
  /// - 面3: (0, pi/2, 0) - Y軸90度回転
  /// - 面4: (0, -pi/2, 0) - Y軸-90度回転
  /// - 面5: (-pi/2, 0, 0) - X軸-90度回転
  /// - 面6: (0, pi, 0) - Y軸180度回転
  static Map<String, double> calculateRotationForFace(
    int targetFaceNumber,
    Random random,
  ) {
    // 各面が正面を向くための基本回転値
    final baseRotations = {
      1: {'x': 0.0, 'y': 0.0, 'z': 0.0},
      2: {'x': pi / 2, 'y': 0.0, 'z': 0.0},
      3: {'x': 0.0, 'y': pi / 2, 'z': 0.0},
      4: {'x': 0.0, 'y': -pi / 2, 'z': 0.0},
      5: {'x': -pi / 2, 'y': 0.0, 'z': 0.0},
      6: {'x': 0.0, 'y': pi, 'z': 0.0},
    };

    final base = baseRotations[targetFaceNumber] ?? baseRotations[1]!;
    
    // 追加のランダム回転を加えて、より自然な回転アニメーションにする
    // ただし、最終的には指定された面が正面を向くようにする
    // 2πの倍数を加えても同じ向きになるため、ランダムな回転を追加可能
    final additionalRotations = random.nextDouble() * 2 * pi;
    
    return {
      'x': (base['x'] as double) + additionalRotations,
      'y': (base['y'] as double) + additionalRotations,
      'z': (base['z'] as double) + additionalRotations * 0.5, // Z軸は少し控えめに
    };
  }
}

