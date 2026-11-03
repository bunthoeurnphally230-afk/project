import '../core/api_client.dart';
import '../models/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<Employee> create(Employee e);
  Future<Employee> update(Employee e);
  Future<void> delete(int id);
}

/// NOTE: dummyjson simulates writes (they are not persisted on the server).
/// Records created in this session get ids above [_maxServerId], so we only
/// call the server for real ids and the controller keeps the local list in sync.
class EmployeeRepositoryImpl implements EmployeeRepository {
  static const _maxServerId = 208;
  static int _nextLocalId = 1000; // unique ids for records created locally
  final ApiClient _api;
  EmployeeRepositoryImpl(this._api);

  @override
  Future<List<Employee>> getEmployees() async {
    final res = await _api.dio.get('/users', queryParameters: {'limit': 20});
    return (res.data['users'] as List).map((e) => Employee.fromJson(e)).toList();
  }

  @override
  Future<Employee> create(Employee e) async {
    await _api.dio.post('/users/add', data: e.toJson());
    return e.withId(_nextLocalId++); // fixed: unique id for each new employee
  }

  @override
  Future<Employee> update(Employee e) async {
    if (e.id <= _maxServerId) await _api.dio.put('/users/${e.id}', data: e.toJson());
    return e;
  }

  @override
  Future<void> delete(int id) async {
    if (id <= _maxServerId) await _api.dio.delete('/users/$id');
  }
}