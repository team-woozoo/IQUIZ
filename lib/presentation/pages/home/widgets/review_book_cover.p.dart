part of '../home_page.dart';

class _ReviewBookCover extends StatelessWidget {
  const _ReviewBookCover();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 60,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColor.splashBackground),
      ),
      child: Image.asset('assets/home/review_cover.png', fit: BoxFit.cover),
    ),
  );
}
