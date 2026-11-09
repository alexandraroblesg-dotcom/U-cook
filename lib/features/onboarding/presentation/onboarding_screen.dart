import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/preferences_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  final TextEditingController _nameController = TextEditingController(text: 'Alejandro');
  String _selectedDiners = 'Solo para mí';

  // Step 2
  final List<String> _availableGoals = [
    'Comer más variado',
    'Gastar menos dinero',
    'Organizar mejor mi semana',
    'Desperdiciar menos comida',
    'Ahorrar tiempo',
  ];
  final Set<String> _selectedGoals = {'Ahorrar tiempo', 'Gastar menos dinero'};

  // Step 3
  String _frequency = 'Semanal';
  final TextEditingController _budgetController = TextEditingController(text: '200000');

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final budget = CurrencyFormatter.parseCOP(_budgetController.text);
    await ref.read(preferencesNotifierProvider.notifier).savePreferences(
          name: _nameController.text.trim().isEmpty ? 'Estudiante' : _nameController.text.trim(),
          diners: _selectedDiners,
          goals: _selectedGoals.toList(),
          groceryFrequency: _frequency,
          budgetCop: budget <= 0 ? 200000 : budget,
        );
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with step indicator & Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.green : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      'Omitir',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            // Bottom action button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.night,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == 2 ? 'Comenzar con U-Cook' : 'Siguiente',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    final dinersOptions = [
      {'title': 'Solo para mí', 'subtitle': '1 persona', 'icon': Icons.person_outline},
      {'title': 'Para 2 personas', 'subtitle': 'Con roomie o pareja', 'icon': Icons.people_outline},
      {'title': 'Para 3 o más', 'subtitle': 'Apartamento compartido', 'icon': Icons.group_outlined},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '¡Empecemos por ti!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.night,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Queremos conocerte un poco para adaptar U-Cook a tu rutina de clases y presupuesto.',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          const Text(
            '¿Cómo te llamas?',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.night),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '¿Para cuántas personas cocinas normalmente?',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.night),
          ),
          const SizedBox(height: 12),
          ...dinersOptions.map((opt) {
            final isSelected = _selectedDiners == opt['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _selectedDiners = opt['title'] as String),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.green.withValues(alpha: 0.08) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.green : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(opt['icon'] as IconData, color: isSelected ? AppColors.green : AppColors.muted),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.green : AppColors.night,
                              ),
                            ),
                            Text(
                              opt['subtitle'] as String,
                              style: const TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.green),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '¿Qué quieres mejorar?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.night,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige lo que más te gustaría lograr con U-Cook. (Selección opcional).',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          ..._availableGoals.map((goal) {
            final isChecked = _selectedGoals.contains(goal);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selectedGoals.remove(goal);
                    } else {
                      _selectedGoals.add(goal);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isChecked ? AppColors.yellow.withValues(alpha: 0.12) : Colors.white,
                    border: Border.all(
                      color: isChecked ? AppColors.yellow : AppColors.cardBorder,
                      width: isChecked ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isChecked ? AppColors.night : AppColors.muted,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                            color: AppColors.night,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Organicemos tus gastos',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.night,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Queremos ayudarte a organizar tus compras sin gastar de más.',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          const Text(
            '¿Cada cuánto haces mercado?',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.night),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Semanal', 'Quincenal', 'Mensual'].map((freq) {
              final isSelected = _frequency == freq;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.green : Colors.white,
                      foregroundColor: isSelected ? Colors.white : AppColors.night,
                      side: BorderSide(
                        color: isSelected ? AppColors.green : AppColors.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() => _frequency = freq),
                    child: Text(
                      freq,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            '¿Cuánto dinero destinas a tu alimentación por periodo?',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.night),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.night,
            ),
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Text(
                  r'$ COP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ),
              hintText: '200000',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ejemplo: \$200.000 para mercado semanal. Puedes modificarlo cuando quieras en la pestaña Gastos.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
