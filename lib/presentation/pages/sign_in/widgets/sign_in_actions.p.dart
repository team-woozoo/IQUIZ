part of '../sign_in_page.dart';

class _SignInActions extends ConsumerWidget with SignInEvent {
  const _SignInActions({required this.form});
  final SignInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AuthErrorText(form.error.value),
      AuthSubmitButton(
        label: form.busy.value ? '로그인 중...' : '로그인',
        color: authLoginColor,
        textStyle: AppTextStyle.bold(16, 22.4),
        busy: form.busy.value,
        onPressed: form.busy.value ? null : () => onSubmit(ref, form),
      ),
      const SizedBox(height: 16),
      Center(
        child: Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Text(
              '아직 계정이 없으신가요?',
              style: AppTextStyle.reqular(
                14,
                20.3,
              ).copyWith(color: AppColor.secondaryText),
            ),
            TextButton(
              onPressed: form.busy.value
                  ? null
                  : () => onSwitchAuthTapped(context),
              style: TextButton.styleFrom(
                foregroundColor: authLoginColor,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: AppTextStyle.medium(14, 20.3),
              ),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    ],
  );
}
