part of '../sign_up_page.dart';

class _SignUpActions extends HookConsumerWidget with SignUpEvent {
  const _SignUpActions({required this.form});
  final SignUpFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = useValueListenable(form.nickname).text;
    final email = useValueListenable(form.email).text;
    final password = useValueListenable(form.password).text;
    final confirmation = useValueListenable(form.confirmation).text;
    final valid =
        validateNickname(nickname) == null &&
        validateEmail(email) == null &&
        validatePassword(password) == null &&
        validateConfirmation(form, confirmation) == null;
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 452),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: AuthSubmitButton(
              label: form.busy.value ? '가입 중...' : '가입하기',
              busy: form.busy.value,
              onPressed: form.busy.value || !valid
                  ? null
                  : () => onSubmit(ref, form),
            ),
          ),
        ),
      ),
    );
  }
}
