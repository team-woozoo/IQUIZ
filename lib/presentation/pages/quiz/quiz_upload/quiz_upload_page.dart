import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/presentation/pages/main/main_navigation.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_generation_state.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_upload_process.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/services/quiz_pdf_preview.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_toolbar.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';

part 'quiz_upload_state.dart';
part 'quiz_upload_event.dart';
part 'widgets/quiz_generation_header.p.dart';
part 'widgets/quiz_generation_options.p.dart';
part 'widgets/quiz_upload_actions.p.dart';
part 'widgets/quiz_option_selector.p.dart';
part 'widgets/quiz_scope_selector.p.dart';
part 'widgets/quiz_generation_progress.p.dart';

class QuizUploadPage extends BasePage with QuizUploadState, QuizUploadEvent {
  const QuizUploadPage({
    super.key,
    this.materialId,
    this.materialTitle,
    this.conceptId,
    this.conceptName,
  });

  final int? materialId;
  final String? materialTitle;
  final int? conceptId;
  final String? conceptName;

  @override
  bool get setBotomSafeArea => false;

  // @override
  // bool get wrapWithSafeArea => false;

  // @override
  // bool get extendBody => true;

  @override
  Color get systemNavigationBarColor => AppColor.lightTransparent;

  @override
  bool get systemNavigationBarContrastEnforced => false;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final form = useUploadState();
    final screen = useState(_UploadScreen.main);
    final generation = generationState(
      ref,
      form.request.value,
      materialId: materialId,
      materialTitle: materialTitle,
      conceptId: conceptId,
      conceptName: conceptName,
    );
    void back() {
      if (screen.value != _UploadScreen.main) {
        screen.value = _UploadScreen.main;
      } else if (context.canPop()) {
        context.pop();
      } else {
        onHomeTapped(context);
      }
    }

    final generating = form.request.value != null;
    return PopScope(
      canPop: screen.value == _UploadScreen.main,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) screen.value = _UploadScreen.main;
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              QuizToolbar(onBack: back),
              Expanded(
                child: generating
                    ? _QuizGenerationProgress(
                        generation: generation,
                        onRetry: () => onRetryUpload(form),
                        onPlay: generation.quizId == null
                            ? null
                            : () => onQuizTapped(
                                context,
                                generation.quizId!,
                                materialId: materialId,
                                materialTitle: conceptName ?? materialTitle,
                                conceptId: conceptId,
                              ),
                      )
                    : switch (screen.value) {
                        _UploadScreen.main => _QuizGenerationOptions(
                          form: form,
                          materialId: materialId,
                          materialTitle: materialTitle,
                          conceptId: conceptId,
                          conceptName: conceptName,
                          busy: isBusy(form, generation),
                          onSelectPdf: () => onSelectPdf(ref, form, generation),
                          onOpen: (value) => screen.value = value,
                          onUpload: () => onUpload(
                            form,
                            generation,
                            materialId: materialId,
                            conceptId: conceptId,
                          ),
                        ),
                        _UploadScreen.format => _QuizFormatSelector(
                          initial: form.format.value,
                          onConfirm: (value) {
                            form.format.value = value;
                            screen.value = _UploadScreen.main;
                          },
                        ),
                        _UploadScreen.difficulty => _QuizDifficultySelector(
                          initial: form.difficulty.value,
                          onConfirm: (value) {
                            form.difficulty.value = value;
                            screen.value = _UploadScreen.main;
                          },
                        ),
                        _UploadScreen.scope => _QuizScopeSelector(
                          pdf: form.selectedPdf.value,
                          count: form.questionCount.value,
                          pages: form.pages.value,
                          onConfirm: (count, pages) {
                            form.questionCount.value = count;
                            form.pages.value = pages;
                            screen.value = _UploadScreen.main;
                          },
                        ),
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
