import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const TuyapApp());
}

/// DATA_MODEL
/// This class holds all the data displayed in the UI and extends ChangeNotifier
/// to allow for state updates that trigger UI rebuilds using Provider.
class TuyapData extends ChangeNotifier {
  double totalIncome;
  double todayIncome;
  double weeklyIncome;
  int workedDays;
  int totalWorkDays;
  int remainingDays;
  String lastAdditionTime;

  TuyapData({
    this.totalIncome = 125000.0,
    this.todayIncome = 750.0,
    this.weeklyIncome = 3200.0,
    this.workedDays = 22,
    this.totalWorkDays = 30,
    this.remainingDays = 8,
    String? initialLastAdditionTime,
  }) : lastAdditionTime = initialLastAdditionTime ?? DateFormat('HH:mm').format(DateTime.now());

  void addIncome(double amount) {
    totalIncome += amount;
    todayIncome += amount;
    weeklyIncome += amount;
    lastAdditionTime = DateFormat('HH:mm').format(DateTime.now());
    notifyListeners();
  }

  void removeIncome(double amount) {
    totalIncome = (totalIncome - amount).clamp(0.0, double.infinity);
    todayIncome = (todayIncome - amount).clamp(0.0, double.infinity);
    weeklyIncome = (weeklyIncome - amount).clamp(0.0, double.infinity);
    lastAdditionTime = DateFormat('HH:mm').format(DateTime.now());
    notifyListeners();
  }
}

class TuyapApp extends StatelessWidget {
  const TuyapApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ChangeNotifierProvider<TuyapData>(
      create: (BuildContext context) => TuyapData(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Tuyap Gelir Takip',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            fontFamily: 'SF Pro Display',
          ),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late String _currentDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentDate = DateFormat('d MMMM EEEE', 'tr_TR').format(DateTime.now());
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TuyapData tuyapData = context.watch<TuyapData>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        HeaderWidget(
                          currentDate: _currentDate,
                          lastAdditionTime: tuyapData.lastAdditionTime,
                        ),
                        const SizedBox(height: 10),
                        TotalIncomeCard(totalIncome: tuyapData.totalIncome),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TodayIncomeCard(
                                todayIncome: tuyapData.todayIncome,
                                totalIncome: tuyapData.totalIncome,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: WorkDaysCard(
                                workedDays: tuyapData.workedDays,
                                totalWorkDays: tuyapData.totalWorkDays,
                                remainingDays: tuyapData.remainingDays,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        WeeklySummaryCard(
                          totalIncome: tuyapData.totalIncome,
                          weeklyIncome: tuyapData.weeklyIncome,
                        ),
                        const SizedBox(height: 100), // Space for floating action buttons
                      ],
                    ),
                  ),
                ],
              ),
              const ModernBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern Header Widget with better typography and spacing
class HeaderWidget extends StatelessWidget {
  final String currentDate;
  final String lastAdditionTime;
  
  const HeaderWidget({
    super.key,
    required this.currentDate,
    required this.lastAdditionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Merhaba! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tuyap Kazanç Takip',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF475569),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  currentDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  'Son: $lastAdditionTime',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero Total Income Card with premium design
class TotalIncomeCard extends StatelessWidget {
  final double totalIncome;
  
  const TotalIncomeCard({super.key, required this.totalIncome});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Kazancınız',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₺${NumberFormat('#,##0', 'tr_TR').format(totalIncome)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '↗ %12.5 bu ay',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Today Income Card
class TodayIncomeCard extends StatelessWidget {
  final double todayIncome;
  final double totalIncome;
  
  const TodayIncomeCard({
    super.key,
    required this.todayIncome,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.today_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bugün',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₺${NumberFormat('#,##0', 'tr_TR').format(todayIncome)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '%${((todayIncome / totalIncome) * 100).toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Work Days Card
class WorkDaysCard extends StatelessWidget {
  final int workedDays;
  final int totalWorkDays;
  final int remainingDays;
  
  const WorkDaysCard({
    super.key,
    required this.workedDays,
    required this.totalWorkDays,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    final progress = workedDays / totalWorkDays;
    
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Çalışma',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$workedDays/$totalWorkDays',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced Weekly Summary Card
class WeeklySummaryCard extends StatelessWidget {
  final double totalIncome;
  final double weeklyIncome;
  
  const WeeklySummaryCard({
    super.key,
    required this.totalIncome,
    required this.weeklyIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haftalık Özet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bu Hafta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Mesai Ücreti',
            totalIncome,
            const Color(0xFF3B82F6),
            Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Kazanılan Ücret',
            weeklyIncome,
            const Color(0xFF10B981),
            Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₺${NumberFormat('#,##0', 'tr_TR').format(amount)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern Floating Action Button Navigation
class ModernBottomNavBar extends StatelessWidget {
  const ModernBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final TuyapData tuyapData = context.read<TuyapData>();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavButton(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Ana Sayfa',
              isActive: true,
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.remove,
              label: 'Çıkar',
              color: const Color(0xFFEF4444),
              onTap: () {
                HapticFeedback.lightImpact();
                _showAddRemoveDialog(context, false, tuyapData);
              },
            ),
            _buildActionButton(
              icon: Icons.add,
              label: 'Ekle',
              color: const Color(0xFF10B981),
              onTap: () {
                HapticFeedback.lightImpact();
                _showAddRemoveDialog(context, true, tuyapData);
              },
            ),
            _buildActionButton(
              icon: Icons.timer,
              label: 'Hızlı Ekle',
              color: const Color(0xFF3B82F6),
              onTap: () {
                HapticFeedback.lightImpact();
                _showQuickAddDialog(context, tuyapData);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRemoveDialog(BuildContext context, bool isAdd, TuyapData tuyapData) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAdd ? 'Gelir Ekle' : 'Gider Çıkar',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tutar',
                  prefixText: '₺',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(controller.text) ?? 0.0;
                        if (amount > 0) {
                          if (isAdd) {
                            tuyapData.addIncome(amount);
                          } else {
                            tuyapData.removeIncome(amount);
                          }
                          Navigator.pop(context);
                          _showSuccessSnackBar(context, isAdd);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdd ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(isAdd ? 'Ekle' : 'Çıkar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
void _showQuickAddDialog(BuildContext context, TuyapData tuyapData) {
  final Map<String, double> options = {
    'Hafta İçi 22:00': 500.0,
    'Hafta İçi 24:00': 600.0,
    'Hafta Sonu 18:00': 400.0,
    'Hafta Sonu 22:00': 550.0,
  };

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.2),
                      const Color(0xFFFFA500).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '💰',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Hızlı Gelir Ekle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Options grid
          ...options.entries.map((entry) {
            final isWeekend = entry.key.contains('Hafta Sonu');
            final isEarlyShift = entry.key.contains('18:00');
            final isLateShift = entry.key.contains('24:00');
            
            // Anlam bazlı renkler ve simgeler
            String emoji;
            List<Color> gradientColors;
            
            if (isWeekend) {
              if (isEarlyShift) {
                emoji = '1'; // Hafta sonu erken 
                gradientColors = [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)]; // Kırmızı tonları
              } else {
                emoji = '2'; // Hafta sonu gece 
                gradientColors = [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]; // Turkuaz tonları
              }
            } else {
              if (isLateShift) {
                emoji = '4'; // Hafta içi gece 
                gradientColors = [const Color(0xFF667EEA), const Color(0xFF764BA2)]; // Mor-mavi tonları
              } else {
                emoji = '3'; // Hafta içi akşam 
                gradientColors = [const Color(0xFFF093FB), const Color(0xF8B500)]; // Pembe-sarı tonları
              }
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    tuyapData.addIncome(entry.value);
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, true);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₺${entry.value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
          
          // Cancel button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '✕',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'İptal',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
  void _showSuccessSnackBar(BuildContext context, bool isAdd) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAdd ? 'Gelir başarıyla eklendi!' : 'Gider başarıyla çıkarıldı!'),
        backgroundColor: isAdd ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
