import 'package:driver_journal_arqa/data/api_service.dart';
import 'package:driver_journal_arqa/data/trip.dart';
import 'package:driver_journal_arqa/feature/add_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  late Future<DailySummary?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _summaryFuture = ApiService.fetchSummary(formattedDate);
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _loadData();
    });
  }

  Future<void> _selectDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadData();
      });
    }
  }

  void _openAddTripDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AddTripPage(
              selectedDate: _selectedDate,
              onTripAdded: () {
                _loadData();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Color(0xFFF1F2F7),
      appBar: AppBar(
        title: const Text('Дневник смен водителя'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTripDialog,
        elevation: 0,
        child: Center(
          child: Icon(Icons.add),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Панель выбора даты и кнопка добавления
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const .all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => _changeDate(-1),
                        ),
                        TextButton.icon(
                          onPressed: _selectDatePicker,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () => _changeDate(1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Основной контент
                Expanded(
                  child: FutureBuilder<DailySummary?>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Ошибка подключения к API: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('Нет данных'));
                      }

                      final summary = snapshot.data!;

                      return ListView(
                        children: [
                          // Сводные карточки
                          LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 600
                                  ? 5
                                  : 2;
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.2,
                                children: [
                                  _SummaryCard(
                                    'Поездок',
                                    '${summary.totalTrips}',
                                    Colors.blue.shade50,
                                    Colors.blue.shade900,
                                  ),
                                  _SummaryCard(
                                    'Выручка',
                                    '${summary.revenue} ₸',
                                    Colors.green.shade50,
                                    Colors.green.shade900,
                                  ),
                                  _SummaryCard(
                                    'Комиссия',
                                    '${summary.commission} ₸',
                                    Colors.red.shade50,
                                    Colors.red.shade900,
                                  ),
                                  _SummaryCard(
                                    'На руки',
                                    '${summary.netIncome} ₸',
                                    Colors.teal.shade100,
                                    Colors.teal.shade900,
                                  ),
                                  _SummaryCard(
                                    'Карта / Нал',
                                    '${summary.cardTotal} / ${summary.cashTotal} ₸',
                                    Colors.purple.shade50,
                                    Colors.purple.shade900,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Таблица / Список поездок
                          const Text(
                            'Список поездок за день',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          summary.trips.isEmpty
                              ? const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        'За выбранный день поездок не найдено',
                                      ),
                                    ),
                                  ),
                                )
                              : Card(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: summary.trips.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final trip = summary.trips[index];
                                      final timeFormat = DateFormat('HH:mm');
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              trip.paymentMethod == 'card'
                                              ? Colors.blue.shade100
                                              : Colors.amber.shade100,
                                          child: Icon(
                                            trip.paymentMethod == 'card'
                                                ? Icons.credit_card
                                                : Icons.payments,
                                            color: trip.paymentMethod == 'card'
                                                ? Colors.blue.shade800
                                                : Colors.amber.shade900,
                                          ),
                                        ),
                                        title: Text(
                                          '${trip.amount} ₸',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Время: ${timeFormat.format(trip.startTime)} - ${timeFormat.format(trip.endTime)} | Комиссия: ${trip.commission} ₸',
                                        ),

                                        trailing: Chip(
                                          label: Text(
                                            trip.paymentMethod == 'card'
                                                ? 'Карта'
                                                : 'Наличные',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final Color textColor;

  const _SummaryCard(this.title, this.value, this.bgColor, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: textColor.withAlpha(150)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
