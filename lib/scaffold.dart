import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flyte/dyte.dart';

VideoView? dyteIosVideoView;
VideoView? dyteAndroidVideoView;

class ScaffoldWidget extends StatefulWidget {
  const ScaffoldWidget({super.key});

  @override
  ScaffoldState createState() => ScaffoldState();
}

class ScaffoldState extends State<ScaffoldWidget> {
  final _dyteClient = Dyte.dyte.dyteClient;

  late Size _deviceSize;

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          SizedBox(
            height: _deviceSize.height * 0.7,
            child: _JoinedParticipantList(
                dyteClient: _dyteClient, deviceSize: _deviceSize),
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
          const _ControlBarWidget(),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedParticipantList extends StatefulWidget {
  const _JoinedParticipantList({
    super.key,
    required DyteMobileClient dyteClient,
    required Size deviceSize,
  })  : _dyteClient = dyteClient,
        _deviceSize = deviceSize;

  final DyteMobileClient _dyteClient;
  final Size _deviceSize;

  @override
  State<_JoinedParticipantList> createState() => _JoinedParticipantListState();
}

class _JoinedParticipantListState extends State<_JoinedParticipantList>
    with DyteDelegate {
  DyteRoomState _roomState = DyteRoomState.left;

  @override
  void initState() {
    Dyte.dyte.addDelegate(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget._dyteClient.activeStream,
        initialData: dyteParticipants,
        builder: (context, snapshot) {
          if (snapshot.hasData && _roomState == DyteRoomState.joined) {
            return ListView(
              children: [
                for (final participant in snapshot.data!)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: widget._deviceSize.height * 0.3,
                      child: VideoView(meetingParticipant: participant),
                    ),
                  ),
              ],
            );
          }
          return const Center(
            child: Text(
              "Loading...",
              style: TextStyle(color: Colors.white),
            ),
          );
        });
  }

  @override
  void roomState(DyteRoomState roomState) {
    setState(() {
      _roomState = roomState;
    });
  }

  @override
  void dispose() {
    Dyte.dyte.removeDelegate(this);
    super.dispose();
  }

  @override
  void update(DyteJoinedMeetingParticipant participant, bool isLocal) {
    // TODO: implement update
  }
}

class _ControlBarWidget extends StatefulWidget {
  const _ControlBarWidget({
    super.key,
  });

  @override
  State<_ControlBarWidget> createState() => _ControlBarWidgetState();
}

class _ControlBarWidgetState extends State<_ControlBarWidget>
    with DyteDelegate {
  DyteRoomState state = DyteRoomState.left;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                    state == DyteRoomState.joining
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
                            color: Colors.white54, fontWeight: FontWeight.bold),
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
                            color: Colors.white54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void leaveRoom() async {
    if (state == DyteRoomState.joining) {
      Dyte.dyte.dyteLeaveRoom();
    }
  }

  void joinRoom() async {
    if (state == DyteRoomState.left) {
      Dyte.dyte.addDelegate(this);

      dyteMeetingId = 'bbb61a33-b644-4edc-8d10-9d45e8320fbf';

      if (dyteMeetingId == null) {
        await Dyte.dyte.dyteCreateMeeting();
      }

      await Dyte.dyte.dyteAddParticipant();
    }
  }

  @override
  void roomState(DyteRoomState roomState) {
    if (roomState == DyteRoomState.left) {
      Dyte.dyte.removeDelegate(this);
    }
    setState(() {
      state = roomState;
    });
  }

  @override
  void update(DyteJoinedMeetingParticipant participant, bool isLocal) {
    // TODO: implement update
  }
}
