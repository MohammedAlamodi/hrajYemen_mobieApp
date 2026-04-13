class AdminStatsModel {
  final UsersStats users;
  final ProductsStats products;
  final ViewsStats views;

  AdminStatsModel({required this.users, required this.products, required this.views});

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      users: UsersStats.fromJson(json['users'] ?? {}),
      products: ProductsStats.fromJson(json['products'] ?? {}),
      views: ViewsStats.fromJson(json['views'] ?? {}),
    );
  }
}

class UsersStats {
  final int total;
  final int lastWeek;

  UsersStats({required this.total, required this.lastWeek});

  factory UsersStats.fromJson(Map<String, dynamic> json) => UsersStats(
    total: json['total'] ?? 0,
    lastWeek: json['lastWeek'] ?? 0,
  );
}

class ProductsStats {
  final int total;
  final int active;
  final int expired;
  final int blocked;
  final int lastWeek;

  ProductsStats({
    required this.total,
    required this.active,
    required this.expired,
    required this.blocked,
    required this.lastWeek,
  });

  factory ProductsStats.fromJson(Map<String, dynamic> json) => ProductsStats(
    total: json['total'] ?? 0,
    active: json['active'] ?? 0,
    expired: json['expired'] ?? 0,
    blocked: json['blocked'] ?? 0,
    lastWeek: json['lastWeek'] ?? 0,
  );
}

class ViewsStats {
  final int total;

  ViewsStats({required this.total});

  factory ViewsStats.fromJson(Map<String, dynamic> json) => ViewsStats(
    total: json['total'] ?? 0,
  );
}