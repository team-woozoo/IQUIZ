/// API 공통 규약의 에러 응답. 화면 분기는 [code], 사용자 표시는 [detail]을 사용
sealed class CustomException implements Exception {
  final String code;
  final String detail;

  /// 작업 조회의 error 객체에는 HTTP 상태 코드가 없으므로 null일 수 있음
  final int? status;
  final List<FieldValidationError> errors;

  const CustomException(
    this.code,
    this.detail, {
    this.status,
    this.errors = const [],
  });

  /// 기존 메시지 접근 방식과의 호환성을 위해 제공
  String get message => detail;

  /// Problem Details 본문 또는 작업 조회 응답의 error 객체를 변환
  /// 서버의 code와 detail을 그대로 보존하며 HTTP 상태로 예외 종류를 추측하지 않음
  factory CustomException.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String;
    final detail = json['detail'] as String;
    final status = json['status'] as int?;
    final errors = List<FieldValidationError>.unmodifiable(
      (json['errors'] as List<dynamic>? ?? const []).map(
        (error) => FieldValidationError.fromJson(error as Map<String, dynamic>),
      ),
    );

    return switch (code) {
      'INVALID_INPUT' => InvalidInputException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'UNSUPPORTED_FILE_TYPE' => UnsupportedFileTypeException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'FILE_TOO_LARGE' => FileTooLargeException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'TOO_MANY_PAGES' => TooManyPagesException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'EXTRACTION_FAILED' => ExtractionFailedException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'MATERIAL_NOT_FOUND' => MaterialNotFoundException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'CONCEPT_NOT_FOUND' => ConceptNotFoundException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'GENERATION_IN_PROGRESS' => GenerationInProgressException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'DAILY_GENERATION_LIMIT_EXCEEDED' =>
        DailyGenerationLimitExceededException(
          detail: detail,
          status: status,
          errors: errors,
        ),
      'QUIZ_NOT_FOUND' => QuizNotFoundException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'JOB_NOT_FOUND' => JobNotFoundException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'INVALID_SUBMISSION' => InvalidSubmissionException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'UNAUTHORIZED' => UnAuthorizedException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'INVALID_CREDENTIALS' => InvalidCredentialException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'EMAIL_ALREADY_EXISTS' => EmailAlreadyExistsException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'INVALID_REFRESH_TOKEN' => InvalidRefreshTokenException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'INTERNAL_ERROR' => InternalErrorException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'GENERATION_FAILED' => GenerationFailedException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      'NO_VALID_QUESTIONS' => NoValidQuestionsException(
        detail: detail,
        status: status,
        errors: errors,
      ),
      _ => UnknownApiException(
        code: code,
        detail: detail,
        status: status,
        errors: errors,
      ),
    };
  }

  @override
  String toString() =>
      '$runtimeType(code: $code, status: $status, detail: $detail)';
}

/// INVALID_INPUT 응답의 필드별 검증 실패 사유
class FieldValidationError {
  final String field;
  final String message;

  const FieldValidationError({required this.field, required this.message});

  factory FieldValidationError.fromJson(Map<String, dynamic> json) {
    return FieldValidationError(
      field: json['field'] as String,
      message: json['message'] as String,
    );
  }
}

class InvalidInputException extends CustomException {
  const InvalidInputException({
    String detail = '입력값이 올바르지 않습니다.',
    super.status = 400,
    super.errors,
  }) : super('INVALID_INPUT', detail);
}

class UnsupportedFileTypeException extends CustomException {
  const UnsupportedFileTypeException({
    String detail = 'PDF 파일만 업로드할 수 있습니다.',
    super.status = 400,
    super.errors,
  }) : super('UNSUPPORTED_FILE_TYPE', detail);
}

class FileTooLargeException extends CustomException {
  const FileTooLargeException({
    String detail = '파일 크기 상한을 초과했습니다.',
    super.status = 413,
    super.errors,
  }) : super('FILE_TOO_LARGE', detail);
}

class TooManyPagesException extends CustomException {
  const TooManyPagesException({
    String detail = '페이지 수 상한을 초과했습니다.',
    super.status = 400,
    super.errors,
  }) : super('TOO_MANY_PAGES', detail);
}

class ExtractionFailedException extends CustomException {
  const ExtractionFailedException({
    String detail = '글자를 읽을 수 없는 파일입니다.',
    super.status = 422,
    super.errors,
  }) : super('EXTRACTION_FAILED', detail);
}

class MaterialNotFoundException extends CustomException {
  const MaterialNotFoundException({
    String detail = '자료를 찾을 수 없습니다.',
    super.status = 404,
    super.errors,
  }) : super('MATERIAL_NOT_FOUND', detail);
}

class QuizNotFoundException extends CustomException {
  const QuizNotFoundException({
    String detail = '퀴즈를 찾을 수 없습니다.',
    super.status = 404,
    super.errors,
  }) : super('QUIZ_NOT_FOUND', detail);
}

class JobNotFoundException extends CustomException {
  const JobNotFoundException({
    String detail = '작업을 찾을 수 없습니다.',
    super.status = 404,
    super.errors,
  }) : super('JOB_NOT_FOUND', detail);
}

class InvalidSubmissionException extends CustomException {
  const InvalidSubmissionException({
    String detail = '제출한 답안이 올바르지 않습니다.',
    super.status = 400,
    super.errors,
  }) : super('INVALID_SUBMISSION', detail);
}

/// 토큰 재발급 후 원래 요청을 다시 시도해야 하는 인증 오류
class UnAuthorizedException extends CustomException {
  const UnAuthorizedException({
    String detail = '로그인이 필요합니다.',
    super.status = 401,
    super.errors,
  }) : super('UNAUTHORIZED', detail);
}

class InvalidCredentialException extends CustomException {
  const InvalidCredentialException({
    String detail = '이메일 또는 비밀번호가 올바르지 않습니다.',
    super.status = 401,
    super.errors,
  }) : super('INVALID_CREDENTIALS', detail);
}

class EmailAlreadyExistsException extends CustomException {
  const EmailAlreadyExistsException({
    String detail = '이미 가입된 이메일입니다.',
    super.status = 409,
    super.errors,
  }) : super('EMAIL_ALREADY_EXISTS', detail);
}

/// 재발급을 다시 시도하지 않고 로그인 화면으로 이동해야 하는 인증 오류
class InvalidRefreshTokenException extends CustomException {
  const InvalidRefreshTokenException({
    String detail = '다시 로그인해 주세요.',
    super.status = 401,
    super.errors,
  }) : super('INVALID_REFRESH_TOKEN', detail);
}

class InternalErrorException extends CustomException {
  const InternalErrorException({
    String detail = '서버 내부 오류가 발생했습니다.',
    super.status = 500,
    super.errors,
  }) : super('INTERNAL_ERROR', detail);
}

/// HTTP 200인 작업 조회 응답에서도 전달되는 작업 실패 사유
class GenerationFailedException extends CustomException {
  const GenerationFailedException({
    String detail = '퀴즈 생성에 실패했습니다. 다시 시도해 주세요.',
    super.status,
    super.errors,
  }) : super('GENERATION_FAILED', detail);
}

class NoValidQuestionsException extends CustomException {
  const NoValidQuestionsException({
    String detail = '생성된 문제 중 유효한 문제가 없습니다.',
    super.status,
    super.errors,
  }) : super('NO_VALID_QUESTIONS', detail);
}

/// 아직 앱에서 정의하지 않은 서버 코드도 원문을 보존
class UnknownApiException extends CustomException {
  const UnknownApiException({
    required String code,
    required String detail,
    super.status,
    super.errors,
  }) : super(code, detail);
}

class ConceptNotFoundException extends CustomException {
  const ConceptNotFoundException({
    String detail = '개념을 찾을 수 없습니다.',
    super.status = 404,
    super.errors,
  }) : super('CONCEPT_NOT_FOUND', detail);
}

class GenerationInProgressException extends CustomException {
  const GenerationInProgressException({
    String detail = '이미 퀴즈를 생성하고 있습니다.',
    super.status = 409,
    super.errors,
  }) : super('GENERATION_IN_PROGRESS', detail);
}

class DailyGenerationLimitExceededException extends CustomException {
  const DailyGenerationLimitExceededException({
    String detail = '오늘의 퀴즈 생성 횟수를 초과했습니다.',
    super.status = 429,
    super.errors,
  }) : super('DAILY_GENERATION_LIMIT_EXCEEDED', detail);
}
