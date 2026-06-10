
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../configurations/data/api_services.dart';
import '../../../../configurations/data/end_points_manager.dart';
import '../../../../model/bank_account_model.dart';

class BanksAdminRepo {
  BanksAdminRepo._internal();

  static final BanksAdminRepo _singleton = BanksAdminRepo._internal();

  factory BanksAdminRepo() {
    return _singleton;
  }


  Future<List<BankAccountModel>> fetchBanks() async {
    await ApiService().getToken();

    try {
      final response = await ApiService().dio.get(EndPointsStrings.banksEndPoint);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => BankAccountModel.fromJson(e))
              .toList();
        } else if (response.data is Map && response.data['data'] != null) {
          return (response.data['data'] as List)
              .map((e) => BankAccountModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint("خطأ في الاتصال بالشبكة (Banks): ${e.message}");
      return [];
    } catch (e) {
      debugPrint("خطأ في تحويل بيانات الحسابات: $e");
      return [];
    }
  }

  Future<bool> createBank({required String name, required String accountNumber, XFile? image}) async {
    try {
      await ApiService().getToken();

      FormData formData = FormData.fromMap({
        'Name': name,
        'AccountNumber': accountNumber,
        'ImageUrl': '', // إرسال قيمة فارغة كما طلبت
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            'image', // تأكد أن هذا يطابق اسم المتغير في الباك إند
            MultipartFile.fromBytes(
              await image.readAsBytes(),
              filename: image.name,
            ),
          ),
        );
      }

      final response = await ApiService().dio.post(
        EndPointsStrings.banksEndPoint,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint("خطأ أثناء رفع الحساب: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
      return false;
    }
  }

  Future<bool> updateBank(int id, String name, String accountNumber, XFile? image) async {
    try {
      await ApiService().getToken();

      FormData formData = FormData.fromMap({
        'Name': name,
        'AccountNumber': accountNumber,
        'ImageUrl': '',
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              await image.readAsBytes(),
              filename: image.name,
            ),
          ),
        );
      }

      final response = await ApiService().dio.put(
        '${EndPointsStrings.banksEndPoint}/$id',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error updating bank: $e");
      return false;
    }
  }

  Future<bool> deleteBank(int id) async {
    try {
      await ApiService().getToken();
      final response = await ApiService().dio.delete('${EndPointsStrings.banksEndPoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting bank: $e");
      return false;
    }
  }
}