import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/database_helper.dart';
import '../colors.dart';
import '../utils/notification_helper.dart'; 

class AddEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;

  AddEntryScreen({this.expense});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  String _description = '';
  List<String> _categories = [];

  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.expense != null) {
      _category = widget.expense!['category'];
      _amount = widget.expense!['amount'];
      _date = DateTime.parse(widget.expense!['date']);
      _description = widget.expense!['description'];
    }
  }

  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _categories = (prefs.getStringList('categories') ?? ['Food', 'Transport', 'Entertainment', 'Others']);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.expense == null) {
        dbHelper.insertExpense({
          'category': _category,
          'amount': _amount,
          'date': _date.toIso8601String(),
          'description': _description,
        });
      } else {
        dbHelper.updateExpense({
          'id': widget.expense!['id'],
          'category': _category,
          'amount': _amount,
          'date': _date.toIso8601String(),
          'description': _description,
        });
      }
      scheduleNotification('Expense Tracker', 'New expense added!', DateTime.now().add(Duration(seconds: 5)));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navBarColor,
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _category.isNotEmpty ? _category : null,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                initialValue: _amount != 0.0 ? _amount.toString() : '',
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: DateFormat('dd-MM-yyyy').format(_date),
                ),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveEntry,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
