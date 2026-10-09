class Trip {
  final String? id;
  final DateTime startTime;
  final DateTime endTime;
  final double amount;
  final double commission;
  final String paymentMethod; // 'cash' | 'card'

  Trip({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.commission,
    required this.paymentMethod,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      amount: (json['amount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      paymentMethod: json['payment_method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'amount': amount,
      'commission': commission,
      'payment_method': paymentMethod,
    };
  }
}

class DailySummary {
  final String date;
  final int totalTrips;
  final double revenue;
  final double commission;
  final double netIncome;
  final double cashTotal;
  final double cardTotal;
  final List<Trip> trips;

  DailySummary({
    required this.date,
    required this.totalTrips,
    required this.revenue,
    required this.commission,
    required this.netIncome,
    required this.cashTotal,
    required this.cardTotal,
    required this.trips,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    var breakdown = json['breakdown'] ?? {};
    var tripsList = (json['trips'] as List? ?? [])
        .map((t) => Trip.fromJson(t))
        .toList();

    return DailySummary(
      date: json['date'],
      totalTrips: json['total_trips'],
      revenue: (json['revenue'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      netIncome: (json['net_income'] as num).toDouble(),
      cashTotal: (breakdown['cash'] as num? ?? 0).toDouble(),
      cardTotal: (breakdown['card'] as num? ?? 0).toDouble(),
      trips: tripsList,
    );
  }
}
