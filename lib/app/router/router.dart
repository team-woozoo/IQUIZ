import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iquiz/presentation/pages/main/main_page.dart';
import 'package:iquiz/presentation/pages/main/providers/main_bottom_navigation.dart';
import 'package:iquiz/presentation/pages/material/material_detail_page.dart';
import 'package:iquiz/presentation/pages/notice/notice_page.dart';
import 'package:iquiz/presentation/pages/splash/splash_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/quiz_play_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/quiz_result_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/quiz_upload_page.dart';
import 'package:iquiz/presentation/pages/sign_in/sign_in_page.dart';
import 'package:iquiz/presentation/pages/sign_up/sign_up_page.dart';
import 'package:iquiz/presentation/pages/wrong_answers/wrong_answer_review_page.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';

part 'router.g.dart';

@TypedGoRoute<WrongAnswersRoute>(
  path: WrongAnswersRoute.path,
  name: WrongAnswersRoute.name,
  routes: [
    TypedGoRoute<WrongAnswerReviewRoute>(
      path: WrongAnswerReviewRoute.path,
      name: WrongAnswerReviewRoute.name,
    ),
  ],
)
class WrongAnswersRoute extends GoRouteData with $WrongAnswersRoute {
  const WrongAnswersRoute();
  static const path = '/wrong-answers';
  static const name = 'wrongAnswers';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MainPage(initialTab: MainNavigationTab.note);
}

class WrongAnswerReviewRoute extends GoRouteData with $WrongAnswerReviewRoute {
  const WrongAnswerReviewRoute(this.questionId, {this.$extra});
  static const path = ':questionId';
  static const name = 'wrongAnswerReview';
  final int questionId;
  final WrongAnswerEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      WrongAnswerReviewPage(questionId: questionId, question: $extra);
}

@TypedGoRoute<SignInRoute>(path: SignInRoute.path, name: SignInRoute.name)
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute({this.email, this.from});
  static const path = '/sign-in';
  static const name = 'signIn';
  final String? email;
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SignInPage(email: email);
}

@TypedGoRoute<SignUpRoute>(path: SignUpRoute.path, name: SignUpRoute.name)
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();
  static const path = '/sign-up';
  static const name = 'signUp';

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}

@TypedGoRoute<SplashRoute>(path: SplashRoute.path, name: SplashRoute.name)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  static const String path = '/splash';
  static const String name = 'splash';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const SplashPage(),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

@TypedGoRoute<HomeRoute>(path: HomeRoute.path, name: HomeRoute.name)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
  static const String path = '/home';
  static const String name = 'home';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const MainPage(),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

@TypedGoRoute<MaterialDetailRoute>(
  path: MaterialDetailRoute.path,
  name: MaterialDetailRoute.name,
)
class MaterialDetailRoute extends GoRouteData with $MaterialDetailRoute {
  const MaterialDetailRoute(this.materialId);
  static const String path = '/materials/:materialId';
  static const String name = 'materialDetail';
  final int materialId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MaterialDetailPage(materialId: materialId);
}

@TypedGoRoute<NoticeRoute>(path: NoticeRoute.path, name: NoticeRoute.name)
class NoticeRoute extends GoRouteData with $NoticeRoute {
  const NoticeRoute();

  static const String path = '/notice';
  static const String name = 'notice';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const NoticePage(),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

@TypedGoRoute<UploadRoute>(
  path: UploadRoute.path,
  name: UploadRoute.name,
  routes: [
    TypedGoRoute<QuizRoute>(
      path: QuizRoute.path,
      name: QuizRoute.name,
      routes: [
        TypedGoRoute<QuizResultRoute>(
          path: QuizResultRoute.path,
          name: QuizResultRoute.name,
        ),
      ],
    ),
  ],
)
class UploadRoute extends GoRouteData with $UploadRoute {
  const UploadRoute({
    this.materialId,
    this.materialTitle,
    this.conceptId,
    this.conceptName,
  });
  final int? materialId;
  final String? materialTitle;
  final int? conceptId;
  final String? conceptName;
  static const String path = '/upload';
  static const String name = 'upload';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: QuizUploadPage(
        materialId: materialId,
        materialTitle: materialTitle,
        conceptId: conceptId,
        conceptName: conceptName,
      ),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class QuizRoute extends GoRouteData with $QuizRoute {
  const QuizRoute(this.quizId, {this.title});
  static const String path = 'quiz/:quizId';
  static const String name = 'quiz';

  final int quizId;
  final String? title;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return QuizPlayPage(quizId: quizId, title: title);
  }
}

class QuizResultRoute extends GoRouteData with $QuizResultRoute {
  const QuizResultRoute(this.quizId, {this.$extra});

  static const String path = 'result';
  static const String name = 'quizResult';

  final int quizId;
  final QuizResultRouteArg? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      QuizResultPage(quizId: quizId, result: $extra);
}
