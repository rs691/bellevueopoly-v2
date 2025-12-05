import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String businessId;
  final String? ownerId; // null if unowned
  final int visitCount;
  final DateTime? acquiredAt;
  final DateTime? expiresAt; // for limited ownership

  const Property({
    required this.businessId,
    this.ownerId,
    required this.visitCount,
    this.acquiredAt,
    this.expiresAt,
  });

  bool get isOwned => ownerId != null;

  Property copyWith({
    String? businessId,
    String? ownerId,
    int? visitCount,
    DateTime? acquiredAt,
    DateTime? expiresAt,
  }) {
    return Property(
      businessId: businessId ?? this.businessId,
      ownerId: ownerId ?? this.ownerId,
      visitCount: visitCount ?? this.visitCount,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'ownerId': ownerId,
        'visitCount': visitCount,
        'acquiredAt': acquiredAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      businessId: json['businessId'] as String,
      ownerId: json['ownerId'] as String?,
      visitCount: json['visitCount'] as int,
      acquiredAt: json['acquiredAt'] != null
          ? DateTime.parse(json['acquiredAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [businessId, ownerId, visitCount, acquiredAt, expiresAt];
}
