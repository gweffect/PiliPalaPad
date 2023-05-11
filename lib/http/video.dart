import 'dart:io';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/model_rec_video_item.dart';
import 'package:pilipala/models/video_detail_res.dart';

/// res.data['code'] == 0 请求正常返回结果
/// res.data['data'] 为结果
/// 返回{'status': bool, 'data': List}
/// view层根据 status 判断渲染逻辑
class VideoHttp {
  // 首页推荐视频
  static Future rcmdVideoList({required int ps, required int freshIdx}) async {
    try {
      var res = await Request().get(
        Api.recommendList,
        data: {
          'feed_version': 'V3',
          'ps': ps,
          'fresh_idx': freshIdx,
        },
      );
      if (res.data['code'] == 0) {
        List<RecVideoItemModel> list = [];
        for (var i in res.data['data']['item']) {
          list.add(RecVideoItemModel.fromJson(i));
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': []};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err};
    }
  }

  // 最热视频
  static Future hotVideoList({required int pn, required int ps}) async {
    try {
      var res = await Request().get(
        Api.hotList,
        data: {'pn': pn, 'ps': ps},
      );
      if (res.data['code'] == 0) {
        List<HotVideoItemModel> list = [];
        for (var i in res.data['data']['list']) {
          list.add(HotVideoItemModel.fromJson(i));
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': []};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err};
    }
  }

  // 视频信息 标题、简介
  static Future videoIntro({required String aid}) async {
    var res = await Request().get(Api.videoIntro, data: {'aid': aid});
    VideoDetailResponse result = VideoDetailResponse.fromJson(res.data);
    if (result.code == 0) {
      return {'status': true, 'data': result.data!};
    } else {
      Map errMap = {
        -400: '请求错误',
        -403: '权限不足',
        -404: '无视频',
        62002: '稿件不可见',
        62004: '稿件审核中',
      };
      return {
        'status': false,
        'data': null,
        'msg': errMap[result.code] ?? '请求异常',
      };
    }
  }

  // 相关视频
  static Future relatedVideoList({required String aid}) async {
    var res = await Request().get(Api.relatedList, data: {'aid': aid});
    if (res.data['code'] == 0) {
      List<HotVideoItemModel> list = [];
      for (var i in res.data['data']) {
        list.add(HotVideoItemModel.fromJson(i));
      }
      return {'status': true, 'data': list};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 获取点赞状态
  static Future hasLikeVideo({required String aid}) async {
    var res = await Request().get(Api.hasLikeVideo, data: {'aid': aid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 获取投币状态
  static Future hasCoinVideo({required String aid}) async {
    var res = await Request().get(Api.hasCoinVideo, data: {'aid': aid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': true, 'data': []};
    }
  }

  // 获取收藏状态
  static Future hasFavVideo({required String aid}) async {
    var res = await Request().get(Api.hasFavVideo, data: {'aid': aid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 一键三连
  // （取消）点赞
  static Future likeVideo({required String aid, required bool type}) async {
    var res = await Request().post(
      Api.likeVideo,
      data: {
        'aid': aid,
        'like': type ? 1 : 2,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // （取消）收藏
  static Future favVideo(
      {required String aid, required bool type, required String ids}) async {
    Map data = {'rid': aid, 'type': 2};
    // type true 添加收藏 false 取消收藏
    if (type) {
      data['add_media_ids'] = ids;
    } else {
      data['del_media_ids'] = ids;
    }
    var res = await Request()
        .post(Api.favVideo, data: {'aid': aid, 'like': type ? 1 : 2});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }
}
