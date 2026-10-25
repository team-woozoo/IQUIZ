import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';

const authLoginColor = Color(0xFF9055CF);
const authDisabledColor = Color(0xFFF4EAFE);
const _authHintColor = Color(0xFFA5A5AF);

String authErrorMessage(Exception error) => switch (error) {
  CustomException(:final detail) => detail,
  DioException(
    type: DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.connectionError,
  ) =>
    '네트워크 연결을 확인하고 다시 시도해 주세요.',
  _ => '요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.',
};

String? authFieldError(Exception? error, String field) {
  if (error is! CustomException) return null;
  for (final item in error.errors) {
    if (item.field == field) return item.message;
  }
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '이메일을 입력해 주세요.';
  if (email.length > 255 ||
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return '이메일 형식을 확인해 주세요.';
  }
  return null;
}

/// 로그인·회원가입 공통 입력칸. 레이블은 입력창 위에 고정
class AuthTextField extends HookWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.enabled = true,
    this.password = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.errorText,
    this.helperText,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onFieldSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool enabled;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final String? helperText;
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final value = useValueListenable(controller).text;
    final obscure = useState(true);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    Widget action(String tooltip, String asset, VoidCallback onPressed) =>
        IconButton(
          tooltip: tooltip,
          onPressed: enabled ? onPressed : null,
          constraints: const BoxConstraints.tightFor(width: 38, height: 48),
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(asset),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyle.medium(14, 20.3)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: password && obscure.value,
          autocorrect: !password && keyboardType != TextInputType.emailAddress,
          enableSuggestions: !password,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          errorBuilder: (_, message) =>
              _AuthFieldMessage(message, color: AppColor.danger),
          autovalidateMode: autovalidateMode,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          cursorColor: AppColor.brandColor,
          style: AppTextStyle.reqular(16, 22.4),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColor.white,
            hintText: hintText,
            hintStyle: AppTextStyle.reqular(
              16,
              22.4,
            ).copyWith(color: _authHintColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: border(AppColor.divider),
            enabledBorder: border(AppColor.divider),
            disabledBorder: border(AppColor.divider),
            focusedBorder: border(AppColor.brandColor),
            errorBorder: border(AppColor.danger),
            focusedErrorBorder: border(AppColor.danger),
            error: errorText == null
                ? null
                : _AuthFieldMessage(errorText!, color: AppColor.danger),
            helper: helperText == null
                ? null
                : _AuthFieldMessage(helperText!, color: AppColor.success),
            suffixIconConstraints: const BoxConstraints(minHeight: 52),
            suffixIcon: password || value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (password)
                          action(
                            obscure.value ? '비밀번호 표시' : '비밀번호 숨기기',
                            obscure.value
                                ? 'assets/icons/auth_visibility_off.svg'
                                : 'assets/icons/auth_visibility_on.svg',
                            () => obscure.value = !obscure.value,
                          ),
                        if (value.isNotEmpty)
                          action(
                            '$label 지우기',
                            'assets/icons/auth_clear.svg',
                            () {
                              controller.clear();
                              onChanged?.call('');
                            },
                          ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _AuthFieldMessage extends StatelessWidget {
  const _AuthFieldMessage(this.message, {required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Transform.translate(
      offset: const Offset(-16, 0),
      child: Text(
        message,
        style: AppTextStyle.reqular(14, 19.6).copyWith(color: color),
      ),
    ),
  );
}

/// 상단부터 흐르는 폼으로 키보드와 큰 글씨에서도 스크롤할 수 있음
class AuthForm extends StatelessWidget {
  const AuthForm({super.key, this.showWordmark = false, required this.child});
  final bool showWordmark;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 452),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showWordmark) ...[
              Center(
                child: SvgPicture.asset(
                  'assets/icons/auth_wordmark.svg',
                  semanticsLabel: '아이퀴즈',
                ),
              ),
              const SizedBox(height: 31),
            ],
            child,
          ],
        ),
      ),
    ),
  );
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColor.brandColor,
    this.busy = false,
    this.textStyle,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool busy;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: color,
      disabledBackgroundColor: busy ? color : authDisabledColor,
      foregroundColor: AppColor.white,
      disabledForegroundColor: AppColor.white,
      minimumSize: const Size.fromHeight(52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textStyle ?? AppTextStyle.btn1,
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}

class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.error, {super.key});
  final Exception? error;

  @override
  Widget build(BuildContext context) => error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            liveRegion: true,
            child: Text(
              authErrorMessage(error!),
              style: AppTextStyle.reqular(
                14,
                20.3,
              ).copyWith(color: AppColor.danger),
            ),
          ),
        );
}
