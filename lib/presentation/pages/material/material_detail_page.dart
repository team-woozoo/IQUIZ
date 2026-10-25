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
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/material_concept_state.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_score_summary.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';

part 'material_detail_state.dart';
part 'material_detail_event.dart';
part 'widgets/material_detail_toolbar.p.dart';
part 'widgets/material_detail_tabs.p.dart';
part 'widgets/material_summary.p.dart';
part 'widgets/material_concept_list.p.dart';
part 'widgets/material_history_list.p.dart';
part 'widgets/material_message.p.dart';
part 'widgets/material_play_action.p.dart';
part 'widgets/material_quiz_selection_sheet.p.dart';

class MaterialDetailPage extends BasePage
    with MaterialDetailState, MaterialDetailEvent {
  const MaterialDetailPage({super.key, required this.materialId});

  final int materialId;

  @override
  bool get setBotomSafeArea => false;

  @override
  Color get systemNavigationBarColor => AppColor.lightTransparent;

  @override
  bool get systemNavigationBarContrastEnforced => false;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final tab = useState(0);
    final openingQuiz = useState(false);
    final material = ref.watch(myMaterialProvider(materialId: materialId));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            _MaterialDetailToolbar(
              title: material.asData?.value?.title ?? '자료 상세',
              onBack: () => onBackTapped(context),
            ),
            Expanded(
              child: material.when(
                skipLoadingOnReload: false,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _MaterialMessage(
                  message: materialError(error),
                  onRetry: () => ref.invalidate(
                    myMaterialProvider(materialId: materialId),
                  ),
                ),
                data: (item) => item == null
                    ? const _MaterialMessage(message: '로그인 후 자료를 확인해 주세요.')
                    : Stack(
                        children: [
                          RefreshIndicator(
                            color: AppColor.brandColor,
                            onRefresh: () => onRefresh(ref, materialId),
                            child: CustomScrollView(
                              key: PageStorageKey(
                                'material_${materialId}_${tab.value}',
                              ),
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 24,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _MaterialSummary(material: item),
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    15,
                                    0,
                                    15,
                                    24,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _MaterialDetailTabs(
                                      selected: tab.value,
                                      onSelected: (value) => tab.value = value,
                                    ),
                                  ),
                                ),
                                if (item.generating)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        16,
                                      ),
                                      child: Text(
                                        '문제 만드는 중...',
                                        style: AppTextStyle.body2.copyWith(
                                          color: AppColor.brandColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (tab.value == 0)
                                  _MaterialConceptList(materialId: materialId)
                                else
                                  _MaterialHistoryList(materialId: materialId),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height:
                                        BaseBottomNavigationBar.overlayHeight +
                                        16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _MaterialPlayAction(
                              busy: openingQuiz.value,
                              onPressed: () =>
                                  onPlayTapped(ref, item, openingQuiz),
                              onGenerate: () => onGenerateTapped(context, item),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onResumed(WidgetRef ref) {
    ref.invalidate(myMaterialsProvider);
    ref.invalidate(myMaterialProvider(materialId: materialId));
    ref.invalidate(myMaterialConceptsProvider(materialId: materialId));
    ref.invalidate(materialQuizzesProvider(materialId: materialId));
  }
}
