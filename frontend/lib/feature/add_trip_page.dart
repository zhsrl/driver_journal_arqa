import 'package:driver_journal_arqa/data/api_service.dart';
import 'package:driver_journal_arqa/data/trip.dart';
import 'package:flutter/material.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({
    super.key,
    required this.selectedDate,
    required this.onTripAdded,
  });

  final DateTime selectedDate;
  final VoidCallback onTripAdded;

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  static const double _defaultCommissionPercent = 12.0;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commissionPercentController = TextEditingController(
    text: '$_defaultCommissionPercent',
  );
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 30);
  double _amount = 0.0;
  double _commission = 0.0;
  String _paymentMethod = 'card';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_recalculateCommission);
    _commissionPercentController.addListener(_recalculateCommission);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commissionPercentController.dispose();
    super.dispose();
  }

  void _recalculateCommission() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final percent = double.tryParse(_commissionPercentController.text) ?? 0.0;
    setState(() {
      _commission = amount * percent / 100;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (!endDateTime.isAfter(startDateTime)) {
      setState(() {
        _errorMessage =
            'Ошибка: Время окончания должно быть позже времени начала!';
      });
      return;
    }

    final trip = Trip(
      startTime: startDateTime,
      endTime: endDateTime,
      amount: _amount,
      commission: _commission,
      paymentMethod: _paymentMethod,
    );

    try {
      final res = await ApiService.addTrip(trip);
      if (res['status'] == 'duplicate') {
        setState(() {
          _errorMessage =
              'Предупреждение: Дубликат! Данная поездка уже есть в системе.';
        });
      } else {
        widget.onTripAdded();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сервера: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Добавление поездки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Время начала'),
                  subtitle: Text(_startTime.format(context)),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (t != null) setState(() => _startTime = t);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Время окончания'),
                  subtitle: Text(_endTime.format(context)),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (t != null) setState(() => _endTime = t);
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Сумма поездки (₸)'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null ||
                  double.tryParse(v) == null ||
                  double.parse(v) <= 0) {
                return 'Сумма должна быть > 0';
              }
              return null;
            },
            onSaved: (v) => _amount = double.parse(v!),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _commissionPercentController,
            decoration: const InputDecoration(
              labelText: 'Комиссия (%)',
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null ||
                  double.tryParse(v) == null ||
                  double.parse(v) < 0) {
                return 'Комиссия не может быть отрицательной';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Комиссия составит: ${_commission.toStringAsFixed(2)} ₸',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Способ оплаты'),
            items: const [
              DropdownMenuItem(
                value: 'card',
                child: Text('Карта (безналичные)'),
              ),
              DropdownMenuItem(value: 'cash', child: Text('Наличные')),
            ],
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Сохранить поездку'),
          ),
        ],
      ),
    );
  }
}
