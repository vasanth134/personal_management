import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Expense>> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = apiService.getExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expenses = apiService.getExpenses();
    });
  }

  void _addExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: _AddExpenseForm(
          onSubmit: (title, amount, category) async {
            final newExpense = Expense(
              id: '',
              title: title,
              amount: amount,
              category: category,
              date: DateTime.now(),
            );
            await apiService.addExpense(newExpense);
            _refreshExpenses();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1E1E1E),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Expense>>(
        future: _expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses found'));
          }

          final expenses = snapshot.data!;
          final total = expenses.fold(0.0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: PieChart(
                  PieChartData(
                    sections: _getSections(expenses),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.greenAccent,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                await apiService.deleteExpense(expense.id);
                                _refreshExpenses();
                              },
                            ),
                          ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<PieChartSectionData> _getSections(List<Expense> expenses) {
    // Simple logic to group by category for chart (mock logic for now)
    // In a real app, you'd group by category properly
    return expenses.take(5).map((e) {
      return PieChartSectionData(
        color: Colors.primaries[expenses.indexOf(e) % Colors.primaries.length],
        value: e.amount,
        title: '',
        radius: 50,
      );
    }).toList();
  }
}

class _AddExpenseForm extends StatefulWidget {
  final Function(String, double, String) onSubmit;

  const _AddExpenseForm({required this.onSubmit});

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add New Expense',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            final category = _categoryController.text;

            if (title.isNotEmpty && amount > 0 && category.isNotEmpty) {
              widget.onSubmit(title, amount, category);
            }
          },
          child: const Text('Add Expense'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
