import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/presentation/pages/home/home_page.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/profile/providers/my_cognitive_type_scores_provider.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/widgets/base_app_bar.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'widgets/profile_app_bar.p.dart';
part 'widgets/profile_learning_analysis.p.dart';
part 'widgets/profile_score_chart.p.dart';
part 'widgets/profile_weak_concepts_sheet.p.dart';

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  @override
  bool get wrapWithSafeArea => false;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      const _ProfileAppBar();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userAuthProvider).user;
    final signingOut = useState(false);

    Future<void> signOut() async {
      if (signingOut.value) return;
      signingOut.value = true;
      try {
        final result = await ref.read(userAuthProvider.notifier).signOut();
        if (!context.mounted) return;
        result.fold(
          onSuccess: (_) {},
          onFailure: (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('인증 정보 삭제에 실패했습니다. 다시 시도해 주세요.')),
          ),
        );
      } finally {
        if (context.mounted) signingOut.value = false;
      }
    }

    Future<void> refresh() async {
      try {
        await Future.wait<Object?>([
          ref.refresh(myCognitiveTypeScoresProvider.future),
          ref.refresh(myWeakConceptsProvider.future),
        ]);
      } catch (_) {
        // 각 영역에서 오류와 재시도 버튼을 표시
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          color: AppColor.brandColor,
          onRefresh: refresh,
          child: ListView(
            key: const PageStorageKey('profile_content'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nickname ?? '학습자',
                            style: AppTextStyle.medium(16, 22.4),
                          ),
                          const SizedBox(height: 4),
                          if (user != null)
                            Text(
                              user.email,
                              style: AppTextStyle.reqular(
                                14,
                                20.3,
                              ).copyWith(color: AppColor.secondaryText),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: signingOut.value ? null : signOut,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.dark,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(49, 44),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: AppTextStyle.medium(14, 19.6),
                      ),
                      child: signingOut.value
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('로그아웃'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProfileLearningAnalysis(nickname: user?.nickname ?? '학습자'),
            ],
          ),
        ),
      ),
    );
  }
}
