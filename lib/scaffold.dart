import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyte/dyte.dart';
import 'package:flyte/tools.dart';

VideoView? dyteIosVideoView;
VideoView? dyteAndroidVideoView;

class ScaffoldWidget extends StatefulWidget {
  const ScaffoldWidget({super.key});

  @override
  ScaffoldState createState() => ScaffoldState();
}

class ScaffoldState extends State<ScaffoldWidget> with DyteDelegate {
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white54,
                  width: 2,
                ),
              ),
              child: dyteIosVideoView ??
                  const Center(
                    child: Icon(Icons.apple, size: 64, color: Colors.white54),
                  ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white54,
                  width: 2,
                ),
              ),
              child: dyteAndroidVideoView ??
                  const Center(
                    child: Icon(Icons.android, size: 64, color: Colors.white54),
                  ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
            child: Text(
              textAlign: TextAlign.center,
              dyteMeetingId != null ? '\nMeeting ID:\n$dyteMeetingId' : '',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      joinRoom();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white54, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isJoining
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login, color: Colors.white54),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 24, // Add padding top and bottom
                          ),
                          child: Text(
                            '      J o i n',
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Add some space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      leaveRoom();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white54, width: 2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white54),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 24, // Add padding top and bottom
                          ),
                          child: Text(
                            '      L e a v e',
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void joinRoom() async {
    if (!isJoining) {
      if ((Tools.tools.appDevice == AppDevice.ios &&
              Tools.tools.userId == 'ios' &&
              dyteIosVideoView != null) ||
          (Tools.tools.appDevice == AppDevice.android &&
              Tools.tools.userId == 'android' &&
              dyteAndroidVideoView != null)) {
        leaveRoom();
      }

      setState(() {
        isJoining = true;
      });

      Dyte.dyte.dyteDelegate = this;

      // TODO: Replace with your meeting id
      dyteMeetingId = 'your meeting id goes here';

      if (dyteMeetingId == null) {
        await Dyte.dyte.dyteCreateMeeting();
      }

      await Dyte.dyte.dyteAddParticipant();
    }
  }

  void leaveRoom() async {
    if (!isJoining) {
      Dyte.dyte.dyteLeaveRoom();
    }
  }

  //DyteDelegate
  @override
  void update(
      String state, DyteJoinedMeetingParticipant participant, bool isLocal) {
    debugPrint('stageLiveUpdateView: $state');

    if (state == 'join') {
      if (Tools.tools.appDevice == AppDevice.ios &&
          (participant.clientSpecificId == 'ios' || isLocal)) {
        dyteIosVideoView = const VideoView(isSelfParticipant: true);
        debugPrint('ME AS IOS');
      } else if (Tools.tools.appDevice == AppDevice.ios) {
        dyteAndroidVideoView = VideoView(meetingParticipant: participant);
        debugPrint('HIM AS ANDROID');
      } else if (Tools.tools.appDevice == AppDevice.android &&
          (participant.clientSpecificId == 'android' || isLocal)) {
        dyteAndroidVideoView = const VideoView(isSelfParticipant: true);
        debugPrint('ME AS ANDROID');
      } else if (Tools.tools.appDevice == AppDevice.android) {
        dyteIosVideoView = VideoView(meetingParticipant: participant);
        debugPrint('HIM AS IOS');
      }
    } else if (state == 'leave') {
      dyteIosVideoView = null;
      dyteAndroidVideoView = null;
    }

    setState(() {
      isJoining = false;
    });
  }
}
