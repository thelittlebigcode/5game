/// Orientación de gravedad lateral en Gravity Courier.
enum WallSide {
  left,
  right;

  WallSide get opposite =>
      this == WallSide.left ? WallSide.right : WallSide.left;

  /// Posición X de contacto contra la pared respectiva (área de juego de 450 de ancho).
  /// Pared izquierda en X=30, pared derecha en X=420.
  double get wallX => this == WallSide.left ? 30.0 : 420.0;

  /// Dirección de la fuerza gravitatoria horizontal: +1 hacia la derecha, -1 hacia la izquierda.
  double get gravityDirection => this == WallSide.right ? 1.0 : -1.0;
}
