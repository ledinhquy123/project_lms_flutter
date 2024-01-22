import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:lms_flutter_app/Controller/lesson_controller.dart';
import 'package:lms_flutter_app/Model/Course/Lesson.dart';
import 'package:lms_flutter_app/utils/widgets/connectivity_checker_widget.dart';
// import 'package:pod_player/pod_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String? videoID;
  final Lesson? lesson;
  final String? source;

  VideoPlayerPage(this.source, {this.videoID, this.lesson});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // PodPlayerController? _podPlayerController;

  final LessonController lessonController = Get.put(LessonController());

  String? video;
  bool _isPlayerReady = false;
  late YoutubePlayerController _controller;

  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;

  @override
  void initState() {

      print('Video ID: ${widget.videoID}');
      print('Video Lesson: ${widget.lesson?.name}');
      print('Video Source: ${widget.source}');

    _controller = YoutubePlayerController(
      initialVideoId: extractYouTubeVideoId('${widget.videoID}'),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;

    // try{
    //
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //     DeviceOrientation.landscapeRight,
    //     DeviceOrientation.landscapeLeft
    //   ]);
    //
    //   print('Video ID: ${widget.videoID}');
    //   print('Video Lesson: ${widget.lesson?.name}');
    //   print('Video Source: ${widget.source}');
    //
    //   _podPlayerController = PodPlayerController(
    //     playVideoFrom: widget.source == "Youtube"
    //         ? PlayVideoFrom.youtube(
    //       'https://www.youtube.com/watch?v=MMhdcVfNo18',
    //     )
    //         : PlayVideoFrom.network(
    //       '${widget.videoID}',
    //     ),
    //   )
    //     ..initialise()
    //     ..addListener(() async {
    //       if (_podPlayerController!.isInitialised) {
    //         if (_podPlayerController?.videoPlayerValue?.position ==
    //             _podPlayerController?.totalVideoLength) {
    //           if (widget.lesson != null) {
    //             await lessonController.updateLessonProgress(
    //                 widget.lesson?.id, widget.lesson?.courseId, 1);
    //             Get.back();
    //           }
    //         }
    //       }
    //     });
    //
    // } catch (e, t) {
    //
    //   debugPrint('$e');
    //   debugPrint('$t');
    //
    // }

    super.initState();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  String extractYouTubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'^.*(?:youtu.be\/|v\/|e\/|u\/\w+\/|embed\/|v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );

    Match? match = regExp.firstMatch(url);
    if (match?.groupCount == 1) {
      return match!.group(1)!;
    } else {
      // Return an empty string or throw an exception, depending on your use case.
      return '';
    }
  }


  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // _podPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ConnectionCheckerWidget(
    //   child: SafeArea(
    //     child: WillPopScope(
    //       onWillPop: () async => false,
    //       child: SafeArea(
    //         child: Scaffold(
    //           body: Stack(
    //             children: [
    //               Positioned.fill(
    //                 child: Container(
    //                   color: Colors.black,
    //                   child: Align(
    //                     alignment: Alignment.center,
    //                     child: PodVideoPlayer(controller: _podPlayerController!),
    //                   ),
    //                 ),
    //               ),
    //               Positioned(
    //                 top: 30,
    //                 left: 5,
    //                 child: IconButton(
    //                   onPressed: () => Get.back(),
    //                   icon: Icon(Icons.cancel, color: Colors.white),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return ConnectionCheckerWidget(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async => false,
          child: YoutubePlayerBuilder(
            onExitFullScreen: () {
              SystemChrome.setPreferredOrientations(DeviceOrientation.values);
            },
            onEnterFullScreen: () {
              SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.landscapeLeft]);
            },
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
              progressIndicatorColor: Colors.blueAccent,
              onReady: () {
                setState(() {
                  _isPlayerReady = true;
                });
              },
              onEnded: (data) async {
                if (widget.lesson != null) {
                  await lessonController
                      .updateLessonProgress(
                          widget.lesson?.id, widget.lesson?.courseId, 1)
                      .then((value) {
                    Get.back();
                  });
                }
              },
            ),
            builder: (context, player) => SafeArea(
              child: Scaffold(
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(fit: BoxFit.fill, child: player),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 5,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.cancel, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
