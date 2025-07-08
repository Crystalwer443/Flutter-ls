import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BankModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const BankingApp(),
    ),
  );
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      title: 'Banking App',
      themeMode: themeModel.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      ),
      home: const NavigationScreen(),
    );
  }
}

class ThemeModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class BankModel extends ChangeNotifier {
  double _balance = 12450.00;
  final List<Transaction> _history = [
    Transaction(date: DateTime(2025, 4, 20), amount: -100.0, type: 'Olympus Mons Tour'),
    Transaction(date: DateTime(2025, 4, 18), amount: -55.75, type: 'Groceries'),
    Transaction(date: DateTime(2025, 4, 16), amount: 320.0, type: 'Space Tech Store'),
  ];

  double get balance => _balance;
  List<Transaction> get history => _history.reversed.toList();

  void transfer(String recipient, double amount) {
    if (amount <= _balance) {
      _balance -= amount;
      _history.add(Transaction(
        date: DateTime.now(),
        amount: -amount,
        type: 'Transfer to $recipient',
      ));
      notifyListeners();
    }
  }

  void topUp(double amount) {
    _balance += amount;
    _history.add(Transaction(
      date: DateTime.now(),
      amount: amount,
      type: 'Top Up',
    ));
    notifyListeners();
  }
}

class Transaction {
  final DateTime date;
  final double amount;
  final String type;

  Transaction({required this.date, required this.amount, required this.type});
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransferScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
    const CurrencyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Transfer'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Currency'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bank = Provider.of<BankModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning,", style: GoogleFonts.montserrat(fontSize: 22)),
            const SizedBox(height: 4),
            Text("Alex", style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("BALANCE", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text("\$${bank.balance.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _HomeActionButton(icon: Icons.send, label: 'Transfer', color: Colors.blueAccent, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
                      }),
                      _HomeActionButton(icon: Icons.download, label: 'Deposit', color: Colors.green, onTap: () {
                        bank.topUp(100);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Topped up by \$100')),
                        );
                      }),
                      _HomeActionButton(icon: Icons.history, label: 'History', color: Colors.orangeAccent, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text("Recent Transactions", style: GoogleFonts.montserrat(fontSize: 20)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: bank.history.length,
                itemBuilder: (_, index) {
                  final tx = bank.history[index];
                  final color = tx.amount >= 0 ? Colors.green : Colors.red;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.type,
                                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text("${tx.date.month}/${tx.date.day}/${tx.date.year}",
                                  style: const TextStyle(color: Colors.black45)),
                            ],
                          ),
                        ),
                        Text(
                          "${tx.amount > 0 ? '+' : ''}\$${tx.amount.toStringAsFixed(2)}",
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ],
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

class _HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _HomeActionButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final bank = Provider.of<BankModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Funds')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: recipientController, decoration: const InputDecoration(labelText: 'Recipient')),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final recipient = recipientController.text;
                final amount = double.tryParse(amountController.text);
                if (recipient.isNotEmpty && amount != null && amount > 0) {
                  if (bank.balance >= amount) {
                    bank.transfer(recipient, amount);
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Success'),
                        content: Text('Transferred \$${amount.toStringAsFixed(2)} to $recipient'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insufficient funds'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<BankModel>(context).history;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, index) {
                final tx = transactions[index];
                return ListTile(
                  title: Text(tx.type),
                  subtitle: Text(tx.date.toLocal().toString().split(' ')[0]),
                  trailing: Text(
                    '${tx.amount > 0 ? '+' : ''}\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: tx.amount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final isDark = themeModel.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: SwitchListTile(
          title: const Text("Dark Mode"),
          value: isDark,
          onChanged: (value) => themeModel.toggleTheme(value),
        ),
      ),
    );
  }
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _currencies = ['USD', 'EUR', 'KZT', 'GBP', 'JPY'];
  String _from = 'USD';
  String _to = 'EUR';
  double? _convertedAmount;
  Map<String, dynamic> _rates = {};

  Future<void> fetchRates() async {
    final url = Uri.parse('https://api.exchangerate.host/latest?base=$_from');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _rates = data['rates'];
      });
    }
  }

  void convert() {
    final input = double.tryParse(_controller.text);
    if (input != null && _rates.containsKey(_to)) {
      final rate = _rates[_to];
      setState(() {
        _convertedAmount = input * rate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _from,
                    isExpanded: true,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _from = value;
                          fetchRates();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _to,
                    isExpanded: true,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _to = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: convert, child: const Text('Convert')),
            const SizedBox(height: 20),
            if (_convertedAmount != null)
              Text(
                'Result: ${_convertedAmount!.toStringAsFixed(2)} $_to',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
