import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _budget = 0.0;
  String _selectedMonth = 'January';
  List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  Map<String, double> _monthlyBudgets = {};

  @override
  void initState() {
    super.initState();
    _loadAllBudgets();
  }

  void _loadAllBudgets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> budgets = {};
    for (String month in _months) {
      budgets[month] = prefs.getDouble('budget_$month') ?? 0.0;
    }
    setState(() {
      _monthlyBudgets = budgets;
      _budget = _monthlyBudgets[_selectedMonth]!;
    });
  }

  void _saveBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_$_selectedMonth', _budget);
    _loadAllBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navBarColor,
        title: Text('Set Monthly Budget'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  color: sideBarColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'Select Month',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: sideBarColor,
                          iconEnabledColor: Colors.white,
                          items: _months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month, style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMonth = newValue!;
                              _budget = _monthlyBudgets[_selectedMonth]!;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          initialValue: _budget.toString(),
                          decoration: InputDecoration(
                            labelText: 'Monthly Budget',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee, color: Colors.white),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a budget amount';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _budget = double.tryParse(value!)!;
                          },
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navBarColor, // Change primary to backgroundColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _saveBudget();
                              _showSuccessModal('Budget set successfully for $_selectedMonth');
                            }
                          },
                          child: Text('Save Budget'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: sideBarColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Monthly Budgets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _months.length,
                          itemBuilder: (context, index) {
                            String month = _months[index];
                            double budget = _monthlyBudgets[month]!;
                            return ListTile(
                              title: Text(
                                month,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                '₹${budget.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }

  void _showSuccessModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                Navigator.pop(context, true); // Close the BudgetScreen and return to previous screen
              },
            ),
          ],
        );
      },
    );
  }
}
