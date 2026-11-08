part of 'sign_in_page.dart';

mixin class SignInEvent {
  /// [form]을 검증한 뒤 입력한 계정으로 로그인하고 실패하면 폼의 오류 상태를 갱신
  /// 중복 요청을 차단하며 로그인 성공 시 자동 완성 입력을 확정
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
    } catch (error, stackTrace) {
      Log.e('로그인 요청 처리 실패', error: error, stackTrace: stackTrace);
      if (context.mounted) {
        form.error.value = error is Exception ? error : Exception('로그인 처리 실패');
      }
    } finally {
      if (context.mounted) form.busy.value = false;
    }
  }

  /// [value]에 비밀번호가 입력됐는지 검사하고 오류 문구 또는 null을 반환
  String? validatePassword(String? value) =>
      value == null || value.isEmpty ? '비밀번호를 입력해 주세요.' : null;

  /// 회원가입 화면으로 이동
  void onSwitchAuthTapped(BuildContext context) =>
      const SignUpRoute().go(context);
}
