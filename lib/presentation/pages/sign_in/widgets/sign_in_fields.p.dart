part of '../sign_in_page.dart';

class _SignInFields extends ConsumerWidget with SignInEvent {
  const _SignInFields({required this.form});
  final SignInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AuthTextField(
        controller: form.emailController,
        label: '이메일',
        hintText: '이메일을 입력해주세요',
        enabled: !form.busy.value,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.username],
        errorText: authFieldError(form.error.value, 'email'),
        validator: validateEmail,
        onChanged: (_) => form.error.value = null,
      ),
      const SizedBox(height: 20),
      AuthTextField(
        controller: form.passwordController,
        label: '비밀번호',
        hintText: '비밀번호를 입력해주세요',
        enabled: !form.busy.value,
        password: true,
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => onSubmit(ref, form),
        errorText: authFieldError(form.error.value, 'password'),
        validator: validatePassword,
        onChanged: (_) => form.error.value = null,
      ),
    ],
  );
}
