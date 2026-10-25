import 'dart:async';

import 'package:iquiz/core/logger/log.dart';

extension StreamExtension on Stream<dynamic> {
  Stream<List<T>> withListConverter<T>({
    required T Function(Map<String, dynamic> fromJson) fromJson,
  }) {
    return map((data) {
      final successfulItems = <T>[];
      if (data is! List) {
        Log.f(
          'Stream data is not a List: $data\n'
          'name: withListConverter',
        );
        return successfulItems;
      }

      for (final item in data) {
        try {
          final mapData = item as Map<String, dynamic>;

          final parsedItem = fromJson(mapData);
          successfulItems.add(parsedItem);
        } catch (e) {
          Log.f(
            'Failed to parse item. Error: $e\n'
            'name: withListConverter.fromJson\n'
            'error: $e',
          );
          Log.f(
            'Problematic data: $item'
            'name: withListConverter.data',
          );
        }
      }

      return successfulItems;
    });
  }

  Stream<T> withSingleConverter<T>({
    required T Function(Map<String, dynamic> fromJson) fromJson,
  }) {
    return map((data) {
      if (data is! Map<String, dynamic>) {
        throw FormatException(
          'Map<String, dynamic> 형식이 아님\n'
          '원본 타입: ${data.runtimeType}',
        );
      }

      try {
        return fromJson(data);
      } catch (e) {
        Log.f('Failed to parse item. Error: $e\n');
        rethrow;
      }
    });
  }
}
