import 'package:dio/dio.dart';
import 'package:iquiz/core/logger/log.dart';

extension FutureExtension on Future<Response> {
  Future<List<T>> withListConverter<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await this;
    final dynamic data = response.data;

    final result = <T>[];

    if (data is! List) {
      throw Exception('Expected List but got ${data.runtimeType}');
    }

    for (final Object? e in data) {
      try {
        result.add(fromJson(e as Map<String, dynamic>));
      } on Exception catch (e) {
        Log.e('ERROR : $e');
        rethrow;
      }
    }

    return result;
  }

  Future<T> withSingleConverter<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await this;
    final dynamic data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Expected Map<String, dynamic> but got ${data.runtimeType}',
      );
    }

    try {
      return fromJson(data);
    } on Exception catch (e) {
      Log.e('ERROR : $e');
      rethrow;
    }
  }
}
