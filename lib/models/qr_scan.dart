import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QrScan extends Equatable {
  final String id;
  final String playerId;
  final String businessId;
  final String businessName;
  final int pointsEarned;
  final DateTime scannedAt;
  final String? notes;

  const QrScan({
    required this.id,
    required this.playerId,
    required this.businessId,
    required this.businessName,
    required this.pointsEarned,
    required this.scannedAt,
    this.notes,
  });

  factory QrScan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QrScan(
      id: doc.id,
      playerId: data['playerId'] ?? '',
      businessId: data['businessId'] ?? '',
      businessName: data['businessName'] ?? 'Unknown Business',
      pointsEarned: data['pointsEarned'] ?? 0,
      scannedAt: (data['scannedAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'businessId': businessId,
      'businessName': businessName,
      'pointsEarned': pointsEarned,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'notes': notes,
    };
  }

  QrScan copyWith({
    String? id,
    String? playerId,
    String? businessId,
    String? businessName,
    int? pointsEarned,
    DateTime? scannedAt,
    String? notes,
  }) {
    return QrScan(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      scannedAt: scannedAt ?? this.scannedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playerId,
    businessId,
    businessName,
    pointsEarned,
    scannedAt,
    notes,
  ];
}
