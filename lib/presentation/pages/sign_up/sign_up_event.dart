part of 'sign_up_page.dart';

mixin class SignUpEvent {
  /// [form]을 검증한 뒤 회원가입을 요청하고 실패하면 폼의 오류 상태를 갱신
  /// 중복 요청을 차단하며 성공 시 이메일을 전달해 로그인 화면으로 이동하고 완료를 안내
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
    } catch (error, stackTrace) {
      Log.e('회원가입 요청 처리 실패', error: error, stackTrace: stackTrace);
      if (context.mounted) {
        form.error.value = error is Exception ? error : Exception('회원가입 처리 실패');
      }
    } finally {
      if (context.mounted) form.busy.value = false;
    }
  }

  /// [value]의 닉네임이 비어 있지 않고 공백 제거 후 50자 이내인지 검사
  /// 검증 실패 시 안내 문구를, 통과하면 null을 반환
  String? validateNickname(String? value) =>
      value == null || value.trim().isEmpty
      ? '닉네임을 입력해 주세요.'
      : value.trim().length > 50
      ? '닉네임은 50자 이내로 입력해 주세요.'
      : null;

  /// [value]의 비밀번호가 8~64자인지 검사하고 오류 문구 또는 null을 반환
  String? validatePassword(String? value) => value == null || value.isEmpty
      ? '비밀번호를 입력해 주세요.'
      : value.length < 8 || value.length > 64
      ? '비밀번호는 8~64자로 입력해 주세요.'
      : null;

  /// [value]가 비어 있지 않고 [form]의 비밀번호와 일치하는지 검사
  /// 검증 실패 시 안내 문구를, 일치하면 null을 반환
  String? validateConfirmation(SignUpFormState form, String? value) =>
      value == null || value.isEmpty
      ? '비밀번호를 다시 입력해 주세요.'
      : value != form.password.text
      ? '비밀번호가 서로 달라요'
      : null;

  /// 로그인 화면으로 이동
  void onSwitchAuthTapped(BuildContext context) =>
      const SignInRoute().go(context);
}
