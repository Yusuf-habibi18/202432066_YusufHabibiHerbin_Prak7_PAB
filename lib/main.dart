import 'package:flutter/material.dart';

void main() {
  runApp(const DompetkuApp());
}

/// ============================================================
/// APP ROOT
/// ============================================================
class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0F766E); // deep teal/emerald

    return MaterialApp(
      title: 'Dompetku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        tabBarTheme: TabBarThemeData(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.18),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: seed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: seed, width: 1.6),
          ),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

/// ============================================================
/// DATA MODEL
/// ============================================================
class Category {
  const Category(this.name, this.imagePath, this.icon, this.color);
  final String name;
  final String imagePath;
  final IconData icon;
  final Color color;
}

// TUGAS 1: kategori "Kesehatan" ditambahkan, masing-masing kini punya
// warna & ikon khas sendiri supaya tampilannya lebih hidup.
const categories = [
  Category('Makanan', 'assets/images/makanan.png', Icons.restaurant, Color(0xFFFF7043)),
  Category('Transportasi', 'assets/images/transportasi.png', Icons.directions_bus, Color(0xFF42A5F5)),
  Category('Belanja', 'assets/images/belanja.png', Icons.shopping_bag, Color(0xFFAB47BC)),
  Category('Hiburan', 'assets/images/hiburan.png', Icons.movie, Color(0xFFEC407A)),
  Category('Kesehatan', 'assets/images/kesehatan.png', Icons.favorite, Color(0xFF26A69A)),
];

class Expense {
  Expense(this.title, this.amount, this.category);
  final String title;
  final double amount;
  final Category category;
}

String formatRupiah(double value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromRight = s.length - i;
    buf.write(s[i]);
    if (posFromRight > 1 && posFromRight % 3 == 1) buf.write('.');
  }
  return 'Rp $buf';
}

/// Mengubah input seperti "40.000" atau "40,000" menjadi 40000.
double? parseRupiah(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return double.tryParse(digits);
}

/// ============================================================
/// DASHBOARD (4 tab: Transaksi, Kategori, Statistik, Profil)
/// ============================================================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Expense> _expenses = [
    Expense('Makan Siang', 25000, categories[0]),
    Expense('Ojek ke Kampus', 15000, categories[1]),
    Expense('Beli Buku', 85000, categories[2]),
    Expense('Nonton Bioskop', 50000, categories[3]),
    Expense('Kopi Susu', 18000, categories[0]),
    Expense('Beli Obat & Vitamin', 120000, categories[4]), // Kesehatan, sekaligus terbesar
  ];

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  Future<void> _openForm() async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result != null) {
      setState(() => _expenses.add(result));
    }
  }

  void _deleteExpense(Expense e) {
    final index = _expenses.indexOf(e);
    if (index < 0) return;
    setState(() => _expenses.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${e.title}" dihapus'),
        action: SnackBarAction(
          label: 'Batal',
          onPressed: () => setState(() => _expenses.insert(index, e)),
        ),
      ));
  }

  Future<void> _resetExpenses() async {
    if (_expenses.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Transaksi'),
        content: const Text('Semua transaksi akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _expenses.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 4, // TUGAS 2
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [seed, seed.withOpacity(0.75)],
              ),
            ),
          ),
          title: const Text('Dompetku', style: TextStyle(fontWeight: FontWeight.w800)),
          toolbarHeight: 64,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Transaksi'),
                  Tab(icon: Icon(Icons.grid_view_rounded, size: 20), text: 'Kategori'),
                  Tab(icon: Icon(Icons.insights_rounded, size: 20), text: 'Statistik'),
                  Tab(icon: Icon(Icons.person_rounded, size: 20), text: 'Profil'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(children: [
          TransaksiTab(
            expenses: _expenses,
            total: _total,
            onDelete: _deleteExpense,
            onReset: _resetExpenses,
          ),
          KategoriTab(expenses: _expenses),
          StatistikTab(expenses: _expenses),
          ProfilTab(jumlahTransaksi: _expenses.length),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openForm,
          icon: const Icon(Icons.add),
          label: const Text('Catat'),
        ),
      ),
    );
  }
}

/// ============================================================
/// TAB 1 — TRANSAKSI
/// ============================================================
class TransaksiTab extends StatelessWidget {
  const TransaksiTab({
    super.key,
    required this.expenses,
    required this.total,
    required this.onDelete,
    required this.onReset,
  });
  final List<Expense> expenses;
  final double total;
  final ValueChanged<Expense> onDelete;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Hero balance card (total pengeluaran)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [seed, seed.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(color: seed.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text('Total Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                formatRupiah(total),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('${expenses.length} transaksi tercatat',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Riwayat Transaksi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              TextButton.icon(
                onPressed: expenses.isEmpty ? null : onReset,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Daftar transaksi pakai ListView.builder (transaksi terbaru di atas)
        Expanded(
          child: expenses.isEmpty
              ? Center(
                  child: Text('Belum ada transaksi',
                      style: TextStyle(color: Colors.grey[600])),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[expenses.length - 1 - index];
                    // Geser kartu ke kiri untuk menghapus
                    return Dismissible(
                      key: ObjectKey(e),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => onDelete(e),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      child: TransactionCard(expense: e, onDelete: () => onDelete(e)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// CUSTOM WIDGET: kartu satu transaksi
class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.expense, this.onDelete});
  final Expense expense;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: expense.category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(expense.category.icon, color: expense.category.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(expense.category.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('-${formatRupiah(expense.amount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFFD32F2F))),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.grey[500]),
              tooltip: 'Hapus',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// ============================================================
/// TAB 2 — KATEGORI (TUGAS 3: GridView.builder 2 kolom)
/// ============================================================
class KategoriTab extends StatelessWidget {
  const KategoriTab({super.key, required this.expenses});
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        final items = expenses.where((e) => e.category == c).toList();
        final subtotal = items.fold<double>(0, (sum, e) => sum + e.amount);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.color.withOpacity(0.95), c.color.withOpacity(0.65)],
            ),
            boxShadow: [
              BoxShadow(color: c.color.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar kategori mengisi seluruh ruang kosong di atas teks
              Expanded(
                child: Center(
                  child: Image.asset(
                    c.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(c.icon, color: Colors.white, size: 72),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('${items.length} transaksi',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(formatRupiah(subtotal),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================================================
/// TAB 3 — STATISTIK (TUGAS 2)
/// ============================================================
class StatistikTab extends StatelessWidget {
  const StatistikTab({super.key, required this.expenses});
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Belum ada transaksi'));
    }

    final terbesar = expenses.reduce((a, b) => a.amount > b.amount ? a : b);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    // total per kategori, diurutkan dari terbesar, untuk mini bar chart
    final perKategori = categories.map((c) {
      final sum = expenses.where((e) => e.category == c).fold<double>(0, (s, e) => s + e.amount);
      return (c, sum);
    }).where((p) => p.$2 > 0).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    final maxValue = perKategori.isEmpty ? 1.0 : perKategori.first.$2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      children: [
        // Spotlight: transaksi terbesar
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 36, color: Colors.amber),
              ),
              const SizedBox(height: 12),
              const Text('Transaksi Terbesar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  terbesar.category.imagePath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(terbesar.category.icon, size: 64, color: terbesar.category.color),
                ),
              ),
              const SizedBox(height: 12),
              Text(terbesar.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(terbesar.category.name, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
              Text(
                formatRupiah(terbesar.amount),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pengeluaran per Kategori', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        // Mini bar chart manual pakai Container (tanpa dependency tambahan)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: perKategori.map((p) {
              final c = p.$1;
              final value = p.$2;
              final persen = total == 0 ? 0 : (value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(c.icon, size: 16, color: c.color),
                        const SizedBox(width: 6),
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const Spacer(),
                        Text('$persen%  ·  ${formatRupiah(value)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value / maxValue,
                        minHeight: 8,
                        backgroundColor: c.color.withOpacity(0.12),
                        color: c.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// TAB 4 — PROFIL
/// ============================================================
class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key, required this.jumlahTransaksi});
  final int jumlahTransaksi;

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 190,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: seed.withOpacity(0.15),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [seed, seed.withOpacity(0.6)]),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -45,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        const Text('Yusuf Habibi Herbin',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        Text('202432066 · Pemrograman Aplikasi Bergerak',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfilStat(
                    icon: Icons.receipt_long,
                    label: 'Transaksi',
                    value: '$jumlahTransaksi'),
                const _VDivider(),
                _ProfilStat(
                    icon: Icons.category_rounded,
                    label: 'Kategori',
                    value: '${categories.length}'),
                const _ProfilStat(
                    icon: Icons.verified_user_rounded,
                    label: 'Status',
                    value: 'Aktif'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ProfilStat extends StatelessWidget {
  const _ProfilStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: seed, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: Colors.grey[200]);
}

/// ============================================================
/// FORM TAMBAH TRANSAKSI
/// ============================================================
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  Category _selectedCategory = categories.first;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        _titleController.text.trim(),
        parseRupiah(_amountController.text)!,
        _selectedCategory,
      );
      Navigator.pop(context, expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        title: const Text('Catat Transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((c) {
                final selected = c == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? c.color : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? c.color : Colors.grey[300]!),
                      boxShadow: selected
                          ? [BoxShadow(color: c.color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 18, color: selected ? Colors.white : c.color),
                        const SizedBox(width: 6),
                        Text(c.name,
                            style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Nama Transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Contoh: Makan Siang'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama transaksi wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            const Text('Nominal', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Contoh: 25000', prefixText: 'Rp '),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                final n = parseRupiah(v);
                if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Simpan Transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}