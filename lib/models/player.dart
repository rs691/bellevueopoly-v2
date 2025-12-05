import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final int balance;
  final List<String> ownedPropertyIds;
  final int totalVisits;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    required this.balance,
    required this.ownedPropertyIds,
    required this.totalVisits,
    required this.createdAt,
  });

  Player copyWith({
    String? id,
    String? name,
    int? balance,
    List<String>? ownedPropertyIds,
    int? totalVisits,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      ownedPropertyIds: ownedPropertyIds ?? this.ownedPropertyIds,
      totalVisits: totalVisits ?? this.totalVisits,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balance': balance,
    'ownedPropertyIds': ownedPropertyIds,
    'totalVisits': totalVisits,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
      ownedPropertyIds: List<String>.from(json['ownedPropertyIds'] as List),
      totalVisits: json['totalVisits'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    balance,
    ownedPropertyIds,
    totalVisits,
    createdAt,
  ];
}
