import 'package:PiliPalaPad/pages/media/controller.dart';
import 'package:PiliPalaPad/pages/media/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPalaPad/common/constants.dart';
import 'package:PiliPalaPad/common/widgets/network_img_layer.dart';
import 'package:PiliPalaPad/models/common/theme_type.dart';
import 'package:PiliPalaPad/models/user/info.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'controller.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserController userController = Get.put(UserController());
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();

    _futureBuilderFuture = userController.queryUserInfo();
    _futureBuilderFuture.then((value) => setState(() {
          _futureBuilderFuture = userController.queryFavFolder();
        }));
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        controller: userController.scrollController,
        child: Column(
          children: [
            buildUserRow(),
            for (var i in userController.list) ...[
              ListTile(
                onTap: () => i['onTap'](),
                dense: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Icon(
                    i['icon'],
                    color: primary,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.only(left: 15, top: 2, bottom: 2),
                minLeadingWidth: 0,
                title: Text(
                  i['title'],
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
            Obx(() => userController.userLogin.value
                ? favFolder(userController, context)
                : const SizedBox(height: 0))
          ],
        ),
      ),
    );
  }

  Widget buildUserRow() {
    LevelInfo? levelInfo = userController.userInfo.value.levelInfo;
    TextStyle style = TextStyle(
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => userController.onLogin(),
          child: ClipOval(
            child: Container(
              width: 70,
              height: 70,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Center(
                child: userController.userInfo.value.face != null
                    ? NetworkImgLayer(
                        src: userController.userInfo.value.face,
                        semanticsLabel: '头像',
                        width: 70,
                        height: 70)
                    : Image.asset(
                        'assets/images/noface.jpeg',
                        semanticLabel: "默认头像",
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  userController.currenrUserName,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  'assets/images/lv/lv${userController.userInfo.value.levelInfo != null ? userController.userInfo.value.levelInfo!.currentLevel : '0'}.png',
                  height: 10,
                  semanticLabel:
                      '等级：${userController.userInfo.value.levelInfo != null ? userController.userInfo.value.levelInfo!.currentLevel : '0'}',
                )
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '硬币 ',
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.outline)),
              TextSpan(
                  text: (userController.userInfo.value.money ?? '-').toString(),
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              TextSpan(
                  text: "  经验 ",
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.outline)),
              TextSpan(
                  text: "${levelInfo?.currentExp ?? '-'}",
                  semanticsLabel: "当前${levelInfo?.currentExp ?? '-'}",
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              TextSpan(
                  text: "/${levelInfo?.nextExp ?? '-'}",
                  semanticsLabel: "升级需${levelInfo?.nextExp ?? '-'}",
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.outline)),
            ]))
          ],
        ),
        Expanded(
          child: Container(),
        ),
        Container(
            width: 240,
            height: 100,
            child: GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: [
                InkWell(
                  onTap: () => userController.pushDynamic(),
                  borderRadius: StyleString.mdRadius,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Text(
                            (userController.userStat.value.dynamicCount ?? '-')
                                .toString(),
                            key: ValueKey<String>(userController
                                .userStat.value.dynamicCount
                                .toString()),
                            style: style),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '动态',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => userController.pushFollow(),
                  borderRadius: StyleString.mdRadius,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Text(
                            (userController.userStat.value.following ?? '-')
                                .toString(),
                            key: ValueKey<String>(userController
                                .userStat.value.following
                                .toString()),
                            style: style),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '关注',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => userController.pushFans(),
                  borderRadius: StyleString.mdRadius,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Text(
                            (userController.userStat.value.follower ?? '-')
                                .toString(),
                            key: ValueKey<String>(userController
                                .userStat.value.follower
                                .toString()),
                            style: style),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '粉丝',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(width: 10),
        IconButton(
          tooltip: '设置',
          onPressed: () {
            Get.toNamed('/setting');
          },
          icon: const Icon(
            Icons.settings_outlined,
          ),
        )
      ],
    );
  }

  Widget userInfoBuild(_userController, context) {
    LevelInfo? levelInfo = _userController.userInfo.value.levelInfo;
    TextStyle style = TextStyle(
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => _userController.onLogin(),
            child: ClipOval(
              child: Container(
                width: 70,
                height: 70,
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: Center(
                  child: _userController.userInfo.value.face != null
                      ? NetworkImgLayer(
                          src: _userController.userInfo.value.face,
                          semanticsLabel: '头像',
                          width: 70,
                          height: 70)
                      : Image.asset(
                          'assets/images/noface.jpeg',
                          semanticLabel: "默认头像",
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IntrinsicWidth(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _userController.userInfo.value.uname ?? '点击头像登录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/lv/lv${_userController.userInfo.value.levelInfo != null ? _userController.userInfo.value.levelInfo!.currentLevel : '0'}.png',
                    height: 10,
                    semanticLabel:
                        '等级：${_userController.userInfo.value.levelInfo != null ? _userController.userInfo.value.levelInfo!.currentLevel : '0'}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '硬币 ',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelSmall!.fontSize,
                        color: Theme.of(context).colorScheme.outline)),
                TextSpan(
                    text: (_userController.userInfo.value.money ?? '-')
                        .toString(),
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text: "  经验 ",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelSmall!.fontSize,
                        color: Theme.of(context).colorScheme.outline)),
                TextSpan(
                    text: "${levelInfo?.currentExp ?? '-'}",
                    semanticsLabel: "当前${levelInfo?.currentExp ?? '-'}",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text: "/${levelInfo?.nextExp ?? '-'}",
                    semanticsLabel: "升级需${levelInfo?.nextExp ?? '-'}",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelSmall!.fontSize,
                        color: Theme.of(context).colorScheme.outline)),
              ])),
              // const SizedBox(height: 4),
              // Text.rich(TextSpan(children: [
              // ])),
              // Text.rich(
              //     textAlign: TextAlign.right,
              //     TextSpan(children: [
              //
              //     ])),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                minHeight: 2,
                value: levelInfo != null
                    ? (levelInfo.currentExp! / levelInfo.nextExp!)
                    : 0,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            ],
          )),
          const SizedBox(width: 20),
        ],
      ),
      const SizedBox(height: 10),
      Container(
          width: 240,
          height: 100,
          child: GridView.count(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
              InkWell(
                onTap: () => _userController.pushDynamic(),
                borderRadius: StyleString.mdRadius,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                          (_userController.userStat.value.dynamicCount ?? '-')
                              .toString(),
                          key: ValueKey<String>(_userController
                              .userStat.value.dynamicCount
                              .toString()),
                          style: style),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '动态',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _userController.pushFollow(),
                borderRadius: StyleString.mdRadius,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                          (_userController.userStat.value.following ?? '-')
                              .toString(),
                          key: ValueKey<String>(_userController
                              .userStat.value.following
                              .toString()),
                          style: style),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '关注',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _userController.pushFans(),
                borderRadius: StyleString.mdRadius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                          (_userController.userStat.value.follower ?? '-')
                              .toString(),
                          key: ValueKey<String>(_userController
                              .userStat.value.follower
                              .toString()),
                          style: style),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '粉丝',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          )),
    ]);
  }

  Widget favFolder(userController, context) {
    return Column(
      children: [
        Divider(
          height: 20,
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        ListTile(
          onTap: () => Get.toNamed('/fav'),
          leading: null,
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Obx(
              () => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '我的收藏  ',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    if (userController.favFolderData.value.count != null)
                      TextSpan(
                        text: "${userController.favFolderData.value.count}  ",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleSmall!.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    WidgetSpan(
                        child: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                  ],
                ),
              ),
            ),
          ),
          trailing: IconButton(
            tooltip: '刷新',
            onPressed: () {
              setState(() {
                _futureBuilderFuture = userController.queryFavFolder();
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 20,
            ),
          ),
        ),
        // const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.textScalerOf(context).scale(200),
          child: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SizedBox();
                  }
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    List favFolderList =
                        userController.favFolderData.value.list!;
                    int favFolderCount =
                        userController.favFolderData.value.count!;
                    bool flag = favFolderCount > favFolderList.length;
                    return Obx(() => ListView.builder(
                          itemCount:
                              userController.favFolderData.value.list!.length +
                                  (flag ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (flag && index == favFolderList.length) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 14, bottom: 35),
                                  child: Center(
                                    child: IconButton(
                                      tooltip: '查看更多',
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withOpacity(0.5);
                                        }),
                                      ),
                                      onPressed: () => Get.toNamed('/fav'),
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ));
                            } else {
                              return FavFolderItem(
                                  item: userController
                                      .favFolderData.value.list![index],
                                  index: index);
                            }
                          },
                          scrollDirection: Axis.horizontal,
                        ));
                  } else {
                    return SizedBox(
                      height: 160,
                      child: Center(child: Text(data['msg'])),
                    );
                  }
                } else {
                  // 骨架屏
                  return const SizedBox();
                }
              }),
        ),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final Icon? icon;
  final Function? onTap;
  final String? text;

  const ActionItem({
    Key? key,
    this.icon,
    this.onTap,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: StyleString.mdRadius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon!.icon!),
          const SizedBox(height: 8),
          Text(
            text!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
