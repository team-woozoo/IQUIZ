import 'package:dio/dio.dart';
import 'package:iquiz/core/exception/custom_exception.dart';

/// 서버의 code/detail/errors를 보존하되, 비표준 응답은 네트워크 오류로 유지
Exception mapApiError(Exception error) {
  if (error is! DioException) return error;
  if (error.error case final CustomException cause) return cause;
  final dynamic data = error.response?.data;
  if (data is Map<String, dynamic> &&
      data['code'] is String &&
      data['detail'] is String) {
    try {
      return CustomException.fromJson(data);
    } on Object {
      return error;
    }
  }
  return error;
}
