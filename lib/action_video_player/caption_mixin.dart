import 'package:Tracker/action_sheet/action_description.dart';
import 'package:async/async.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'dart:async';

mixin CaptionSchedularMixin<T extends StatefulWidget> on State<T> {
  int currentCaption = -1;
  bool interrupt = false;
  List<ActionDescription> captionList;
  Widget captionWidget;
  CancelableOperation<void> _displayCpationOperation;
  CancelableOperation<void> _hideCpationOperation;
  bool disposed = false;
  BetterPlayerController _controller;

  void schedularInitialize(List<ActionDescription> captionList,
      Widget captionWidget, BetterPlayerController controller) {
    _controller = controller;
    this.captionList = captionList;
    this.captionWidget = captionWidget;
  }

  void startScheduleCaption() {
    _controller.addEventsListener(_playerControlEventHandler);
  }

  void _playerControlEventHandler(BetterPlayerEvent e) {
    switch (e.betterPlayerEventType) {
      case BetterPlayerEventType.progressStartDragging:
        // cancel all scheduling event
        break;
      case BetterPlayerEventType.progressEndDragging:
        // reschedule all caption event.
        break;
      case BetterPlayerEventType.finished:
        // cancel all event and caption.
        break;
      default:
    }
  }

  void scheduleDisplayCpation() {
    if (currentCaption + 1 == captionList.length)
      return; // out of bound checking
    final Duration delay = captionList[currentCaption + 1].targetTime -
        _controller.videoPlayerController.value.position;

    _displayCpationOperation =
        CancelableOperation.fromFuture(Future.delayed(delay, () {
      if (interrupt) return;

      _displayCpationOperation = null;
      displayCaption(_controller, ++currentCaption);

      scheduleDisplayCpation();
    }));
  }

  int calculateCaptionDisplayTime(int wordLength) {
    return (wordLength ~/ (200 / 60)) * 1000 + 500;
  }

  void displayCaption(BetterPlayerController controller, int cpationIndex) {
    if (disposed) return;
    _displayCpationOperation?.cancel();
    setState(() {
      final ActionDescription action = captionList[cpationIndex];

      captionWidget = action.buildCaptionWidget();
      int wordCount = action.description.split(' ').length;

      scheduleHideCaption(
          Duration(milliseconds: calculateCaptionDisplayTime(wordCount)),
          cpationIndex);
    });
  }

  void scheduleHideCaption(Duration d, int cancelCaptionIndex) {
    _hideCpationOperation =
        CancelableOperation.fromFuture(Future.delayed(d, () {
      if (interrupt) return;

      _hideCpationOperation = null;

      hideCaption(cancelCaptionIndex);
    }));
  }

  void hideCaption(int cancelCaptionIndex) {
    if (disposed || currentCaption != cancelCaptionIndex) return;
    _hideCpationOperation?.cancel();
    setState(() {
      captionWidget = Container();
    });
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
