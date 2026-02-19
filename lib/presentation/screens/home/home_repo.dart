import 'dart:math';
import 'package:flutter/material.dart';

import '../../../model/category_model.dart';
import '../../../model/product_condition.dart';
import '../../../model/product_image_model.dart';
import '../../../model/product_model.dart';
import '../../../model/user_model.dart';
import '../my_ads/custom_widgets/my_ad_card.dart'; // للأيقونات إذا لزم الأمر

class HomeRepository {
  // =========================================================
  // 1. جلب قائمة المنتجات (للمتجر أو الصفحة الرئيسية)
  // =========================================================
  Future<List<ProductModel>> fetchProducts({
    required int page,
    int limit = 20,
  }) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 2));

    // إذا الصفحة > 5 نوقف التحميل (نهاية البيانات)
    if (page > 5) return [];

    return List.generate(limit, (index) {
      final id = ((page - 1) * limit) + index;

      return ProductModel(
        id: id,
        title: 'سيارة تويوتا كامري موديل 202${Random().nextInt(4)} نظيفة',
        description: 'سيارة بحالة ممتازة، استخدام شخصي، بودي بلد، الممشى قليل...',
        price: (Random().nextInt(50) + 10) * 1000.0, // Double
        condition: index % 2 == 0 ? ProductCondition.newItem : ProductCondition.used,
        status: AdStatus.active.toString(),
        // إعدادات التواصل
        allowChat: true,
        allowCall: true,
        allowWhatsApp: index % 3 == 0,
        showPhoneNumber: true,
        viewsCount: Random().nextInt(500),

        createdAt: DateTime.now().subtract(Duration(days: Random().nextInt(10))),

        // العلاقات
        userId: 'user_$id',
        user: _getDummyUser('user_$id', 'البائع $id'), // بيانات البائع

        categoryId: 1,
        category: null, // في القائمة المصغرة قد لا نحتاج الكائن كاملاً

        subCategoryId: 101,
        subCategory: _getRandomSubCategory(),

        cityId: 1,
        city: _getRandomCity(),

        regionId: 1,
        region: _getRandomRegion(),

        // الصور (نستخدم موديل الصور الجديد)
        images: [
          ProductImageModel(
              id: 1,
              imageUrl: 'https://arabgt.com/wp-content/uploads/2021/08/%D8%A7%D8%B3%D8%B9%D8%A7%D8%B1-%D9%88%D9%85%D9%88%D8%A7%D8%B5%D9%81%D8%A7%D8%AA-%D8%B3%D9%8A%D8%A7%D8%B1%D9%87-%D9%8A%D8%A7%D8%B1%D8%B3-2021-4.jpg',
              isMain: true,
              productId: id
          ),
          ProductImageModel(
              id: 2,
              imageUrl: 'https://placehold.co/400x300/0D9488/white?text=Side+View',
              isMain: false,
              productId: id
          ),
        ],
        comments: [], // في القائمة الرئيسية عادة لا نجلب التعليقات
      );
    });
  }

  // =========================================================
  // 2. جلب الفئات (الأقسام)
  // =========================================================
  Future<List<CategoryModel>> fetchCategories() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة الشبكة

    return [
      CategoryModel(
          id: 1,
          name: 'سيارات',
          icon: Icons.directions_car_filled, // أيقونة
          color: const Color(0xFF2462EB),    // لون أزرق
          subCategories: [
            SubCategoryModel(id: 11, name: 'تويوتا', categoryId: 1),
            SubCategoryModel(id: 12, name: 'هونداي', categoryId: 1),
            SubCategoryModel(id: 13, name: 'فورد', categoryId: 1),
          ]
      ),
      CategoryModel(
          id: 2,
          name: 'عقارات',
          icon: Icons.home_work,
          color: const Color(0xFF10B981),    // لون أخضر
          subCategories: [
            SubCategoryModel(id: 21, name: 'شقق للبيع', categoryId: 2),
            SubCategoryModel(id: 22, name: 'أراضي', categoryId: 2),
          ]
      ),
      CategoryModel(
          id: 3,
          name: 'أجهزة',
          icon: Icons.phone_android,
          color: const Color(0xFFF59E0B),    // لون برتقالي
          subCategories: []
      ),
      CategoryModel(
          id: 4,
          name: 'أزياء',
          icon: Icons.checkroom,
          color: const Color(0xFFEC4899),    // لون وردي
          subCategories: []
      ),
      CategoryModel(
          id: 5,
          name: 'أثاث',
          icon: Icons.chair,
          color: const Color(0xFF8B5CF6),    // لون بنفسجي
          subCategories: []
      ),
      CategoryModel(
          id: 6,
          name: 'حيوانات',
          icon: Icons.pets,
          color: const Color(0xFF795548),    // لون بني
          subCategories: []
      ),
      CategoryModel(
          id: 7,
          name: 'خدمات',
          icon: Icons.handyman,
          color: const Color(0xFF607D8B),    // لون رمادي أزرق
          subCategories: []
      ),
    ];
  }

  // =========================================================
  // 3. جلب تفاصيل المنتج (كاملة)
  // =========================================================
  // ملاحظة: قمنا بتغيير النوع المرجعي ليكون ProductModel بدلاً من ProductDetailsModel 
  // لأن ProductModel الآن يحتوي على كل شيء (User, Comments, Images) بناءً على تحديث الـ C#
  Future<ProductModel> fetchProductDetails(int productId) async {
    await Future.delayed(const Duration(seconds: 2));

    return ProductModel(
      id: productId,
      title: 'تويوتا كامري 2020 نظيف جداً فل كامل',
      description: 'السيارة بحالة الوكالة، بودي بلد، مكينة وجير عالشرط. الممشى 50 ألف كيلو فقط. جميع الصيانات في الوكالة. السيارة موجودة في المكلا للمعاينة...',
      price: 45000.0,
      status: AdStatus.active.toString(),
      condition: ProductCondition.used,

      allowChat: true,
      allowCall: true,
      allowWhatsApp: true,
      showPhoneNumber: true,

      viewsCount: 1250,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),

      userId: 'seller_123',
      user: UserModel(
        id: 'seller_123',
        fullName: 'معرض النخبة',
        profileImageUrl: 'https://placehold.co/100x100/2462EB/white?text=Seller',
        phoneNumber: '0500000000',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),

      categoryId: 1,
      category: CategoryModel(id: 1, name: 'سيارات', icon: Icons.directions_car_filled, color: const Color(0xFF2462EB)),

      subCategoryId: 101,
      subCategory: SubCategoryModel(id: 101, name: 'تويوتا', categoryId: 1),

      cityId: 1,
      city: CityModel(id: 1, name: 'المكلا'),

      regionId: 10,
      region: RegionModel(id: 10, name: 'فوه', cityId: 1),

      images: [
        ProductImageModel(id: 1, productId: productId, isMain: true, imageUrl: "https://arabgt.com/wp-content/uploads/2021/08/%D8%A7%D8%B3%D8%B9%D8%A7%D8%B1-%D9%88%D9%85%D9%88%D8%A7%D8%B5%D9%81%D8%A7%D8%AA-%D8%B3%D9%8A%D8%A7%D8%B1%D9%87-%D9%8A%D8%A7%D8%B1%D8%B3-2021-4.jpg"),
        ProductImageModel(id: 2, productId: productId, isMain: false, imageUrl: "https://placehold.co/600x400/0D9488/white?text=Interior"),
        ProductImageModel(id: 3, productId: productId, isMain: false, imageUrl: "https://placehold.co/600x400/F87315/white?text=Back"),
      ],

      comments: [
        ProductCommentModel(
            id: 101,
            comment: 'كم حدك فيها من الآخر؟',
            productId: productId,
            userId: '21',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            user: UserModel(
                id: 'user_comment_1',
                fullName: 'سالم بن محفوظ',
                profileImageUrl: 'https://placehold.co/80x80?text=S'
            )
        ),
        ProductCommentModel(
            id: 102,
            comment: 'ماشاء الله تبارك الله، الله يبارك لك',
            productId: productId,
            userId: '44',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            user: UserModel(
                id: 'user_comment_2',
                fullName: 'عمر باوزير',
                profileImageUrl: 'https://placehold.co/80x80?text=O'
            )
        ),
      ],
    );
  }

  // =========================================================
  // 4. دوال مساعدة لتوليد بيانات عشوائية (Helpers)
  // =========================================================

  UserModel _getDummyUser(String id, String name) {
    return UserModel(
      id: id,
      fullName: name,
      profileImageUrl: 'https://placehold.co/100x100?text=${name.split(" ").last}',
      createdAt: DateTime.now(),
    );
  }

  RegionModel _getRandomRegion() {
    final regions = [
      RegionModel(id: 1, cityId: 1, name: 'فوه'),
      RegionModel(id: 2, cityId: 1, name: 'الشرج'),
      RegionModel(id: 3, cityId: 1, name: 'الديس'),
      RegionModel(id: 4, cityId: 2, name: 'كريتر'),
      RegionModel(id: 5, cityId: 3, name: 'حدة'),
    ];
    return regions[Random().nextInt(regions.length)];
  }

  CityModel _getRandomCity() {
    final cities = [
      CityModel(id: 1, name: 'المكلا'),
      CityModel(id: 2, name: 'عدن'),
      CityModel(id: 3, name: 'صنعاء'),
      CityModel(id: 4, name: 'تعز'),
      CityModel(id: 5, name: 'إب'),
    ];
    return cities[Random().nextInt(cities.length)];
  }

  SubCategoryModel _getRandomSubCategory() {
    final subs = [
      SubCategoryModel(id: 1, categoryId: 1, name: 'تويوتا'),
      SubCategoryModel(id: 2, categoryId: 1, name: 'هونداي'),
      SubCategoryModel(id: 3, categoryId: 1, name: 'كيا'),
      SubCategoryModel(id: 4, categoryId: 1, name: 'نيسان'),
      SubCategoryModel(id: 5, categoryId: 1, name: 'فورد'),
    ];
    return subs[Random().nextInt(subs.length)];
  }
}