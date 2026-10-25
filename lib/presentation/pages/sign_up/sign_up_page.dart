import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/presentation/widgets/auth/auth_form.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'sign_up_state.dart';
part 'sign_up_event.dart';
part 'widgets/sign_up_fields.p.dart';
part 'widgets/sign_up_actions.p.dart';

class SignUpPage extends BasePage with SignUpState {
  const SignUpPage({super.key});

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 56,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.white,
        leadingWidth: 56,
        leading: IconButton(
          tooltip: '로그인으로 돌아가기',
          padding: EdgeInsets.zero,
          onPressed: () => const SignInRoute().go(context),
          icon: SvgPicture.asset('assets/icons/material_back.svg'),
        ),
        title: Text('회원가입', style: AppTextStyle.title2),
      );

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final form = useFormState();
    return Column(
      children: [
        Expanded(
          child: AuthForm(
            child: AutofillGroup(
              child: Form(
                key: form.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SignUpFields(form: form),
                    if (form.error.value != null) ...[
                      const SizedBox(height: 20),
                      AuthErrorText(form.error.value),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        _SignUpActions(form: form),
      ],
    );
  }
}
