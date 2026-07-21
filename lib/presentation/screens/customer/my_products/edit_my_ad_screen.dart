import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../configurations/resources/app_colors.dart';
import '../../../../model/product_model.dart';
import '../../../custom_widgets/Custom_header_bar.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../custom_widgets/en_digits_input_formatter.dart';
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
    viewModel.initControllers(
      widget.product,
    ); // تهيئة الكنترولرز بالبيانات الحالية
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<MyAdViewModel>(context);

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

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildTextField(
                            vm.priceController,
                            isNumber: true,
                            inputFormatters: [EnglishDigitsInputFormatter()],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 2. قائمة اختيار العملة (Dropdown)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50, // نفس ارتفاع حقل النص تقريباً
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC), // لون خلفية خفيف
                              border: Border.all(
                                color: const Color(0xFFE1E8EF),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: vm.currencies.contains(vm.priceCurrency)
                                    ? vm.priceCurrency
                                    : vm.currencies.first,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                                items: vm.currencies.map((String currency) {
                                  return DropdownMenuItem<String>(
                                    value: currency,
                                    child: CustomText(
                                      title: currency,
                                      size: Theme.of(context).textTheme.bodySmall!.fontSize! - 5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => vm.setCurrency(val), // استدعاء دالة التغيير
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // الوصف (متعدد الأسطر وينمو للأسفل)
                    _buildLabel('الوصف'),
                    _buildTextField(
                      vm.descController,
                      multiline: true,
                      minLines: 5,
                      maxLines: null,
                    ),

                    const SizedBox(height: 16),

                    // الموقع (يمكن جعله Dropdown لاحقاً)
                    _buildLabel('الموقع'),
                    _buildTextField(vm.locationController),

                    const SizedBox(height: 16),

                    // السماح بالمراسلة (true/false)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE1E8EF)),
                      ),
                      child: SwitchListTile(
                        value: vm.allowChat,
                        onChanged: vm.setAllowChat,
                        activeColor: AppColors.current.primary,
                        title: CustomText(
                          title: 'السماح بالمراسلة',
                          size: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F162A),
                        ),
                        subtitle: const CustomText(
                          title: 'عند الإيقاف لن يتمكّن المشترون من مراسلتك',
                          size: 11,
                          color: Color(0xFF63748A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // السماح بالاتصال (true/false)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE1E8EF)),
                      ),
                      child: SwitchListTile(
                        value: vm.allowCall,
                        onChanged: vm.setAllowCall,
                        activeColor: AppColors.current.primary,
                        title: CustomText(
                          title: 'السماح بالاتصال',
                          size: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F162A),
                        ),
                        subtitle: const CustomText(
                          title: 'عند الإيقاف لن يظهر رقمك ولن يتمكّن المشترون من الاتصال بك',
                          size: 11,
                          color: Color(0xFF63748A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildLabel('صور الإعلان'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // زر إضافة صور جديدة
                          _buildAddImageButton(() => vm.pickNewImages()),
                          const SizedBox(width: 12),

                          // عرض الصور القديمة (التي لم تُحذف بعد)
                          ...widget.product.images
                              .where(
                                (img) => !vm.deletedImageIds.contains(img.id),
                              ).map((img) => _buildImageItem(
                                  url: img.imageUrl,
                                  onDelete: () =>
                                      vm.removeExistingImage(img.id),
                                ),),

                          // عرض الصور الجديدة المختارة من الجهاز
                          ...vm.newImages.asMap().entries.map(
                            (entry) => _buildImageItem(
                              file: entry.value,
                              onDelete: () => vm.removeNewImage(entry.key),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // _buildLabel('صور الإعلان'),
                    // const SizedBox(height: 12),
                    // SizedBox(
                    //   height: 100,
                    //   child: ListView.separated(
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: widget.product.images.length + 1, // +1 لزر الإضافة
                    //     separatorBuilder: (c, i) => const SizedBox(width: 12),
                    //     itemBuilder: (context, index) {
                    //       if (index == 0) {
                    //         return _buildAddImageButton();
                    //       }
                    //       // عرض الصور الموجودة
                    //       return _buildImageItem(widget.product.images[index - 1].imageUrl);
                    //     },
                    //   ),
                    // ),
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

  Widget _buildAddImageButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 94,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E8EF), width: 2),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.current.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem({
    String? url,
    File? file,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: 94,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE1E8EF)),
              image: DecorationImage(
                image: file != null
                    ? FileImage(file)
                    : NetworkImage(url!) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // زر الحذف (X)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTextField(
    TextEditingController controller, {
    String? suffix,
    int? maxLines = 1,
    int? minLines,
    bool isNumber = false,
    bool multiline = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final TextInputType keyboardType = multiline
        ? TextInputType.multiline
        : (isNumber ? TextInputType.number : TextInputType.text);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        textInputAction:
            multiline ? TextInputAction.newline : TextInputAction.done,
        style: const TextStyle(
          fontFamily: 'Expo Arabic',
          fontSize: 14,
          color: Color(0xFF0F162A),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            fontFamily: 'Expo Arabic',
            color: Color(0xFF63748A),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: CustomText(
                    title: 'إلغاء',
                    color: Color(0xFF0F162A),
                    fontWeight: FontWeight.bold,
                    size: Theme.of(context).textTheme.bodySmall!.fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // زر حفظ
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.isEditingLoading
                      ? null
                      : () => vm.editMyAdFun(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.current.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: vm.isEditingLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : CustomText(
                          title: 'حفظ التعديلات',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: Theme.of(context).textTheme.bodySmall!.fontSize,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
