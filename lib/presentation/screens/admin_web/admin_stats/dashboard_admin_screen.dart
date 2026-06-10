import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import 'dashboard_admin_vm.dart';

class DashboardAdminScreen extends StatelessWidget {
  final Function(int, {String? userId, String? status})? onNavigate;

  const DashboardAdminScreen({super.key, this.onNavigate});

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
                // الهيدر وأزرار الفلترة والتحديث
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(title: 'نظرة عامة', size: fontSize + 4, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        CustomText(
                            title: 'إحصائيات المنصة وأداء الإعلانات',
                            size: fontSize - 2,
                            textHeight: 1,
                            color: Colors.grey
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // 🔥 زر تصفية التاريخ (يفتح الديالوج المخصص)
                        OutlinedButton.icon(
                          onPressed: () async {
                            // فتح الديالوج المخصص الذي بنيناه بالأسفل
                            final DateTimeRange? pickedDate = await showDialog<DateTimeRange>(
                              context: context,
                              barrierDismissible: false, // لا يغلق عند الضغط خارج النافذة (حسب طلبك)
                              builder: (BuildContext context) {
                                return CustomDateRangeDialog(
                                  initialStartDate: vm.startDate,
                                  initialEndDate: vm.endDate,
                                );
                              },
                            );

                            // إذا ضغط "تأكيد" (يرجع بيانات) نحدث الكود
                            if (pickedDate != null) {
                              vm.filterByDate(pickedDate.start, pickedDate.end);
                            }
                            // أما إذا ضغط "إلغاء" (يرجع null) فلا يحدث شيء (كما طلبت)
                          },
                          icon: const Icon(Icons.date_range, size: 18),
                          label: CustomText(
                            title: vm.startDate != null && vm.endDate != null
                                ? '${_formatDate(vm.startDate!)} - ${_formatDate(vm.endDate!)}'
                                : 'تصفية بالتاريخ',
                            size: fontSize - 2,
                            color: Colors.black87,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),

                        // زر تفريغ الفلتر (يظهر فقط إذا كان هناك فلتر تاريخ)
                        if (vm.startDate != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              tooltip: 'إلغاء الفلتر',
                              onPressed: () => vm.clearDateFilter(),
                            ),
                          ),

                        const SizedBox(width: 8),

                        // زر التحديث العادي
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: 'تحديث البيانات',
                          onPressed: () => vm.fetchStats(),
                        )
                      ],
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
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildMainStatCard(
                              context: context,
                              title: 'إجمالي المستخدمين',
                              value: vm.stats!.users.total.toString(),
                              subValue: 'انضموا هذا الأسبوع: ${vm.stats!.users.lastWeek}',
                              icon: Icons.people_alt_outlined,
                              gradientColors: [const Color(0xFF4A90E2), const Color(0xFF007AFF)],
                            ),
                            _buildMainStatCard(
                              context: context,
                              title: 'إجمالي الإعلانات',
                              value: vm.stats!.products.total.toString(),
                              subValue: 'أُضيفت هذا الأسبوع: ${vm.stats!.products.lastWeek}',
                              icon: Icons.campaign_outlined,
                              gradientColors: [const Color(0xFF34C759), const Color(0xFF28A745)],
                            ),
                            _buildMainStatCard(
                              context: context,
                              title: 'إجمالي المشاهدات',
                              value: vm.stats!.views.total.toString(),
                              subValue: 'مرات ظهور الإعلانات',
                              icon: Icons.visibility_outlined,
                              gradientColors: [const Color(0xFFFF9500), const Color(0xFFFF8C00)],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        CustomText(title: 'تفصيل حالة الإعلانات', size: fontSize + 2, fontWeight: FontWeight.bold),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildSubStatCard(
                              context: context,
                              title: 'الإعلانات النشطة',
                              value: vm.stats!.products.active.toString(),
                              icon: Icons.check_circle_outline,
                              color: Colors.green,
                              onTap: () {
                                if (onNavigate != null) onNavigate!(4, status: 'active');
                              },
                            ),
                            _buildSubStatCard(
                              context: context,
                              title: 'الإعلانات المنتهية',
                              value: vm.stats!.products.expired.toString(),
                              icon: Icons.access_time,
                              color: Colors.orange,
                              onTap: () {
                                if (onNavigate != null) onNavigate!(4, status: 'expired');
                              },
                            ),
                            _buildSubStatCard(
                              context: context,
                              title: 'الإعلانات المحظورة',
                              value: vm.stats!.products.blocked.toString(),
                              icon: Icons.block,
                              color: Colors.red,
                              onTap: () {
                                if (onNavigate != null) onNavigate!(4, status: 'blocked');
                              },
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

  // الكروت بقيت كما هي ...
  Widget _buildMainStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subValue,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = (MediaQuery.of(context).size.width - 500) / 3;
          double fontSize = Theme.of(context).textTheme.bodySmall!.fontSize!;
          if (cardWidth < 200) cardWidth = 200;

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
                Positioned(
                  left: -10,
                  bottom: -10,
                  child: Icon(icon, size: fontSize + 60, color: Colors.white.withOpacity(0.15)),
                ),
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

  Widget _buildSubStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = (MediaQuery.of(context).size.width - 340) / 3;
          if (cardWidth < 280) cardWidth = 280;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              hoverColor: color.withOpacity(0.05),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
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
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey.shade300, size: 16),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

// =====================================================================
// 🔥 نافذة الديالوج المخصصة للتاريخ (تصميم نظيف وخلفية بيضاء)
// =====================================================================
class CustomDateRangeDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const CustomDateRangeDialog({super.key, this.initialStartDate, this.initialEndDate});

  @override
  State<CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<CustomDateRangeDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final DateTime firstDate = isStart ? DateTime(2023) : (_startDate ?? DateTime(2023));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.current.primary, // لون التطبيق
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // إذا اختار تاريخ بداية أكبر من تاريخ النهاية الحالي، نصفر تاريخ النهاية
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // خلفية بيضاء نقية
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: CustomText(
          title: 'اختر نطاق التاريخ',
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
          size: Theme.of(context).textTheme.bodySmall!.fontSize! - 2,
      ),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
                title: 'حدد تاريخ البداية والنهاية لتصفية الإحصائيات.',
                color: Colors.grey,
                size: Theme.of(context).textTheme.bodySmall!.fontSize! - 4
            ),
            const SizedBox(height: 24),

            // زر اختيار تاريخ البداية
            _buildDateSelector(
              label: 'من تاريخ:',
              date: _startDate,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),

            // زر اختيار تاريخ النهاية
            _buildDateSelector(
              label: 'إلى تاريخ:',
              date: _endDate,
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        // زر الإلغاء (لا يعمل شيء فقط يغلق النافذة)
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: CustomText(title: 'إلغاء', color: Colors.grey, fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize! - 4),
        ),
        // زر التأكيد (يرسل البيانات إذا كانت مكتملة)
        ElevatedButton(
          onPressed: (_startDate != null && _endDate != null)
              ? () {
            // إغلاق النافذة وتمرير التواريخ
            Navigator.pop(context, DateTimeRange(start: _startDate!, end: _endDate!));
          }
              : null, // الزر يكون معطل إذا لم يختار التاريخين
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.current.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: CustomText(title: 'تأكيد', color: Colors.white, fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize! - 4),
        ),
      ],
    );
  }

  // كرت فرعي لتحديد التاريخ
  Widget _buildDateSelector({required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFFAFBFF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(title: label, size: 14, color: Colors.black87),
            Row(
              children: [
                CustomText(
                  title: date != null ? '${date.year}/${date.month}/${date.day}' : 'اختر التاريخ',
                  size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                  fontWeight: FontWeight.bold,
                  color: date != null ? AppColors.current.primary : Colors.grey,
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_month, size: 18, color: date != null ? AppColors.current.primary : Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}