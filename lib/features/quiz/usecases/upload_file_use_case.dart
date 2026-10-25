import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class UploadFileUseCase {
  const UploadFileUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<int>> call({
    required List<int> fileBytes,
    required String fileName,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) {
    return repository.uploadFile(
      fileBytes: fileBytes,
      fileName: fileName,
      options: options,
      title: title,
    );
  }
}
