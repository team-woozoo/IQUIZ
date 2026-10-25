import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/providers/quiz/quiz_generation_activity_provider.dart';
import 'package:iquiz/presentation/widgets/base_app_bar.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'home_state.dart';
part 'home_event.dart';
part 'widgets/home_app_bar.p.dart';
part 'widgets/home_list_message.p.dart';
part 'widgets/home_search_sheet.p.dart';
part 'widgets/recent_material_list.p.dart';
part 'widgets/recent_material_tile.p.dart';
part 'widgets/recent_material_content.p.dart';
part 'widgets/generating_material_list.p.dart';
part 'widgets/review_recommendation_card.p.dart';
part 'widgets/review_book_cover.p.dart';
part 'widgets/review_recommendation_content.p.dart';

class HomePage extends BasePage with HomeEvent {
  const HomePage({super.key});

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      const _HomeAppBar();

  @override
  bool get wrapWithSafeArea => false;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          color: AppColor.brandColor,
          onRefresh: () => onRefresh(ref),
          child: CustomScrollView(
            key: const PageStorageKey('home_quizzes'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _ReviewRecommendationCard()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 31, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Text('최근 자료', style: AppTextStyle.title3),
                ),
              ),
              const _GeneratingMaterialList(),
              const _RecentMaterialList(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
