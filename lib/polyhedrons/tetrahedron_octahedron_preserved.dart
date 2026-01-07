/// 正四面体と正八面体の実装コード（保存用）
/// 
/// 注意: このファイルは現在使用されていませんが、将来的に使用する可能性があるため保存されています。
/// 正六面体にフォーカスするため、これらのコードは一時的に非アクティブになっています。
/// 
/// 使用方法（将来）:
/// - DiceWidgetに戻す場合は、このファイルのコードをDiceWidgetに統合してください
/// - polyhedronTypeパラメータがtetrahedronまたはoctahedronの場合に使用されます

import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;

/// 正四面体の各面のデータ
/// 正四面体の各頂点を基準に、各面の中心位置と向きを計算
List<Map<String, dynamic>> getTetrahedronFaceData(double halfSize) {
  // 正四面体の辺の長さを決定（表示サイズに合わせて調整）
  // 一辺の長さを a とすると:
  // - 外接球の半径 R = a√6/4
  // - 高さ h = a√6/3
  // - 底面の中心のY座標 = -h/3 = -a√6/9
  // - 底面の正三角形の外接円の半径 = a/√3
  // 正四面体の各面はすべて同じサイズの正三角形
  final a = halfSize * 0.8; // 一辺の長さ（固定値）
  final sqrt6 = math.sqrt(6.0);
  final sqrt3 = math.sqrt(3.0);
  
  // 外接球の半径
  final R = a * sqrt6 / 4.0;
  // 高さ
  final h = a * sqrt6 / 3.0;
  // 底面の中心のY座標
  final bottomCenterY = -h / 3.0;
  // 底面の正三角形の外接円の半径
  final bottomRadius = a / sqrt3;
  
  // 正四面体の4つの頂点座標（標準的な配置）
  // 頂点1: 上（正のY方向）
  final v1 = {'x': 0.0, 'y': R, 'z': 0.0};
  // 頂点2, 3, 4: 底面の正三角形の3頂点（120度ずつ回転）
  // 頂点2: 角度0度
  final v2 = {
    'x': bottomRadius * math.cos(0.0),
    'y': bottomCenterY,
    'z': bottomRadius * math.sin(0.0),
  };
  // 頂点3: 角度120度 = 2π/3
  final v3 = {
    'x': bottomRadius * math.cos(2 * math.pi / 3),
    'y': bottomCenterY,
    'z': bottomRadius * math.sin(2 * math.pi / 3),
  };
  // 頂点4: 角度240度 = 4π/3
  final v4 = {
    'x': bottomRadius * math.cos(4 * math.pi / 3),
    'y': bottomCenterY,
    'z': bottomRadius * math.sin(4 * math.pi / 3),
  };
  
  // 各面の3つの頂点を定義（頂点が共有されるように）
  // 面1: v1-v2-v3
  // 面2: v1-v2-v4
  // 面3: v1-v3-v4
  // 面4: v2-v3-v4
  
  // 各面の中心座標を計算（3頂点の平均）
  final face1Center = {
    'x': (v1['x']! + v2['x']! + v3['x']!) / 3,
    'y': (v1['y']! + v2['y']! + v3['y']!) / 3,
    'z': (v1['z']! + v2['z']! + v3['z']!) / 3,
  };
  final face2Center = {
    'x': (v1['x']! + v2['x']! + v4['x']!) / 3,
    'y': (v1['y']! + v2['y']! + v4['y']!) / 3,
    'z': (v1['z']! + v2['z']! + v4['z']!) / 3,
  };
  final face3Center = {
    'x': (v1['x']! + v3['x']! + v4['x']!) / 3,
    'y': (v1['y']! + v3['y']! + v4['y']!) / 3,
    'z': (v1['z']! + v3['z']! + v4['z']!) / 3,
  };
  final face4Center = {
    'x': (v2['x']! + v3['x']! + v4['x']!) / 3,
    'y': (v2['y']! + v3['y']! + v4['y']!) / 3,
    'z': (v2['z']! + v3['z']! + v4['z']!) / 3,
  };
  
  // 各面の法線ベクトルを計算（外側に向かう方向）
  // 面1: v1-v2-v3（上左）
  final n1 = calculateNormal(v1, v2, v3);
  // 面2: v1-v2-v4（上右）
  final n2 = calculateNormal(v1, v4, v2);
  // 面3: v1-v3-v4（上後方）
  final n3 = calculateNormal(v1, v3, v4);
  // 面4: v2-v3-v4（底面）
  final n4 = calculateNormal(v2, v4, v3);
  
  // 各面のサイズ（正三角形の辺の長さ）を計算
  // 2頂点間の距離を計算
  final distance = (v1['x']! - v2['x']!) * (v1['x']! - v2['x']!) +
                   (v1['y']! - v2['y']!) * (v1['y']! - v2['y']!) +
                   (v1['z']! - v2['z']!) * (v1['z']! - v2['z']!);
  final faceEdgeLength = math.sqrt(distance);
  
  // 正三角形の中心から各頂点までの距離（外接円の半径）
  // 正三角形の外接円の半径 = 辺の長さ / sqrt(3)
  final circumradius = faceEdgeLength / math.sqrt(3.0);
  
  return [
    {
      'number': 1,
      'x': face1Center['x']!,
      'y': face1Center['y']!,
      'z': face1Center['z']!,
      'rot': getRotationMatrix(n1),
      'size': faceEdgeLength,
      'vertices': [v1, v2, v3], // 各面の3つの頂点
      'circumradius': circumradius, // 外接円の半径
    },
    {
      'number': 2,
      'x': face2Center['x']!,
      'y': face2Center['y']!,
      'z': face2Center['z']!,
      'rot': getRotationMatrix(n2),
      'size': faceEdgeLength,
      'vertices': [v1, v2, v4],
      'circumradius': circumradius,
    },
    {
      'number': 3,
      'x': face3Center['x']!,
      'y': face3Center['y']!,
      'z': face3Center['z']!,
      'rot': getRotationMatrix(n3),
      'size': faceEdgeLength,
      'vertices': [v1, v3, v4],
      'circumradius': circumradius,
    },
    {
      'number': 4,
      'x': face4Center['x']!,
      'y': face4Center['y']!,
      'z': face4Center['z']!,
      'rot': getRotationMatrix(n4),
      'size': faceEdgeLength,
      'vertices': [v2, v3, v4],
      'circumradius': circumradius,
    },
  ];
}

/// 正八面体の各面のデータ
/// 正八面体は6つの頂点（±R, 0, 0), (0, ±R, 0), (0, 0, ±R)を持つ
/// 8つの正三角形の面を持つ
List<Map<String, dynamic>> getOctahedronFaceData(double halfSize) {
  // 正八面体の外接球の半径（頂点までの距離）
  final R = halfSize * 0.8;
  
  // 正八面体の6つの頂点座標
  final v1 = {'x': 0.0, 'y': R, 'z': 0.0}; // 上
  final v2 = {'x': 0.0, 'y': -R, 'z': 0.0}; // 下
  final v3 = {'x': R, 'y': 0.0, 'z': 0.0}; // 右
  final v4 = {'x': -R, 'y': 0.0, 'z': 0.0}; // 左
  final v5 = {'x': 0.0, 'y': 0.0, 'z': R}; // 前
  final v6 = {'x': 0.0, 'y': 0.0, 'z': -R}; // 後
  
  // 正八面体の8つの面を定義（各面は3つの頂点からなる正三角形）
  // 面1: 上右前 (v1-v3-v5)
  // 面2: 上前左 (v1-v5-v4)
  // 面3: 上左後 (v1-v4-v6)
  // 面4: 上後右 (v1-v6-v3)
  // 面5: 下前右 (v2-v3-v5) - v2から見て反時計回り
  // 面6: 下左前 (v2-v5-v4) - v2から見て反時計回り
  // 面7: 下後左 (v2-v4-v6) - v2から見て反時計回り
  // 面8: 下右後 (v2-v6-v3) - v2から見て反時計回り
  
  // 各面の中心座標を計算（3頂点の平均）
  final face1Center = {
    'x': (v1['x']! + v3['x']! + v5['x']!) / 3,
    'y': (v1['y']! + v3['y']! + v5['y']!) / 3,
    'z': (v1['z']! + v3['z']! + v5['z']!) / 3,
  };
  final face2Center = {
    'x': (v1['x']! + v5['x']! + v4['x']!) / 3,
    'y': (v1['y']! + v5['y']! + v4['y']!) / 3,
    'z': (v1['z']! + v5['z']! + v4['z']!) / 3,
  };
  final face3Center = {
    'x': (v1['x']! + v4['x']! + v6['x']!) / 3,
    'y': (v1['y']! + v4['y']! + v6['y']!) / 3,
    'z': (v1['z']! + v4['z']! + v6['z']!) / 3,
  };
  final face4Center = {
    'x': (v1['x']! + v6['x']! + v3['x']!) / 3,
    'y': (v1['y']! + v6['y']! + v3['y']!) / 3,
    'z': (v1['z']! + v6['z']! + v3['z']!) / 3,
  };
  final face5Center = {
    'x': (v2['x']! + v3['x']! + v5['x']!) / 3,
    'y': (v2['y']! + v3['y']! + v5['y']!) / 3,
    'z': (v2['z']! + v3['z']! + v5['z']!) / 3,
  };
  final face6Center = {
    'x': (v2['x']! + v5['x']! + v4['x']!) / 3,
    'y': (v2['y']! + v5['y']! + v4['y']!) / 3,
    'z': (v2['z']! + v5['z']! + v4['z']!) / 3,
  };
  final face7Center = {
    'x': (v2['x']! + v4['x']! + v6['x']!) / 3,
    'y': (v2['y']! + v4['y']! + v6['y']!) / 3,
    'z': (v2['z']! + v4['z']! + v6['z']!) / 3,
  };
  final face8Center = {
    'x': (v2['x']! + v6['x']! + v3['x']!) / 3,
    'y': (v2['y']! + v6['y']! + v3['y']!) / 3,
    'z': (v2['z']! + v6['z']! + v3['z']!) / 3,
  };
  
  // 各面の法線ベクトルを計算（外側に向かう方向）
  // 上面（v1を含む面）: v1から見て時計回りに頂点を並べる
  // 下面（v2を含む面）: v2から見て反時計回りに頂点を並べる
  final n1 = calculateNormal(v1, v3, v5); // 上右前
  final n2 = calculateNormal(v1, v5, v4); // 上前左
  final n3 = calculateNormal(v1, v4, v6); // 上左後
  final n4 = calculateNormal(v1, v6, v3); // 上後右
  // 下面の面はv2から見て反時計回りに並べる（法線が外側を向くように）
  final n5 = calculateNormal(v2, v3, v5); // 下前右（修正: v2-v3-v5）
  final n6 = calculateNormal(v2, v5, v4); // 下左前（修正: v2-v5-v4）
  final n7 = calculateNormal(v2, v4, v6); // 下後左（修正: v2-v4-v6）
  final n8 = calculateNormal(v2, v6, v3); // 下右後（修正: v2-v6-v3）
  
  // 各面のサイズ（正三角形の辺の長さ）を計算
  // 正八面体の各辺は同じ長さ（2頂点間の距離）
  final distance = (v1['x']! - v3['x']!) * (v1['x']! - v3['x']!) +
                   (v1['y']! - v3['y']!) * (v1['y']! - v3['y']!) +
                   (v1['z']! - v3['z']!) * (v1['z']! - v3['z']!);
  final faceEdgeLength = math.sqrt(distance);
  
  // 正三角形の中心から各頂点までの距離（外接円の半径）
  final circumradius = faceEdgeLength / math.sqrt(3.0);
  
  return [
    {
      'number': 1,
      'x': face1Center['x']!,
      'y': face1Center['y']!,
      'z': face1Center['z']!,
      'rot': getRotationMatrix(n1),
      'size': faceEdgeLength,
      'vertices': [v1, v3, v5],
      'circumradius': circumradius,
    },
    {
      'number': 2,
      'x': face2Center['x']!,
      'y': face2Center['y']!,
      'z': face2Center['z']!,
      'rot': getRotationMatrix(n2),
      'size': faceEdgeLength,
      'vertices': [v1, v5, v4],
      'circumradius': circumradius,
    },
    {
      'number': 3,
      'x': face3Center['x']!,
      'y': face3Center['y']!,
      'z': face3Center['z']!,
      'rot': getRotationMatrix(n3),
      'size': faceEdgeLength,
      'vertices': [v1, v4, v6],
      'circumradius': circumradius,
    },
    {
      'number': 4,
      'x': face4Center['x']!,
      'y': face4Center['y']!,
      'z': face4Center['z']!,
      'rot': getRotationMatrix(n4),
      'size': faceEdgeLength,
      'vertices': [v1, v6, v3],
      'circumradius': circumradius,
    },
    {
      'number': 5,
      'x': face5Center['x']!,
      'y': face5Center['y']!,
      'z': face5Center['z']!,
      'rot': getRotationMatrix(n5),
      'size': faceEdgeLength,
      'vertices': [v2, v3, v5],
      'circumradius': circumradius,
    },
    {
      'number': 6,
      'x': face6Center['x']!,
      'y': face6Center['y']!,
      'z': face6Center['z']!,
      'rot': getRotationMatrix(n6),
      'size': faceEdgeLength,
      'vertices': [v2, v5, v4],
      'circumradius': circumradius,
    },
    {
      'number': 7,
      'x': face7Center['x']!,
      'y': face7Center['y']!,
      'z': face7Center['z']!,
      'rot': getRotationMatrix(n7),
      'size': faceEdgeLength,
      'vertices': [v2, v4, v6],
      'circumradius': circumradius,
    },
    {
      'number': 8,
      'x': face8Center['x']!,
      'y': face8Center['y']!,
      'z': face8Center['z']!,
      'rot': getRotationMatrix(n8),
      'size': faceEdgeLength,
      'vertices': [v2, v6, v3],
      'circumradius': circumradius,
    },
  ];
}

/// 3頂点から法線ベクトルを計算
Map<String, double> calculateNormal(Map<String, double> v1, Map<String, double> v2, Map<String, double> v3) {
  // 2つの辺ベクトル
  final edge1 = {
    'x': v2['x']! - v1['x']!,
    'y': v2['y']! - v1['y']!,
    'z': v2['z']! - v1['z']!,
  };
  final edge2 = {
    'x': v3['x']! - v1['x']!,
    'y': v3['y']! - v1['y']!,
    'z': v3['z']! - v1['z']!,
  };
  
  // 外積を計算（法線ベクトル）
  final normal = {
    'x': edge1['y']! * edge2['z']! - edge1['z']! * edge2['y']!,
    'y': edge1['z']! * edge2['x']! - edge1['x']! * edge2['z']!,
    'z': edge1['x']! * edge2['y']! - edge1['y']! * edge2['x']!,
  };
  
  // 正規化
  final length = math.sqrt(normal['x']! * normal['x']! + normal['y']! * normal['y']! + normal['z']! * normal['z']!);
  if (length > 0) {
    return {
      'x': normal['x']! / length,
      'y': normal['y']! / length,
      'z': normal['z']! / length,
    };
  }
  return {'x': 0.0, 'y': 1.0, 'z': 0.0};
}

/// 法線ベクトルから回転マトリックスを生成
/// 法線ベクトルがZ軸正方向（0, 0, 1）を向くように回転
vm.Matrix4 getRotationMatrix(Map<String, double> normal) {
  // 簡易実装：法線ベクトルがZ軸正方向を向くように回転
  // より正確な実装には、クォータニオンやオイラー角が必要
  final nz = normal['z']!;
  final ny = normal['y']!;
  final nx = normal['x']!;
  
  // Y軸回転（XZ平面での回転）
  final yAngle = math.atan2(nx, nz);
  // X軸回転（YZ平面での回転）
  final xAngle = -math.asin(ny);
  
  return vm.Matrix4.identity()
    ..rotateY(yAngle)
    ..rotateX(xAngle);
}

