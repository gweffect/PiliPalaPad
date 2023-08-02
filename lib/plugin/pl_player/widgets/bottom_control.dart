import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/plugin/pl_player/widgets/play_pause_btn.dart';

class BottomControl extends StatelessWidget implements PreferredSizeWidget {
  final PlPlayerController? controller;
  const BottomControl({this.controller, Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Color colorTheme = Theme.of(context).colorScheme.primary;
    final _ = controller!;
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      primary: false,
      toolbarHeight: 73,
      automaticallyImplyLeading: false,
      titleSpacing: 14,
      title: Column(
        children: [
          const SizedBox(height: 23),
          Obx(
            () {
              final int value = _.sliderPosition.value.inSeconds;
              final int max = _.duration.value.inSeconds;
              final int buffer = _.buffered.value.inSeconds;
              if (value > max || max <= 0) {
                return Container();
              }
              return ProgressBar(
                progress: Duration(seconds: value),
                buffered: Duration(seconds: buffer),
                total: Duration(seconds: max),
                progressBarColor: colorTheme,
                baseBarColor: Colors.white.withOpacity(0.2),
                bufferedBarColor: colorTheme.withOpacity(0.4),
                timeLabelLocation: TimeLabelLocation.none,
                thumbColor: colorTheme,
                barHeight: 3.0,
                thumbRadius: 5.5,
                onDragStart: (duration) {
                  _.onChangedSliderStart();
                },
                onDragUpdate: (duration) {
                  _.onUodatedSliderProgress(duration.timeStamp);
                },
                onSeek: (duration) {
                  _.onChangedSliderEnd();
                  _.onChangedSlider(duration.inSeconds.toDouble());
                  _.seekTo(Duration(seconds: duration.inSeconds));
                },
              );
            },
          ),
          Row(
            children: [
              // Obx(
              //   () => ComBtn(
              //     icon: Icon(
              //       _.playerStatus.paused
              //           ? FontAwesomeIcons.play
              //           : _.playerStatus.playing
              //               ? FontAwesomeIcons.pause
              //               : FontAwesomeIcons.rotateRight,
              //       size: 15,
              //       color: Colors.white,
              //     ),
              //     fuc: () => _.togglePlay(),
              //   ),
              // ),
              PlayOrPauseButton(
                controller: _,
              ),
              const SizedBox(width: 4),
              // 播放时间
              Obx(() {
                return Text(
                  _.duration.value.inMinutes >= 60
                      ? printDurationWithHours(_.position.value)
                      : printDuration(_.position.value),
                  style: textStyle,
                );
              }),
              const SizedBox(width: 2),
              const Text('/', style: textStyle),
              const SizedBox(width: 2),
              Obx(
                () => Text(
                  _.duration.value.inMinutes >= 60
                      ? printDurationWithHours(_.duration.value)
                      : printDuration(_.duration.value),
                  style: textStyle,
                ),
              ),
              const Spacer(),
              // 倍速
              // Obx(
              //   () => SizedBox(
              //     width: 45,
              //     height: 34,
              //     child: TextButton(
              //       style: ButtonStyle(
              //         padding: MaterialStateProperty.all(EdgeInsets.zero),
              //       ),
              //       onPressed: () {
              //         _.togglePlaybackSpeed();
              //       },
              //       child: Text(
              //         '${_.playbackSpeed.toString()}X',
              //         style: textStyle,
              //       ),
              //     ),
              //   ),
              // ),
              // ComBtn(
              //   icon: const Icon(
              //     Icons.fit_screen_sharp,
              //     size: 18,
              //     color: Colors.white,
              //   ),
              //   fuc: () => _.toggleVideoFit(),
              // ),
              // const SizedBox(width: 4),
              // 全屏
              Obx(() => ComBtn(
                    icon: Icon(
                      _.isFullScreen.value
                          ? FontAwesomeIcons.a
                          : FontAwesomeIcons.expand,
                      size: 15,
                      color: Colors.white,
                    ),
                    fuc: () async {
                      if (!_.isFullScreen.value) {
                        /// 按照视频宽高比决定全屏方向
                        if (_.direction.value == 'horizontal') {
                          /// 进入全屏
                          await enterFullScreen();
                          // 横屏
                          await landScape();
                        } else {
                          // 竖屏
                          await verticalScreen();
                        }

                        _.toggleFullScreen(true);
                        var result = await showDialog(
                          context: Get.context!,
                          builder: (context) => Dialog.fullscreen(
                            backgroundColor: Colors.black,
                            child: PLVideoPlayer(
                              controller: _,
                              headerControl: _.headerControl,
                            ),
                          ),
                        );
                        if (result == null) {
                          // 退出全屏
                          exitFullScreen();
                          await verticalScreen();
                          _.toggleFullScreen(false);
                        }
                      } else {
                        Get.back();
                        exitFullScreen();
                        await verticalScreen();
                        _.toggleFullScreen(false);
                      }
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
