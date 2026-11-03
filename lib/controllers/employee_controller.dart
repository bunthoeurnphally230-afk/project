import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api_client.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeController extends GetxController {
  final EmployeeRepository _repo;
  EmployeeController(this._repo);

  final employees = <Employee>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      employees.assignAll(await _repo.getEmployees());
    } catch (e) {
      error.value = ApiClient.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns true on success so the form page can close itself.
  Future<bool> save(Employee e, {required bool isEdit}) async {
    isSaving.value = true;
    try {
      if (isEdit) {
        final updated = await _repo.update(e);
        final i = employees.indexWhere((x) => x.id == e.id);
        if (i != -1) employees[i] = updated;
      } else {
        employees.insert(0, await _repo.create(e));
      }
      _toast('Success', isEdit ? 'Employee updated' : 'Employee added');
      return true;
    } catch (err) {
      _toast('Error', ApiClient.message(err), error: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(Employee e) async {
    try {
      await _repo.delete(e.id);
      employees.removeWhere((x) => x.id == e.id);
      _toast('Deleted', '${e.fullName} was removed');
    } catch (err) {
      _toast('Error', ApiClient.message(err), error: true);
    }
  }

  /// Confirmation dialog before deleting.
  void confirmDelete(Employee e) {
    Get.defaultDialog(
      title: 'Delete employee',
      middleText: 'Are you sure you want to delete ${e.fullName}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Navigator.of(Get.overlayContext!).pop(); // fixed: was Get.back()
        delete(e);
      },
    );
  }

  void _toast(String title, String msg, {bool error = false}) =>
      Get.snackbar(title, msg,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          backgroundColor: error ? Colors.red.shade100 : Colors.green.shade100);
}