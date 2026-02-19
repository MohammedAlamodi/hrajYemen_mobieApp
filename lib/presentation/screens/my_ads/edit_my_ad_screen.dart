import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';
import '../../../model/product_model.dart';
import '../../custom_widgets/Custom_header_bar.dart';
import '../../custom_widgets/custom_text.dart';
import 'my_ad_view_model.dart';

class EditAdScreen extends StatefulWidget {
  final ProductModel product;

  const EditAdScreen({super.key, required this.product});

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  late MyAdViewModel viewModel;

  @override
  void initState() {
    // TODO: implement initState
    _init();
    super.initState();
  }


  void _init() {
    viewModel = Provider.of<MyAdViewModel>(context, listen: false);
    viewModel.initControllers(widget.product); // تهيئة الكنترولرز بالبيانات الحالية
  }

  @override
  Widget build(BuildContext context) {
    viewModel= Provider.of<MyAdViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.current.appBackground,
      body: Column(
        children: [
          // 1. الهيدر
          const CustomHeaderBar(
            title: 'تعديل الإعلان',
            showBack: true,
            showSearch: false,
            onSearchChange: null,
          ),

          // 2. نموذج التعديل
          Expanded(
            child: Consumer<MyAdViewModel>(
              builder: (context, vm, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // العنوان
                    _buildLabel('العنوان'),
                    _buildTextField(vm.titleController),

                    const SizedBox(height: 16),

                    // السعر
                    _buildLabel('السعر'),
                    _buildTextField(vm.priceController, suffix: 'ر.ي', isNumber: true),

                    const SizedBox(height: 16),

                    // الوصف
                    _buildLabel('الوصف'),
                    _buildTextField(vm.descController, maxLines: 5),

                    const SizedBox(height: 16),

                    // الموقع (يمكن جعله Dropdown لاحقاً)
                    _buildLabel('الموقع'),
                    _buildTextField(vm.locationController),

                    const SizedBox(height: 24),

                    // صور الإعلان
                    _buildLabel('صور الإعلان'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.product.images.length + 1, // +1 لزر الإضافة
                        separatorBuilder: (c, i) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAddImageButton();
                          }
                          // عرض الصور الموجودة
                          return _buildImageItem(widget.product.images[index - 1].imageUrl);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. أزرار الحفظ والإلغاء
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // --- Widgets مساعدة ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomText(
        title: text,
        size: 14,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F162A),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? suffix, int maxLines = 1, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF0F162A)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF63748A)),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 94,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.add_a_photo_outlined, color: Color(0xFF2462EB)),
      ),
    );
  }

  Widget _buildImageItem(String url) {
    return Container(
      width: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Consumer<MyAdViewModel>(
        builder: (context, vm, child) {
          return Row(
            children: [
              // زر إلغاء
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE1E8EF), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: CustomText(title: 'إلغاء', color: Color(0xFF0F162A), fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize,),
                ),
              ),
              const SizedBox(width: 16),
              // زر حفظ
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.isEditingLoading ? null : () => vm.saveChanges(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2462EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: vm.isEditingLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : CustomText(title: 'حفظ التعديلات', color: Colors.white, fontWeight: FontWeight.bold, size: Theme.of(context).textTheme.bodySmall!.fontSize,),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}