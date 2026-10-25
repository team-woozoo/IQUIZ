import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/widgets/auth/auth_form.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'sign_in_state.dart';
part 'sign_in_event.dart';
part 'widgets/sign_in_fields.p.dart';
part 'widgets/sign_in_actions.p.dart';

class SignInPage extends BasePage with SignInState {
  const SignInPage({super.key, this.email});
  final String? email;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: SizedBox(height: 56),
      );

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final form = useFormState(email: email);
    return AuthForm(
      showWordmark: true,
      child: AutofillGroup(
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SignInFields(form: form),
              const SizedBox(height: 31),
              _SignInActions(form: form),
            ],
          ),
        ),
      ),
    );
  }
}
