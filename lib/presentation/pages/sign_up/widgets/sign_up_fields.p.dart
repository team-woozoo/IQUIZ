part of '../sign_up_page.dart';

class _SignUpFields extends HookConsumerWidget with SignUpEvent {
  const _SignUpFields({required this.form});
  final SignUpFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = useValueListenable(form.nickname).text;
    final email = useValueListenable(form.email).text;
    final password = useValueListenable(form.password).text;
    // 비밀번호를 바꿔도 확인란의 일치 여부를 다시 검증
    useValueListenable(form.confirmation);
    final passwordValid = validatePassword(password) == null;
    final mixedPassword =
        RegExp('[a-zA-Z]').hasMatch(password) &&
        RegExp('[0-9]').hasMatch(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: form.nickname,
          label: '닉네임',
          hintText: '닉네임을 입력해주세요',
          enabled: !form.busy.value,
          autofillHints: const [AutofillHints.nickname],
          errorText: authFieldError(form.error.value, 'nickname'),
          helperText:
              nickname.trim().isNotEmpty && validateNickname(nickname) == null
              ? '사용할 수 있는 닉네임이에요'
              : null,
          validator: validateNickname,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => form.error.value = null,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: form.email,
          label: '이메일',
          hintText: '이메일을 입력해주세요',
          enabled: !form.busy.value,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          errorText: authFieldError(form.error.value, 'email'),
          helperText: email.isNotEmpty && validateEmail(email) == null
              ? '사용할 수 있는 이메일이에요'
              : null,
          validator: validateEmail,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => form.error.value = null,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: form.password,
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요',
          enabled: !form.busy.value,
          password: true,
          autofillHints: const [AutofillHints.newPassword],
          errorText: authFieldError(form.error.value, 'password'),
          helperText: passwordValid
              ? mixedPassword
                    ? '8자 이상, 영문과 숫자를 섞어 만들었어요'
                    : '8자 이상으로 입력했어요'
              : null,
          validator: validatePassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => form.error.value = null,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: form.confirmation,
          label: '비밀번호 확인',
          hintText: '비밀번호를 다시 입력해주세요',
          enabled: !form.busy.value,
          password: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(ref, form),
          validator: (value) => validateConfirmation(form, value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => form.error.value = null,
        ),
      ],
    );
  }
}
