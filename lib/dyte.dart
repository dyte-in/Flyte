import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flyte/api.dart';

List<DyteJoinedMeetingParticipant> dyteParticipants = [];

String? dyteMeetingId;

bool isDyteInit = false;

enum DyteRoomState {
  joining,
  joined,
  leaving,
  left,
}

mixin DyteDelegate {
  void update(DyteJoinedMeetingParticipant participant, bool isLocal);

  void roomState(DyteRoomState roomState);
}

class Dyte
    implements DyteMeetingRoomEventsListener, DyteParticipantEventsListener {
  final List<DyteDelegate> _delegates = [];

  static final Dyte dyte = Dyte._internal();

  final dyteClient = DyteMobileClient();

  factory Dyte() {
    return dyte;
  }

  void addDelegate(DyteDelegate delegate) {
    _delegates.add(delegate);
  }

  void removeDelegate(DyteDelegate delegate) {
    _delegates.remove(delegate);
  }

  Dyte._internal() {
    debugPrint('INIT DYTE SINGLETON');

    if (!isDyteInit) {
      isDyteInit = true;
      dyteClient.addMeetingRoomEventsListener(this);
      dyteClient.addParticipantEventsListener(this);
    }
  }

  Future<void> dyteCreateMeeting() async {
    dyteMeetingId = await Api.api.restPostDyteMeeting();
  }

  Future<void> dyteAddParticipant() async {
    debugPrint('dyteAddParticipant');

    String? token = await Api.api.restPostDyteParticipant();

    if (token != null) {
      final meetingInfo = DyteMeetingInfoV2(
          authToken: token, enableVideo: true, enableAudio: true);

      dyteClient.init(meetingInfo);
    }
  }

  void dyteJoinRoom() {
    debugPrint('dyteJoinRoom');

    dyteClient.joinRoom();
  }

  void dyteLeaveRoom() {
    debugPrint('dyteLeaveRoom');

    dyteClient.leaveRoom();
    for (final delegate in _delegates) {
      delegate.roomState(DyteRoomState.leaving);
      delegate.update(dyteClient.localUser, true);
    }
  }

  // DyteMeetingRoomEventsListener
  @override
  void onMeetingInitStarted() {
    debugPrint('onMeetingInitStarted');
    for (final delegate in _delegates) {
      delegate.roomState(DyteRoomState.joining);
    }
    dyteParticipants.clear();
  }

  @override
  Future<void> onMeetingInitCompleted() async {
    debugPrint('onMeetingInitCompleted');
    dyteJoinRoom();

    for (final delegate in _delegates) {
      delegate.roomState(DyteRoomState.leaving);
    }
  }

  @override
  void onMeetingInitFailed(Exception exception) {
    debugPrint('onMeetingInitFailed: $exception');
  }

  @override
  void onConnectedToMeetingRoom() {
    debugPrint('onConnectedToMeetingRoom');
  }

  @override
  void onConnectingToMeetingRoom() {
    debugPrint('onConnectingToMeetingRoom');
  }

  @override
  void onDisconnectedFromMeetingRoom(String reason) {
    debugPrint('onDisconnectedFromMeetingRoom: $reason');
  }

  @override
  void onMeetingRoomConnectionError(String errorMessage) {
    debugPrint('onMeetingRoomConnectionError: $errorMessage');
  }

  @override
  void onMeetingRoomDisconnected() {
    debugPrint('onMeetingRoomDisconnected');
  }

  @override
  void onMeetingRoomJoinCompleted() {
    debugPrint('onMeetingRoomJoinCompleted');

    for (final delegate in _delegates) {
      delegate.update(dyteClient.localUser, true);
      delegate.roomState(DyteRoomState.joined);
    }
  }

  @override
  void onMeetingRoomJoinFailed(Exception exception) {
    debugPrint('onMeetingRoomJoinFailed: $exception');
  }

  @override
  void onMeetingRoomJoinStarted() {
    debugPrint('onMeetingRoomJoinStarted');

    for (final delegate in _delegates) {
      delegate.roomState(DyteRoomState.joining);
    }
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    debugPrint('onMeetingRoomLeaveCompleted');
  }

  @override
  void onMeetingRoomLeaveStarted() {
    debugPrint('onMeetingRoomLeaveStarted');
  }

  @override
  void onMeetingRoomReconnectionFailed() {
    debugPrint('onMeetingRoomReconnectionFailed');
  }

  @override
  void onReconnectedToMeetingRoom() {
    debugPrint('onReconnectedToMeetingRoom');
  }

  @override
  void onReconnectingToMeetingRoom() {
    debugPrint('onReconnectingToMeetingRoom');
  }

  // DyteParticipantEventsListener
  @override
  void onActiveParticipantsChanged(List<DyteJoinedMeetingParticipant> active) {
    debugPrint('onActiveParticipantsChanged');
  }

  @override
  void onActiveSpeakerChanged(DyteJoinedMeetingParticipant participant) {
    debugPrint('onActiveSpeakerChanged');
  }

  @override
  void onAudioUpdate(
      bool audioEnabled, DyteJoinedMeetingParticipant participant) {
    debugPrint('onAudioUpdate');
  }

  @override
  void onNoActiveSpeaker() {
    debugPrint('onNoActiveSpeaker');
  }

  @override
  void onParticipantJoin(DyteJoinedMeetingParticipant participant) {
    debugPrint('onParticipantJoin');

    if (!dyteParticipants
        .any((item) => item.clientSpecificId == participant.clientSpecificId)) {
      dyteParticipants.add(participant);
    }
  }

  @override
  void onParticipantLeave(DyteJoinedMeetingParticipant participant) {
    debugPrint('onParticipantLeave');

    if (dyteParticipants
        .any((item) => item.clientSpecificId == participant.clientSpecificId)) {
      dyteParticipants.removeWhere(
          (item) => item.clientSpecificId == participant.clientSpecificId);
    }
  }

  @override
  void onParticipantPinned(DyteJoinedMeetingParticipant participant) {
    debugPrint('onParticipantPinned');
  }

  @override
  void onParticipantUnpinned(DyteJoinedMeetingParticipant participant) {
    debugPrint('onParticipantUnpinned');
  }

  @override
  void onScreenShareEnded(DyteJoinedMeetingParticipant participant) {
    debugPrint('onScreenShareEnded');
  }

  @override
  void onScreenShareStarted(DyteJoinedMeetingParticipant participant) {
    debugPrint('onScreenShareStarted');
  }

  @override
  void onScreenSharesUpdated() {
    debugPrint('onScreenSharesUpdated');
  }

  @override
  void onUpdate(DyteParticipants participants) {
    debugPrint('onUpdate');
  }

  @override
  void onVideoUpdate(
      bool videoEnabled, DyteJoinedMeetingParticipant participant) {
    debugPrint('onVideoUpdate');

    for (final delegate in _delegates) {
      delegate.update(participant, false);
    }
  }
}
