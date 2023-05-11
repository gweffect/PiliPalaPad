import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/user.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/pages/video/detail/controller.dart';

class VideoIntroController extends GetxController {
  // 视频aid
  String aid = Get.parameters['aid']!;

  // 是否预渲染 骨架屏
  bool preRender = false;

  // 视频详情 上个页面传入
  Map? videoItem = {};

  // 请求状态
  RxBool isLoading = false.obs;

  // 视频详情 请求返回
  Rx<VideoDetailData> videoDetail = VideoDetailData().obs;

  // 请求返回的信息
  String responseMsg = '请求异常';

  // up主粉丝数
  Map userStat = {'follower': '-'};

  // 是否点赞
  RxBool hasLike = false.obs;
  // 是否投币
  RxBool hasCoin = false.obs;
  // 是否收藏
  RxBool hasFav = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments.isNotEmpty) {
      if (Get.arguments.containsKey('videoItem')) {
        preRender = true;
        var args = Get.arguments['videoItem'];
        videoItem!['pic'] = args.pic;
        videoItem!['title'] = args.title;
        if (args.stat != null) {
          videoItem!['stat'] = args.stat;
        }
        videoItem!['pubdate'] = args.pubdate;
        videoItem!['owner'] = args.owner;
      }
    }
  }

  // 获取视频简介
  Future queryVideoIntro() async {
    var result = await VideoHttp.videoIntro(aid: aid);
    if (result['status']) {
      videoDetail.value = result['data']!;
      Get.find<VideoDetailController>(tag: Get.arguments['heroTag'])
          .tabs
          .value = ['简介', '评论 ${result['data']!.stat!.reply}'];
    } else {
      responseMsg = result['msg'];
    }
    // 获取到粉丝数再返回
    await queryUserStat();
    // 获取点赞状态
    queryHasLikeVideo();
    // 获取投币状态
    queryHasCoinVideo();
    // 获取收藏状态
    queryHasFavVideo();

    return result;
  }

  // 获取up主粉丝数
  Future queryUserStat() async {
    var result = await UserHttp.userStat(mid: videoDetail.value.owner!.mid!);
    if (result['status']) {
      userStat = result['data'];
    }
  }

  // 获取点赞状态
  Future queryHasLikeVideo() async {
    var result = await VideoHttp.hasLikeVideo(aid: aid);
    // data	num	被点赞标志	0：未点赞  1：已点赞
    hasLike.value = result["data"] == 1 ? true : false;
  }

  // 获取投币状态
  Future queryHasCoinVideo() async {
    var result = await VideoHttp.hasCoinVideo(aid: aid);
    hasCoin.value = result["data"]['multiply'] == 0 ? false : true;
  }

  // 获取收藏状态
  Future queryHasFavVideo() async {
    var result = await VideoHttp.hasFavVideo(aid: aid);
    hasFav.value = result["data"]['favoured'];
  }

  // 一键三连

  // （取消）点赞
  Future actionLikeVideo() async {
    var result = await VideoHttp.likeVideo(aid: aid, type: !hasLike.value);
    if (result['status']) {
      hasLike.value = result["data"] == 1 ? true : false;
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // 投币
  Future actionCoinVideo() async {
    print('投币');
  }

  // （取消）收藏
  Future actionFavVideo() async {
    print('（取消）收藏');
    // var result = await VideoHttp.favVideo(aid: aid, type: true, ids: '');
  }

  // 分享视频
  Future actionShareVideo() async {
    print('分享视频');
  }
}
