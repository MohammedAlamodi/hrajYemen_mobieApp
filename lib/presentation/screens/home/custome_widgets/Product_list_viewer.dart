import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ye_hraj/presentation/custom_widgets/loading_widgets.dart';

import '../../../../model/product_model.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../products/product_details_screen.dart';
import 'product_card_horizontal.dart';
import 'product_card_vertical.dart'; // سنحتاج Provider هنا
// تأكد من استيراد الكارد العمودي
// تأكد من استيراد الكارد الأفقي

// View Model داخلي للتحكم في العرض
class ProductDisplayViewModel extends ChangeNotifier {
  bool _isGridView = true;

  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }
}

class ProductListViewer extends StatelessWidget {
  final List<ProductModel> products;
  final String title;
  final Function()? onScrollEnd;
  final bool isLoadingMore;

  const ProductListViewer({
    super.key,
    required this.products,
    required this.title,
    this.onScrollEnd,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDisplayViewModel(),
      child: Consumer<ProductDisplayViewModel>(
        builder: (context, displayVM, child) {
          // ✅ الحل الجذري: استخدام CustomScrollView بدلاً من Column
          // هذا يسمح للمحتوى بالسكرول بشكل طبيعي داخل NestedScrollView ويمنع الـ Overflow
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!isLoadingMore &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.9) {
                if (onScrollEnd != null) {
                  onScrollEnd!();
                }
              }
              return false;
            },
            child: CustomScrollView(
              // key: PageStorageKey<String>('products'), // اختياري لحفظ مكان السكرول
              slivers: [
                // 1. العنوان وزر التبديل (كـ Sliver)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 4,
                      left: 4,
                      bottom: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          title: title,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F162A),
                        ),
                        InkWell(
                          onTap: () => displayVM.toggleViewMode(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              displayVM.isGridView
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              color: const Color(0xFF0F162A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. قائمة المنتجات (SliverGrid أو SliverList)
                displayVM.isGridView
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      productId: products[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: ProductCardVertical(
                                product: products[index],
                              ),
                            ),
                            childCount: products.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.70,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      productId: products[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: ProductCardHorizontal(
                                product: products[index],
                              ),
                            ),
                            childCount: products.length,
                          ),
                        ),
                      ),

                // 3. مؤشر التحميل في الأسفل (Pagination)
                if (isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CustomLoadingWidget()),
                    ),
                  ),

                // مسافة أمان في الأسفل
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class ProductListViewer extends StatelessWidget {
//   final String? title;
//   final List<ProductModel> products;
//
//   const ProductListViewer({Key? key, required this.products, this.title}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // نستخدم ChangeNotifierProvider لإنشاء ViewModel خاص بهذه القائمة فقط
//     return ChangeNotifierProvider(
//       create: (_) => ProductDisplayViewModel(),
//       child: Consumer<ProductDisplayViewModel>(
//         builder: (context, viewModel, child) {
//           return Column(
//             children: [
//               // --- شريط الأدوات (زر التبديل) ---
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // عدد النتائج (اختياري)
//                     CustomText(
//                       title: title ?? '${products.length} إعلان',
//                       color: const Color(0xFF63748A),
//                       fontWeight: FontWeight.bold,
//                       size: 14,
//                     ),
//
//                     // أيقونة التبديل
//                     InkWell(
//                       onTap: () => viewModel.toggleViewMode(),
//                       borderRadius: BorderRadius.circular(8),
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8F9FB),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: const Color(0xFFE1E8EF)),
//                         ),
//                         child: Icon(
//                           viewModel.isGridView
//                               ? Icons.view_list_rounded // إذا كان شبكة، اعرض أيقونة القائمة
//                               : Icons.grid_view_rounded, // العكس
//                           color: const Color(0xFF0F162A),
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // --- منطقة العرض (Grid أو List) ---
//               Expanded(
//                 child: viewModel.isGridView
//                     ? _buildGridView(products)
//                     : _buildListView(products),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // دالة بناء الشبكة (Grid)
//   Widget _buildGridView(List<ProductModel> products) {
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.72,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         return ProductCardVertical(product: products[index]); // الكارد العمودي القديم
//       },
//     );
//   }
//
//   // دالة بناء القائمة (List)
//   Widget _buildListView(List<ProductModel> products) {
//     return ListView.builder(
//       itemCount: products.length,
//       primary: true,
//       itemBuilder: (context, index) {
//         return ProductCardHorizontal(product: products[index]);
//       },
//     );
//   }
// }
