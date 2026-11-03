import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../models/employee.dart';

/// Used for both "Add" (employee == null) and "Edit".
class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;
  const EmployeeFormPage({super.key, this.employee});
  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final c = Get.find<EmployeeController>();
  late final _first = TextEditingController(text: widget.employee?.firstName);
  late final _last = TextEditingController(text: widget.employee?.lastName);
  late final _email = TextEditingController(text: widget.employee?.email);
  late final _phone = TextEditingController(text: widget.employee?.phone);
  late final _position = TextEditingController(text: widget.employee?.position);
  late final _dept = TextEditingController(text: widget.employee?.department);

  bool get isEdit => widget.employee != null;

  @override
  void dispose() {
    for (final t in [_first, _last, _email, _phone, _position, _dept]) {
      t.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final e = Employee(
      id: widget.employee?.id ?? 0,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      position: _position.text.trim(),
      department: _dept.text.trim(),
      image: widget.employee?.image ?? '',
    );
    final ok = await c.save(e, isEdit: isEdit);
    if (ok && mounted) Navigator.of(context).pop(); // fixed: was Get.back()
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {String? Function(String?)? validator, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator ?? (v) => _required(v, label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Employee' : 'Add Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field(_first, 'First name', Icons.person),
            _field(_last, 'Last name', Icons.person_outline),
            _field(_email, 'Email', Icons.email_outlined,
                type: TextInputType.emailAddress, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  return GetUtils.isEmail(v.trim()) ? null : 'Enter a valid email';
                }),
            _field(_phone, 'Phone', Icons.phone_outlined,
                type: TextInputType.phone, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  return v.replaceAll(RegExp(r'[^0-9]'), '').length >= 8
                      ? null
                      : 'Enter at least 8 digits';
                }),
            _field(_position, 'Position', Icons.work_outline),
            _field(_dept, 'Department', Icons.apartment),
            const SizedBox(height: 8),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: c.isSaving.value ? null : _submit,
                child: c.isSaving.value
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit ? 'Update' : 'Save'),
              ),
            )),
          ]),
        ),
      ),
    );
  }
}