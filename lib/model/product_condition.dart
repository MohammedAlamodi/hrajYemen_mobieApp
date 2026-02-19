enum ProductCondition {
  newItem, // يقابل 1
  used,    // يقابل 2
}

// كلاس مساعد للتحويل بين الرقم والـ Enum
class ProductConditionHelper {
  static ProductCondition fromInt(int value) {
    switch (value) {
      case 1: return ProductCondition.newItem;
      case 2: return ProductCondition.used;
      default: return ProductCondition.used; // قيمة افتراضية
    }
  }

  static int toInt(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem: return 1;
      case ProductCondition.used: return 2;
    }
  }

  static String toText(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem: return 'جديد';
      case ProductCondition.used: return 'مستعمل';
    }
  }
}