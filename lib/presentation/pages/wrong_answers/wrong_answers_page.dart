import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/my_wrong_answers_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'wrong_answers_event.dart';
part 'widgets/wrong_answer_tile.p.dart';
part 'widgets/wrong_answer_filters.p.dart';

class WrongAnswersPage extends BasePage with WrongAnswersEvent {
  const WrongAnswersPage({super.key});

  @override
  bool get wrapWithSafeArea => false;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(myWrongAnswersProvider);
    final materials = ref.watch(myMaterialsProvider);
    final availableMaterials = <int, String>{
      for (final material
          in materials.asData?.value ?? const <StudyMaterialEntity>[])
        material.materialId: material.title,
      for (final item in answers.asData?.value ?? const <WrongAnswerEntity>[])
        item.materialId: item.materialTitle,
    };
    final materialId = useState<int?>(null);
    final searchOpen = useState(false);
    final search = useTextEditingController();
    final query = useValueListenable(search).text.trim().toLowerCase();
    final opening = useState(false);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('오답노트', style: AppTextStyle.semiBold(24, 36.4)),
                  ),
                  IconButton(
                    tooltip: '오답 검색',
                    constraints: const BoxConstraints.tightFor(
                      width: 56,
                      height: 56,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      searchOpen.value = !searchOpen.value;
                      if (!searchOpen.value) search.clear();
                    },
                    icon: SvgPicture.asset('assets/icons/note_search.svg'),
                  ),
                  IconButton(
                    tooltip: '학습 자료 업로드',
                    constraints: const BoxConstraints.tightFor(
                      width: 56,
                      height: 56,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => const UploadRoute().push<void>(context),
                    icon: SvgPicture.asset('assets/icons/note_add.svg'),
                  ),
                ],
              ),
            ),
            // if (searchOpen.value)
            //   Padding(
            //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            //     child: TextField(
            //       key: const ValueKey('wrong_answer_search'),
            //       controller: search,
            //       autofocus: true,
            //       style: AppTextStyle.reqular(15, 21.75),
            //       decoration: InputDecoration(
            //         hintText: '문제, 개념, 자료 검색',
            //         suffixIcon: IconButton(
            //           tooltip: '검색어 지우기',
            //           onPressed: search.clear,
            //           icon: const Icon(Icons.close, size: 20),
            //         ),
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 16),
            _WrongAnswerFilters(
              materials: availableMaterials,
              materialId: materialId.value,
              onSelected: (id) => materialId.value = id,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.brandColor,
                onRefresh: () => onRefresh(ref),
                child: answers.when(
                  skipLoadingOnRefresh: false,
                  loading: () =>
                      _message(child: const CircularProgressIndicator()),
                  error: (error, _) => _message(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error is CustomException
                              ? error.detail
                              : '오답노트를 불러오지 못했어요.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.medium(
                            16,
                            22.4,
                          ).copyWith(color: AppColor.secondaryText),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(myWrongAnswersProvider),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                  data: (items) {
                    final activeId =
                        availableMaterials.containsKey(materialId.value)
                        ? materialId.value
                        : null;
                    final visible = items
                        .where(
                          (item) =>
                              (activeId == null ||
                                  item.materialId == activeId) &&
                              (query.isEmpty ||
                                  '${item.content} ${item.conceptName} ${item.materialTitle}'
                                      .toLowerCase()
                                      .contains(query)),
                        )
                        .toList();
                    if (visible.isEmpty) {
                      return _message(
                        child: Text(
                          query.isEmpty ? '학습 데이터가 더 필요해요' : '검색 결과가 없어요',
                          style: AppTextStyle.medium(
                            16,
                            22.4,
                          ).copyWith(color: AppColor.disabledText),
                        ),
                      );
                    }
                    return ListView.builder(
                      key: const PageStorageKey('wrong_answers'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: visible.length,
                      itemBuilder: (context, index) => _WrongAnswerTile(
                        item: visible[index],
                        onTap: () =>
                            onQuestionTapped(ref, visible[index], opening),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message({required Widget child}) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Center(child: child),
      ),
    ],
  );
}
