// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $wrongAnswersRoute,
  $signInRoute,
  $signUpRoute,
  $splashRoute,
  $homeRoute,
  $materialDetailRoute,
  $noticeRoute,
  $uploadRoute,
];

RouteBase get $wrongAnswersRoute => GoRouteData.$route(
  path: '/wrong-answers',
  name: 'wrongAnswers',
  hasOverriddenOnExit: false,
  factory: $WrongAnswersRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: ':questionId',
      name: 'wrongAnswerReview',
      hasOverriddenOnExit: false,
      factory: $WrongAnswerReviewRoute._fromState,
    ),
  ],
);

mixin $WrongAnswersRoute on GoRouteData {
  static WrongAnswersRoute _fromState(GoRouterState state) =>
      const WrongAnswersRoute();

  @override
  String get location => GoRouteData.$location('/wrong-answers');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WrongAnswerReviewRoute on GoRouteData {
  static WrongAnswerReviewRoute _fromState(GoRouterState state) =>
      WrongAnswerReviewRoute(
        int.parse(state.pathParameters['questionId']!),
        $extra: state.extra as WrongAnswerEntity?,
      );

  WrongAnswerReviewRoute get _self => this as WrongAnswerReviewRoute;

  @override
  String get location => GoRouteData.$location(
    '/wrong-answers/${Uri.encodeComponent(_self.questionId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  name: 'signIn',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => SignInRoute(
    email: state.uri.queryParameters['email'],
    from: state.uri.queryParameters['from'],
  );

  SignInRoute get _self => this as SignInRoute;

  @override
  String get location => GoRouteData.$location(
    '/sign-in',
    queryParams: {
      if (_self.email != null) 'email': _self.email,
      if (_self.from != null) 'from': _self.from,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
  path: '/sign-up',
  name: 'signUp',
  hasOverriddenOnExit: false,
  factory: $SignUpRoute._fromState,
);

mixin $SignUpRoute on GoRouteData {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  name: 'splash',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
  path: '/home',
  name: 'home',
  hasOverriddenOnExit: false,
  factory: $HomeRoute._fromState,
);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $materialDetailRoute => GoRouteData.$route(
  path: '/materials/:materialId',
  name: 'materialDetail',
  hasOverriddenOnExit: false,
  factory: $MaterialDetailRoute._fromState,
);

mixin $MaterialDetailRoute on GoRouteData {
  static MaterialDetailRoute _fromState(GoRouterState state) =>
      MaterialDetailRoute(int.parse(state.pathParameters['materialId']!));

  MaterialDetailRoute get _self => this as MaterialDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/materials/${Uri.encodeComponent(_self.materialId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $noticeRoute => GoRouteData.$route(
  path: '/notice',
  name: 'notice',
  hasOverriddenOnExit: false,
  factory: $NoticeRoute._fromState,
);

mixin $NoticeRoute on GoRouteData {
  static NoticeRoute _fromState(GoRouterState state) => const NoticeRoute();

  @override
  String get location => GoRouteData.$location('/notice');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $uploadRoute => GoRouteData.$route(
  path: '/upload',
  name: 'upload',
  hasOverriddenOnExit: false,
  factory: $UploadRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'quiz/:quizId',
      name: 'quiz',
      hasOverriddenOnExit: false,
      factory: $QuizRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'result',
          name: 'quizResult',
          hasOverriddenOnExit: false,
          factory: $QuizResultRoute._fromState,
        ),
      ],
    ),
  ],
);

mixin $UploadRoute on GoRouteData {
  static UploadRoute _fromState(GoRouterState state) => UploadRoute(
    materialId: _$convertMapValue(
      'material-id',
      state.uri.queryParameters,
      int.tryParse,
    ),
    materialTitle: state.uri.queryParameters['material-title'],
    conceptId: _$convertMapValue(
      'concept-id',
      state.uri.queryParameters,
      int.tryParse,
    ),
    conceptName: state.uri.queryParameters['concept-name'],
  );

  UploadRoute get _self => this as UploadRoute;

  @override
  String get location => GoRouteData.$location(
    '/upload',
    queryParams: {
      if (_self.materialId != null) 'material-id': _self.materialId!.toString(),
      if (_self.materialTitle != null) 'material-title': _self.materialTitle,
      if (_self.conceptId != null) 'concept-id': _self.conceptId!.toString(),
      if (_self.conceptName != null) 'concept-name': _self.conceptName,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizRoute on GoRouteData {
  static QuizRoute _fromState(GoRouterState state) => QuizRoute(
    int.parse(state.pathParameters['quizId']!),
    title: state.uri.queryParameters['title'],
  );

  QuizRoute get _self => this as QuizRoute;

  @override
  String get location => GoRouteData.$location(
    '/upload/quiz/${Uri.encodeComponent(_self.quizId.toString())}',
    queryParams: {if (_self.title != null) 'title': _self.title},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizResultRoute on GoRouteData {
  static QuizResultRoute _fromState(GoRouterState state) => QuizResultRoute(
    int.parse(state.pathParameters['quizId']!),
    $extra: state.extra as QuizResultRouteArg?,
  );

  QuizResultRoute get _self => this as QuizResultRoute;

  @override
  String get location => GoRouteData.$location(
    '/upload/quiz/${Uri.encodeComponent(_self.quizId.toString())}/result',
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
