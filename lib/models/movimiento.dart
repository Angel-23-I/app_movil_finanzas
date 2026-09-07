enum TipoMovimiento { ingreso, egreso }

class Movimiento {
  final String id;
  final String descripcion;
  final String categoria;
  final double monto;
  final DateTime fecha;
  final TipoMovimiento tipo;

  Movimiento({
    required this.id,
    required this.descripcion,
    required this.categoria,
    required this.monto,
    required this.fecha,
    required this.tipo,
  });

  static const categoriasEgreso = [
    'alimentación',
    'transporte',
    'entretenimiento',
    'salud',
    'educación',
    'otro',
  ];

  String get monthKey => '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

  static String monthKeyFrom(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'categoria': categoria,
        'monto': monto,
        'fecha': fecha.toIso8601String(),
        'tipo': tipo.name,
      };

  factory Movimiento.fromJson(Map<String, dynamic> json) => Movimiento(
        id: json['id'] as String,
        descripcion: json['descripcion'] as String,
        categoria: json['categoria'] as String,
        monto: (json['monto'] as num).toDouble(),
        fecha: DateTime.parse(json['fecha'] as String),
        tipo: (json['tipo'] as String) == 'ingreso'
            ? TipoMovimiento.ingreso
            : TipoMovimiento.egreso,
      );

  Movimiento copyWith({
    String? descripcion,
    String? categoria,
    double? monto,
    DateTime? fecha,
  }) =>
      Movimiento(
        id: id,
        descripcion: descripcion ?? this.descripcion,
        categoria: categoria ?? this.categoria,
        monto: monto ?? this.monto,
        fecha: fecha ?? this.fecha,
        tipo: tipo,
      );
}
