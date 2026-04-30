import 'package:flutter/material.dart';

enum InvestmentType { sip, stocks, gold, mutualFunds, crypto, realEstate, others }

class InvestmentModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final InvestmentType type;
  final String notes;

  InvestmentModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index,
      'notes': notes,
    };
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> map) {
    return InvestmentModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      type: InvestmentType.values[map['type']],
      notes: map['notes'] ?? '',
    );
  }

  InvestmentModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    InvestmentType? type,
    String? notes,
  }) {
    return InvestmentModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
}

// Utility for UI
class InvestmentTypeData {
  final InvestmentType type;
  final String name;
  final IconData icon;
  final Color color;

  const InvestmentTypeData(this.type, this.name, this.icon, this.color);
}

const List<InvestmentTypeData> investmentTypes = [
  InvestmentTypeData(InvestmentType.sip, 'SIP', Icons.autorenew_rounded, Color(0xFF6366F1)),
  InvestmentTypeData(InvestmentType.stocks, 'Stocks', Icons.trending_up_rounded, Color(0xFF10B981)),
  InvestmentTypeData(InvestmentType.gold, 'Gold', Icons.workspace_premium_rounded, Color(0xFFEAB308)),
  InvestmentTypeData(InvestmentType.mutualFunds, 'Mutual Funds', Icons.account_balance_wallet_rounded, Color(0xFFEC4899)),
  InvestmentTypeData(InvestmentType.crypto, 'Crypto', Icons.currency_bitcoin_rounded, Color(0xFFF59E0B)),
  InvestmentTypeData(InvestmentType.realEstate, 'Real Estate', Icons.home_work_rounded, Color(0xFF8B5CF6)),
  InvestmentTypeData(InvestmentType.others, 'Others', Icons.more_horiz_rounded, Color(0xFF64748B)),
];
