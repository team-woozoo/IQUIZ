part of 'sign_in_page.dart';

mixin class SignInEvent {
  Future<void> onSubmit(WidgetRef ref, SignInFormState form) async {
    final context = ref.context;
    if (form.busy.value) return;
    form.error.value = null;
    if (!(form.formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    form.busy.value = true;
    try {
      final result = await ref
          .read(userAuthProvider.notifier)
          .signIn(
            email: form.emailController.text.trim(),
            password: form.passwordController.text,
          );
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) => TextInput.finishAutofillContext(),
        onFailure: (failure) => form.error.value = failure,
      );
    } finally {
      if (context.mounted) form.busy.value = false;
    }
  }

  String? validatePassword(String? value) =>
      value == null || value.isEmpty ? '비밀번호를 입력해 주세요.' : null;

  void onSwitchAuthTapped(BuildContext context) =>
      const SignUpRoute().go(context);
}
