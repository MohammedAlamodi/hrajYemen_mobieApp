import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../common/common_view_model.dart';
import 'add_ad_view_model.dart';

class AddAdStep4Review extends StatelessWidget {
  const AddAdStep4Review({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddAdViewModel>(context);
    CommonViewModel commonViewModel =Provider.of<CommonViewModel>(context);

    return Column(
      children: [
        // كارت معاينة الإعلان (يشبه الكروت التي بنيناها في الرئيسية)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E8EF)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // الصورة
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: vm.images.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(vm.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: vm.images.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),

              // التفاصيل
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: vm.titleController.text,
                      size: Theme.of(context).textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          title: '${vm.priceController.text} ر.ي',
                          size:
                              Theme.of(
                                context,
                              ).textTheme.titleMedium!.fontSize! -
                              2,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2462EB),
                        ),
                        CustomText(
                          title: vm.selectedCity ?? '',
                          size:
                              Theme.of(
                                context,
                              ).textTheme.titleMedium!.fontSize! -
                              2,
                          color: const Color(0xFF63748A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // تفاصيل المراجعة (قائمة)
        _buildReviewRow(
          context: context,
          title: 'الصور',
          value: '${vm.images.length} صور',
          icon: Icons.image_outlined,
        ),
        _buildReviewRow(
          context: context,
          title: 'السعر',
          value: '${vm.priceController.text} ريال',
          icon: Icons.attach_money,
        ),
        _buildReviewRow(
          context: context,
          title: 'الموقع',
          value: vm.selectedCity ?? '-',
          icon: Icons.location_on_outlined,
        ),
        _buildReviewRow(
          context: context,
          title: 'التواصل',
          value: [
            if (vm.hasChat) 'شات',
            if (vm.hasCall) 'اتصال',
            if (vm.hasWhatsApp) 'واتس',
          ].join('، '),
          icon: Icons.contact_phone_outlined,
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CustomText(
                  title: 'إتفاقية حراج حضرموت',
                  fontWeight: FontWeight.bold,
                  color: AppColors.current.success,
                ),
              ),

              Divider(),

              CustomText(
                title:
                    'أتعهد أمام اللّٰه وأقسم أنا المعلن بدفع رسوم تطبيق حراج حضرموت المقدرة 1% من قيمة البضاعة المعلنة أو المباعه سواء تم البيع عن طريق التطبيق أو بسببه',
                color: const Color(0xFF63748A),
                size: Theme.of(context).textTheme.titleMedium!.fontSize! - 4,
              ),
              SizedBox(height: 8),
              CustomText(
                title:
                    'كما أتعهد بدفع الرسوم خلال 10 أيام من استلام مبلغ المبايعة',
                color: const Color(0xFF63748A),
                size: Theme.of(context).textTheme.titleMedium!.fontSize! - 3,
              ),
              SizedBox(height: 15),

              Center(
                child: CustomText(
                  title: 'بسم الله الرحمن الرحيم',
                  color: AppColors.current.success,
                  size: Theme.of(context).textTheme.titleMedium!.fontSize! - 3,
                ),
              ),
              Center(
                child: CustomText(
                  title:
                      'وَأَوْفُوا بِعَهْدِ اللهَّ إِذَا عَاهَدْتَمْ وَلَا تَنقُضُوا الْأَيْمَانَ بَعْدَ تَوْكِيدِهَا وَقَدْ جَعَلْتُمُ اللّهَ عَلَيْكُمْ كَفِيلًا إِنَّ اللهَّ يَعْلَمُ مَا تَفْعَلُونَ',
                  color: AppColors.current.success,
                  textAlign: TextAlign.center,
                  size: Theme.of(context).textTheme.titleMedium!.fontSize! - 3,
                ),
              ),

              CheckboxListTile(
                title: CustomText(
                  title: 'أقر وأتعهد بذلك',
                    fontWeight: FontWeight.bold,
                  size: Theme.of(context).textTheme.titleMedium!.fontSize! - 3,
                ),
                value: vm.isAgreeToPostAd,
                controlAffinity: commonViewModel.locale == 'ar'
                    ? ListTileControlAffinity.leading
                : ListTileControlAffinity.trailing,
                onChanged: (value) {
                  vm.setAgreeToPostAd(value ?? false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2462EB), size: 20),
          ),
          const SizedBox(width: 8),
          CustomText(
            title: title,
            fontWeight: FontWeight.bold,
            size: Theme.of(context).textTheme.titleMedium!.fontSize! - 1,
          ),
          const Spacer(),
          CustomText(
            title: value,
            color: const Color(0xFF63748A),
            size: Theme.of(context).textTheme.titleMedium!.fontSize! - 2,
          ),
        ],
      ),
    );
  }
}
