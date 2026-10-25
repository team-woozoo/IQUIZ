import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/core/helper/future_extension.dart';

void main() {
  test('단일 항목 변환 실패 시 원래 예외를 그대로 전달한다', () async {
    const error = FormatException('잘못된 단일 항목');
    final response = Future.value(
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/quizzes/1'),
        data: {'id': 1},
      ),
    );

    final result = response.withSingleConverter<int>(
      fromJson: (_) => throw error,
    );

    await expectLater(result, throwsA(same(error)));
  });

  test('목록 변환 실패 시 원래 예외를 전달하고 이후 항목을 처리하지 않는다', () async {
    final visited = <int>[];
    const error = FormatException('잘못된 목록 항목');
    final response = Future.value(
      Response<List<Map<String, dynamic>>>(
        requestOptions: RequestOptions(path: '/quizzes'),
        data: [
          {'id': 1},
          {'id': 2},
          {'id': 3},
        ],
      ),
    );

    final result = response.withListConverter<int>(
      fromJson: (json) {
        final id = json['id'] as int;
        visited.add(id);
        if (id == 2) throw error;
        return id;
      },
    );

    await expectLater(result, throwsA(same(error)));
    expect(visited, [1, 2]);
  });
}
