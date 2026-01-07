import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final int balance;
  final List<String> ownedPropertyIds;
  final int totalVisits;
  final int totalPoints;  // Total points from all scans
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    required this.balance,
    required this.ownedPropertyIds,
    required this.totalVisits,
    required this.totalPoints,
    required this.createdAt,
  });

  Player copyWith({
    String? id,
    String? name,
    int? balance,
    List<String>? ownedPropertyIds,
    int? totalVisits,
    int? totalPoints,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      ownedPropertyIds: ownedPropertyIds ?? this.ownedPropertyIds,
      totalVisits: totalVisits ?? this.totalVisits,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balance': balance,
    'ownedPropertyIds': ownedPropertyIds,
    'totalVisits': totalVisits,
    'total_points': totalPoints,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Player',
      balance: json['balance'] is int ? json['balance'] : 0,
      ownedPropertyIds: json['ownedPropertyIds'] is List
          ? List<String>.from(json['ownedPropertyIds'])
          : [],
      totalVisits: json['totalVisits'] is int ? json['totalVisits'] : 0,
      totalPoints: json['total_points'] is int ? json['total_points'] : 0,
      createdAt: json['createdAt'] is String 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : (json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.now()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    balance,
    ownedPropertyIds,
    totalVisits,
    totalPoints,
    createdAt,
  ];
}
