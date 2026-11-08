part of 'sign_in_page.dart';

/// 컨트롤러와 임시 입력 상태는 페이지의 Hook 수명주기에 맞춰 정리
typedef SignInFormState = ({
  GlobalKey<FormState> formKey,
  TextEditingController emailController,
  TextEditingController passwordController,
  ValueNotifier<bool> busy,
  ValueNotifier<Exception?> error,
});

mixin class SignInState {
  /// 초기 [email]과 함께 로그인 폼의 컨트롤러·진행 상태·오류 상태를 생성
  /// build에서 항상 같은 순서로 호출하며 입력 상태는 Hook 수명주기에 맞춰 정리
  SignInFormState useFormState({String? email}) => (
    formKey: useMemoized(GlobalKey<FormState>.new),
    emailController: useTextEditingController(text: email),
    passwordController: useTextEditingController(),
    busy: useState(false),
    error: useState<Exception?>(null),
  );
}
