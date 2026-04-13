import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import 'dashboard_admin_vm.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardAdminVM(),
      child: Consumer<DashboardAdminVM>(
        builder: (context, vm, child) {
          final fontSize = Theme.of(context).textTheme.bodySmall!.fontSize! - 2;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر وزر التحديث
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(title: 'نظرة عامة', size: fontSize + 4, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        CustomText(title: 'إحصائيات المنصة وأداء الإعلانات', size: fontSize - 2, color: Colors.grey),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      tooltip: 'تحديث البيانات',
                      onPressed: () => vm.fetchStats(),
                    )
                  ],
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.current.primary))
                      : vm.stats == null
                      ? Center(child: CustomText(title: 'تعذر جلب الإحصائيات', size: fontSize))
                      : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === الصف الأول: الإحصائيات الرئيسية الكبرى ===
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildMainStatCard(
                              title: 'إجمالي المستخدمين',
                              value: vm.stats!.users.total.toString(),
                              subValue: 'انضموا هذا الأسبوع: ${vm.stats!.users.lastWeek}',
                              icon: Icons.people_alt_outlined,
                              gradientColors: [const Color(0xFF4A90E2), const Color(0xFF007AFF)],
                            ),
                            _buildMainStatCard(
                              title: 'إجمالي الإعلانات',
                              value: vm.stats!.products.total.toString(),
                              subValue: 'أُضيفت هذا الأسبوع: ${vm.stats!.products.lastWeek}',
                              icon: Icons.campaign_outlined,
                              gradientColors: [const Color(0xFF34C759), const Color(0xFF28A745)],
                            ),
                            _buildMainStatCard(
                              title: 'إجمالي المشاهدات',
                              value: vm.stats!.views.total.toString(),
                              subValue: 'مرات ظهور الإعلانات',
                              icon: Icons.visibility_outlined,
                              gradientColors: [const Color(0xFFFF9500), const Color(0xFFFF8C00)],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // === الصف الثاني: تفصيل حالة الإعلانات ===
                        CustomText(title: 'تفصيل حالة الإعلانات', size: fontSize + 2, fontWeight: FontWeight.bold),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildSubStatCard(
                              title: 'الإعلانات النشطة',
                              value: vm.stats!.products.active.toString(),
                              icon: Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            _buildSubStatCard(
                              title: 'الإعلانات المنتهية',
                              value: vm.stats!.products.expired.toString(),
                              icon: Icons.access_time,
                              color: Colors.orange,
                            ),
                            _buildSubStatCard(
                              title: 'الإعلانات المحظورة',
                              value: vm.stats!.products.blocked.toString(),
                              icon: Icons.block,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // كرت الإحصائيات الرئيسية (ملون بتدرج - Gradient)
  Widget _buildMainStatCard({
    required String title,
    required String value,
    required String subValue,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    // جعل الكروت تتجاوب مع الشاشة: إذا كانت الشاشة كبيرة تأخذ مساحة معينة، وإذا صغيرة تنزل للسطر
    return LayoutBuilder(
        builder: (context, constraints) {
          // حساب العرض الديناميكي ليأخذ ثلث الشاشة تقريباً مع ترك مسافات
          double cardWidth = (MediaQuery.of(context).size.width - 500) / 3;
          double fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!; // قاعدة عامة لحساب العرض بناءً على حجم الخط
          debugPrint('Calculated card width: $cardWidth');
          if (cardWidth < 200) cardWidth = 200; // أقل عرض مسموح للكرت

          return Container(
            width: cardWidth,
            height: 160,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: gradientColors.last.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                // أيقونة خلفية شفافة لتعطي مظهراً فخماً
                Positioned(
                  left: -10,
                  bottom: -10,
                  child: Icon(icon, size: fontSize + 60, color: Colors.white.withOpacity(0.15)),
                ),
                // البيانات الفعلية
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(title: title, color: Colors.white, size: fontSize - 3, fontWeight: FontWeight.w600),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Icon(icon, color: Colors.white, size: fontSize + 10),
                        ),
                      ],
                    ),
                    CustomText(title: value, color: Colors.white, size: fontSize + 2, fontWeight: FontWeight.bold),
                    CustomText(title: subValue, color: Colors.white.withOpacity(0.8), size: fontSize - 4),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  // كرت الإحصائيات الفرعية (خلفية بيضاء مع حدود وتفاصيل دقيقة)
  Widget _buildSubStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = (MediaQuery.of(context).size.width - 340) / 3;
          if (cardWidth < 280) cardWidth = 280;

          return Container(
            width: cardWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(title: title, color: Colors.grey, size: 14),
                    const SizedBox(height: 4),
                    CustomText(title: value, fontWeight: FontWeight.bold, size: 24),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
}