import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/core/network/api_result.dart';

void main() {
  test('ApiResult Success and Failure behave', () {
    final success = Success<int>(42);
    final failure = Failure<int>(message: 'err', statusCode: 400);

    expect(success.data, equals(42));
    expect(failure.message, equals('err'));
    expect(failure.statusCode, equals(400));
  });
}
