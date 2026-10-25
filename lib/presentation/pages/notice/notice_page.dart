import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/logger/log.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:iquiz/presentation/providers/config/app_config_provier.dart';
import 'package:iquiz/presentation/widgets/base_app_bar.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:iquiz/presentation/widgets/button/animated_icon_button.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';

part 'notice_state.dart';
part 'notice_event.dart';
part 'widgets/notice_header.p.dart';
part 'widgets/notice_details.p.dart';
part 'widgets/notice_bottom_navigation.p.dart';

class NoticePage extends BasePage with NoticeState {
  const NoticePage({super.key});

  @override
  bool get wrapWithSafeArea => false;

  @override
  bool get extendBody => true;

  @override
  Color get systemNavigationBarColor => AppColor.lightTransparent;

  @override
  bool get systemNavigationBarContrastEnforced => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return BaseAppBar(
      leading: AnimatedIconButton(
        onTap: () {},
        iconPath: 'assets/icons/arrow_left.svg',
        dimension: 56,
      ),
    );
  }

  @override
  Widget? buildBottomNavigationBar(BuildContext context) {
    return const _NoticeBottomNavigation();
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return configInfo(ref).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('공지 정보를 불러오지 못했습니다.')),
      data: (config) => CustomScrollView(
        slivers: [
          _NoticeHeader(config: config),
          _NoticeDetails(config: config),
        ],
      ),
    );
  }
}
