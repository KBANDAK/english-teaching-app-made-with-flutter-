import '../models/smart_test.dart';

abstract class TestsRepository {
  Future<List<SmartTest>> fetchSmartTests();
}
