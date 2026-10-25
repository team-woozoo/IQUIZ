part of 'sign_up_page.dart';

mixin class SignUpEvent {
  Future<void> onSubmit(WidgetRef ref, SignUpFormState form) async {
    final context = ref.context;
    if (form.busy.value) return;
    form.error.value = null;
    if (!(form.formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    form.busy.value = true;
    try {
      final result = await ref.read(signUpUseCaseProvider)(
        email: form.email.text.trim(),
        password: form.password.text,
        nickname: form.nickname.text.trim(),
      );
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) {
          SignInRoute(email: form.email.text.trim()).go(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')),
          );
        },
        onFailure: (failure) => form.error.value = failure,
      );
    } finally {
      if (context.mounted) form.busy.value = false;
    }
  }

  String? validateNickname(String? value) =>
      value == null || value.trim().isEmpty
      ? '닉네임을 입력해 주세요.'
      : value.trim().length > 50
      ? '닉네임은 50자 이내로 입력해 주세요.'
      : null;

  String? validatePassword(String? value) => value == null || value.isEmpty
      ? '비밀번호를 입력해 주세요.'
      : value.length < 8 || value.length > 64
      ? '비밀번호는 8~64자로 입력해 주세요.'
      : null;

  String? validateConfirmation(SignUpFormState form, String? value) =>
      value == null || value.isEmpty
      ? '비밀번호를 다시 입력해 주세요.'
      : value != form.password.text
      ? '비밀번호가 서로 달라요'
      : null;

  void onSwitchAuthTapped(BuildContext context) =>
      const SignInRoute().go(context);
}
