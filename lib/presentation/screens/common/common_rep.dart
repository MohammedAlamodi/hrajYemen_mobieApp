//
// import 'package:Taqseet/models/costomer_model.dart';
// import 'package:Taqseet/models/notification_model.dart';
//
// import '../../../configurations/data/api_services.dart';
// import '../../../configurations/data/end_points_manager.dart';
// import '../../../configurations/resources/strings_manager.dart';
// import '../../../configurations/user_preferences.dart';
// import '../../../models/offer_category_model.dart';
// import '../../../models/offer_model.dart';
// import '../../../models/user_role_model.dart';
//
// class CommonViewRepository {
//   CommonViewRepository._internal();
//
//   static final CommonViewRepository _singleton =
//       CommonViewRepository._internal();
//
//   factory CommonViewRepository() {
//     return _singleton;
//   }
//
//   Future<List<UserRolesModel>> getUseRoles(context) {
//     ApiService().getBaseUrlAndToken();
//
//     return ApiService()
//         .dio
//         .get(EndPointsStrings.getUserRoleEndPoint)
//         .then((value) {
//       var result = ApiService.decodeResp(value);
//
//       if (result != null) {
//         var val = result
//             .map<UserRolesModel>((e) => UserRolesModel.fromJson(e))
//             .toList();
//
//         return val;
//       } else {
//         return [];
//       }
//     });
//   }
//
//   Future<List<CustomerModel>> getCustomers(context) {
//     ApiService().getBaseUrlAndToken();
//
//     return ApiService()
//         .dio
//         .get(EndPointsStrings.getCustomersEndPoint)
//         .then((value) {
//       var result = ApiService.decodeResp(value);
//
//       if (result != null) {
//         var val = result
//             .map<CustomerModel>((e) => CustomerModel.fromJson(e))
//             .toList();
//
//         return val;
//       } else {
//         return [];
//       }
//     });
//   }
//
//   Future<List<OfferCategoryModel>> getOfferCategorise(context) {
//     ApiService().getBaseUrlAndToken();
//
//     return ApiService()
//         .dio
//         .get(EndPointsStrings.getOfferCategoryEndPoint)
//         .then((value) {
//       var result = ApiService.decodeResp(value);
//       if (result != null) {
//         var val = result
//             .map<OfferCategoryModel>((e) => OfferCategoryModel.fromJson(e))
//             .toList();
//
//         return val;
//       } else {
//         return [];
//       }
//     });
//   }
//
//   Future<List<OfferModel>> getOffers(context) {
//     ApiService().getBaseUrlAndToken();
//
//     return ApiService()
//         .dio
//         .get(EndPointsStrings.getOfferEndPoint)
//         .then((value) {
//       var result = ApiService.decodeResp(value);
//       if (result != null) {
//         var val = result
//             .map<OfferModel>((e) => OfferModel.fromJson(e))
//             .toList();
//
//         return val;
//       } else {
//         return [];
//       }
//     });
//   }
//
//   Future<List<NotificationModel>> getNotifications(context) async {
//
//     UserPreferences userPreferences = UserPreferences();
//
//     String customerId = await userPreferences.getString(key: AppStrings.userIdKey, defaultValue: 'null');
//
//     if(customerId != 'null') {
//       ApiService().getBaseUrlAndToken();
//
//       return ApiService()
//           .dio
//           .get('${EndPointsStrings.getNotificationsEndPoint}/$customerId')
//           .then((value) {
//         var result = ApiService.decodeResp(value);
//         if (result != null) {
//           var val = result
//               .map<NotificationModel>((e) => NotificationModel.fromJson(e))
//               .toList();
//
//           return val;
//         } else {
//           return [];
//         }
//       });
//     }
//     else{
//       return [];
//     }
//   }
//
//   Future<List<OfferModel>> getOffersByBank(context,bankId) {
//     ApiService().getBaseUrlAndToken();
//
//     return ApiService()
//         .dio
//         .get('${EndPointsStrings.getOfferByBankIdEndPoint}$bankId')
//         .then((value) {
//       var result = ApiService.decodeResp(value);
//       if (result != null) {
//         var val = result
//             .map<OfferModel>((e) => OfferModel.fromJson(e))
//             .toList();
//
//         return val;
//       } else {
//         return [];
//       }
//     });
//   }
//
// // Future<List<TaxData>> getAllTaxes(context) {
// //   ApiService().getBaseUrlAndToken();
// //
// //   return ApiService()
// //       .dio
// //       .get(EndPointsStrings.getTaxesEndPoint)
// //       .then((value) {
// //     var result = ApiService.decodeResp(value);
// //
// //     if (result['data'] != null) {
// //       var val =
// //           result['data'].map<TaxData>((e) => TaxData.fromJson(e)).toList();
// //
// //       return val;
// //     } else {
// //       return [];
// //     }
// //   });
// // }
// }
