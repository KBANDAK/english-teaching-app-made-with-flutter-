import '../../models/smart_test.dart';
import '../tests_repository.dart';

class MockTestsRepository implements TestsRepository {
  @override
  Future<List<SmartTest>> fetchSmartTests() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      SmartTest(
        id: 1,
        title: "Smart Test 1",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 0,
      ),
      SmartTest(
        id: 2,
        title: "Smart Test 2",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 35,
      ),
      SmartTest(
        id: 3,
        title: "Smart Test 3",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 100,
      ),
      SmartTest(
        id: 4,
        title: "Smart Test 4",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 10,
      ),
      SmartTest(
        id: 5,
        title: "Smart Test 5",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 0,
      ),
      SmartTest(
        id: 6,
        title: "Smart Test 6",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 70,
      ),
      SmartTest(
        id: 7,
        title: "Smart Test 7",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 0,
      ),
      SmartTest(
        id: 8,
        title: "Smart Test 8",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 55,
      ),
      SmartTest(
        id: 9,
        title: "Smart Test 9",
        subtitle: "Full IELTS-style test covering all 4 skills",
        durationMin: 165,
        progress: 0,
      ),
    ];
  }
}
