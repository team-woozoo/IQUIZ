part of 'sign_up_page.dart';

/// 컨트롤러와 임시 입력 상태는 페이지의 Hook 수명주기에 맞춰 정리
typedef SignUpFormState = ({
  GlobalKey<FormState> formKey,
  TextEditingController email,
  TextEditingController nickname,
  TextEditingController password,
  TextEditingController confirmation,
  ValueNotifier<bool> busy,
  ValueNotifier<Exception?> error,
});

mixin class SignUpState {
  /// build에서 항상 같은 순서로 호출
  SignUpFormState useFormState() => (
    formKey: useMemoized(GlobalKey<FormState>.new),
    email: useTextEditingController(),
    nickname: useTextEditingController(),
    password: useTextEditingController(),
    confirmation: useTextEditingController(),
    busy: useState(false),
    error: useState<Exception?>(null),
  );
}
