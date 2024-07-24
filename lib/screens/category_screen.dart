import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _newCategory = '';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _categories = (prefs.getStringList('categories') ?? ['Food', 'Transport', 'Entertainment', 'Others']);
    });
  }

  void _saveCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _categories.add(_newCategory);
    await prefs.setStringList('categories', _categories);
    _newCategory = '';
    _formKey.currentState!.reset();
    _loadCategories();
  }

  void _deleteCategory(String category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _categories.remove(category);
    await prefs.setStringList('categories', _categories);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navBarColor,
        title: Text('Manage Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'New Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newCategory = value!;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navBarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveCategory();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(_categories[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: expenseColor),
                        onPressed: () => _deleteCategory(_categories[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
