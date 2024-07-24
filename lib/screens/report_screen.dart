import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/database_helper.dart';
import '../colors.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<PieChartSectionData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _generateChartData();
  }

  void _generateChartData() async {
    final allExpenses = await dbHelper.queryAllExpenses();
    Map<String, double> categoryTotals = {};
    for (var expense in allExpenses) {
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
        title: Text('Expense Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                color: sideBarColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCircularChart(
                    title: ChartTitle(
                      text: 'Expenses by Category',
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    series: <CircularSeries>[
                      PieSeries<PieChartSectionData, String>(
                        dataSource: _chartData,
                        xValueMapper: (PieChartSectionData data, _) => data.title,
                        yValueMapper: (PieChartSectionData data, _) => data.value,
                        dataLabelMapper: (PieChartSectionData data, _) =>
                        '₹${data.value.toStringAsFixed(2)}',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartSectionData {
  final String title;
  final double value;

  PieChartSectionData({required this.title, required this.value});
}
