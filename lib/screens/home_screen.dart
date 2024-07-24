import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/database_helper.dart';
import 'add_entry_screen.dart';
import '../colors.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> expenses = [];
  double _budget = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;
  String currentMonth = DateFormat('MMMM').format(DateTime.now());
  List<PieChartSectionData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _loadBudget();
    _generateChartData();
  }

  void _fetchExpenses() async {
    final allRows = await dbHelper.queryAllExpenses();
    double total = 0.0;
    for (var expense in allRows) {
      total += expense['amount'];
    }
    setState(() {
      expenses = allRows;
      _totalExpenses = total;
      _generateChartData();
    });
  }

  void _loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _budget = (prefs.getDouble('budget_$currentMonth') ?? 0.0);
    });
  }

  void _filterExpensesByDate(DateTime date) {
    final filteredExpenses = expenses.where((expense) {
      return DateTime.parse(expense['date']).month == date.month &&
          DateTime.parse(expense['date']).year == date.year;
    }).toList();

    setState(() {
      expenses = filteredExpenses;
      _totalExpenses = filteredExpenses.fold(0.0, (sum, item) => sum + item['amount']);
      _generateChartData();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterExpensesByDate(picked);
      });
    }
  }

  void _generateChartData() {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals.update(
        expense['category'],
        (value) => value + expense['amount'],
        ifAbsent: () => expense['amount'],
      );
    }
    List<PieChartSectionData> chartData = [];
    categoryTotals.forEach((category, amount) {
      chartData.add(PieChartSectionData(
        title: category,
        value: amount,
      ));
    });
    setState(() {
      _chartData = chartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navBarColor,
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/report');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/budget').then((_) => _loadBudget());
            },
          ),
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: sideBarColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Current Month: $currentMonth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Total Budget: ₹$_budget', style: TextStyle(fontSize: 18, color: Colors.white)),
                      Text('Total Expenses: ₹$_totalExpenses', style: TextStyle(fontSize: 18, color: Colors.white)),
                      Text('Remaining: ₹${_budget - _totalExpenses}', style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _totalExpenses / (_budget == 0 ? 1 : _budget),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 20),
                      SfCircularChart(
                        title: ChartTitle(text: 'Expenses by Category', textStyle: TextStyle(color: Colors.white)),
                        legend: Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                        series: <CircularSeries>[
                          PieSeries<PieChartSectionData, String>(
                            dataSource: _chartData,
                            xValueMapper: (PieChartSectionData data, _) => data.title,
                            yValueMapper: (PieChartSectionData data, _) => data.value,
                            dataLabelMapper: (PieChartSectionData data, _) => '₹${data.value.toStringAsFixed(2)}',
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Dismissible(
                          key: Key(expense['id'].toString()),
                          onDismissed: (direction) {
                            _deleteExpense(expense['id']);
                          },
                          background: Container(color: expenseColor),
                          child: ListTile(
                            leading: Icon(Icons.money_off),
                            title: Text('${expense['category']} - ₹${expense['amount']}'),
                            subtitle: Text(expense['description']),
                            trailing: Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(expense['date']))),
                            onTap: () => _editExpense(context, expense),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: incomeColor,
        onPressed: () {
          Navigator.pushNamed(context, '/add').then((value) => _fetchExpenses());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteExpense(int id) async {
    await dbHelper.deleteExpense(id);
    _fetchExpenses();
  }

  void _editExpense(BuildContext context, Map<String, dynamic> expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(expense: expense),
      ),
    ).then((value) => _fetchExpenses());
  }
}

class PieChartSectionData {
  final String title;
  final double value;

  PieChartSectionData({required this.title, required this.value});
}
