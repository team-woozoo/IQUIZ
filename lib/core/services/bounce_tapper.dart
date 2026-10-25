import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// [bounce_tapper] 패키지 소스코드
/// https://github.com/Xim-ya/bounce_tapper
/// 일부 속성을 재정의하여 사용

class BounceTapper extends StatefulWidget {
  const BounceTapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.shrinkScaleFactor = 0.965,
    this.shrinkCurve = Curves.easeInSine,
    this.growCurve = Curves.easeOutSine,
    this.shrinkDuration = const Duration(milliseconds: 120),
    this.growDuration = const Duration(milliseconds: 120),
    this.delayedDurationBeforeGrow = Duration.zero,
    // this.delayedDurationBeforeGrow = const Duration(milliseconds: 60),
    this.highlightBorderRadius,
    this.highlightColor = const Color(0x1F939BAC),
    this.enable = true,
    this.blockTapOnLongPressEvent = true,
  }) : assert(
         shrinkScaleFactor > 0 && shrinkScaleFactor <= 1,
         'shrinkScaleFactor must be greater than 0 and less than or equal to 1',
       );

  final Widget child;
  final VoidCallback? onTap, onLongPress, onLongPressUp;
  final double shrinkScaleFactor;
  final Curve shrinkCurve, growCurve;
  final Duration shrinkDuration, growDuration;
  final Duration delayedDurationBeforeGrow;
  final bool enable;
  final BorderRadius? highlightBorderRadius;
  final Color highlightColor;
  final bool blockTapOnLongPressEvent;

  @override
  State<StatefulWidget> createState() => _BounceTapperState();
}

class _BounceTapperState extends State<BounceTapper>
    with SingleTickerProviderStateMixin<BounceTapper> {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final GlobalKey _touchAreaKey = GlobalKey();

  BorderRadiusGeometry? targetRadius;
  Timer? _longPressTimer;
  bool _isLongPressed = false;
  bool _isPressed = false; // 하이라이트 효과 제어를 위한 상태

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.shrinkDuration,
      reverseDuration: widget.growDuration,
    );
    _animation = Tween(begin: 1.0, end: widget.shrinkScaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.shrinkCurve,
        reverseCurve: widget.growCurve,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.highlightBorderRadius == null) {
        setState(() {
          targetRadius = _getChildBorderCloseBorderRadius(context);
        });
      }
    });
  }

  BorderRadiusGeometry? _getChildBorderCloseBorderRadius(BuildContext context) {
    final renderObject = context.findRenderObject();
    BorderRadiusGeometry? borderRadius;

    void visit(RenderObject? object) {
      if (borderRadius != null || object == null) {
        return;
      }

      if (object is RenderDecoratedBox) {
        final decoration = object.decoration;
        if (decoration is BoxDecoration && decoration.borderRadius != null) {
          borderRadius = decoration.borderRadius;
          return;
        }
      }

      if (object is RenderClipRRect) {
        borderRadius = object.borderRadius;
        return;
      }

      if (object is RenderPhysicalShape) {
        final clipper = object.clipper;
        if (clipper is ShapeBorderClipper) {
          final shape = clipper.shape;
          if (shape is RoundedRectangleBorder) {
            borderRadius = shape.borderRadius;
            return;
          }
        }
      }
      object.visitChildren(visit);
    }

    visit(renderObject);

    if (borderRadius == null) {
      log(
        'BounceTapper: Could not automatically detect BorderRadius. You may want to provide `highlightBorderRadius` manually.',
      );
    }

    return borderRadius;
  }

  /// 사용자가 터치를 시작했을 때 호출
  Future<void> _handlePressDown() async {
    if (!widget.enable || _controller.isAnimating) {
      return;
    }

    // 이전에 시작된 롱프레스 타이머가 있다면 취소
    _longPressTimer?.cancel();
    _isLongPressed = false;

    setState(() => _isPressed = true);
    await _controller.forward(); // 축소 애니메이션 시작

    // 롱프레스 타이머 시작 (500ms 후 onLongPress 호출)
    if (widget.onLongPress != null || widget.onLongPressUp != null) {
      _longPressTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && widget.onLongPress != null) {
          widget.onLongPress!();
          _isLongPressed = true;
        }
      });
    }
  }

  /// 사용자가 터치를 마쳤을 때 호출
  Future<void> _handlePressUp() async {
    _longPressTimer?.cancel(); // 롱프레스 타이머 취소

    if (!widget.enable) {
      _resetState();
      return;
    }

    if (_controller.status == AnimationStatus.forward &&
        !_controller.isCompleted) {
      await _controller.animateTo(
        widget.shrinkScaleFactor,
        duration: widget.shrinkDuration * (1.0 - _controller.value),
      );
    }

    await Future<void>.delayed(widget.delayedDurationBeforeGrow); // 축소 상태 유지

    await _controller.reverse(); // 확대 애니메이션 시작 및 완료 대기
    setState(() => _isPressed = false);

    // 애니메이션이 완전히 완료된 후 사용자 정의 콜백 실행
    if (_isLongPressed) {
      if (widget.onLongPressUp != null) {
        widget.onLongPressUp!();
      }
    } else {
      if (widget.onTap != null) {
        widget.onTap!();
      }
    }
    _isLongPressed = false; // 다음 상호작용을 위해 상태 초기화
  }

  /// 터치 제스처가 취소되었을 때 (예: 스크롤 시작) 호출
  Future<void> _handlePressCancel() async {
    _longPressTimer?.cancel(); // 롱프레스 타이머 취소
    if (!widget.enable) {
      _resetState();
      return;
    }
    // 즉시 애니메이션 복원 (지연 없음)
    if (_controller.isAnimating || _controller.isCompleted) {
      await _controller.reverse();
    }
    _resetState(); // 상태 초기화
  }

  /// 위젯의 상태를 초기화
  void _resetState() {
    if (mounted) {
      // 위젯이 마운트된 상태에서만 setState 호출
      setState(() {
        _isPressed = false;
        _isLongPressed = false;
      });
    }
    _longPressTimer?.cancel();
    _controller.value = 1.0; // 완전히 확대된 상태로 보장
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _touchAreaKey,
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.enable ? (_) => _handlePressDown() : null,
      onTapUp: widget.enable ? (_) => _handlePressUp() : null,
      onTapCancel: widget.enable ? _handlePressCancel : null,
      child: AnimatedBuilder(
        animation: _animation,
        child: widget.child,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enable ? _animation.value : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        targetRadius ??
                        widget.highlightBorderRadius ??
                        BorderRadius.zero,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        // 하이라이트 효과를 위한 AnimatedOpacity
                        opacity: _isPressed ? 1.0 : 0.0,
                        duration: _isPressed
                            ? widget
                                  .shrinkDuration // 축소될 때 하이라이트 표시
                            : widget.growDuration, // 확대될 때 하이라이트 사라짐
                        curve: Curves.easeOutQuad, // 하이라이트 전용 커브
                        child: ColoredBox(color: widget.highlightColor),
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          );
        },
      ),
    );
  }
}
