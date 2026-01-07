/// 正多面体のタイプ
enum PolyhedronType {
  tetrahedron(4, '正四面体'),
  cube(6, '正六面体（立方体）'),
  octahedron(8, '正八面体');

  const PolyhedronType(this.faceCount, this.displayName);

  /// 面の数
  final int faceCount;

  /// 表示名
  final String displayName;
}
