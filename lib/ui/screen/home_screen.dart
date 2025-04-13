import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title, this.user});

  final String title;
  final User? user;

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _tabTitles = [];
  int _currentTabIndex = 0;

  final GlobalKey plusKey = GlobalKey();
  final GlobalKey leftTabKey = GlobalKey();

  final GlobalKey memberAddKey = GlobalKey();
  final GlobalKey slidableKey = GlobalKey();
  final GlobalKey sortKey = GlobalKey();
  final GlobalKey fabKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _tabTitles = ref.read(tabTitlesProvider);
    _tabController = TabController(length: _tabTitles.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex &&
          !_tabController.indexIsChanging) {
        _currentTabIndex = _tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });

    _tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_tabController.index != _currentTabIndex) {
          _currentTabIndex = _tabController.index;
          _saveTabIndex(_currentTabIndex);
        }
      }
    });

    _loadSavedTabIndex();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isTutorialShown = prefs.getBool('isTutorialShown') ?? false;

    if (!isTutorialShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
      debugPrint('Tutorial shown');
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
      debugPrint('Tutorial already shown');
    }
  }

  void _showTutorial() {
    _createTargets();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFFE0E0E0),
      textSkip: "スキップ",
      paddingFocus: 10,
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isTutorialShown', true);
      },
    );
    tutorialCoachMark.show(context: context);
  }

  void _createTargets() {
    targets.clear();
    targets.addAll([
      TargetFocus(
        identify: "plus_button",
        keyTarget: plusKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "こちらをタップでイベントを\n追加できます",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "left_tab",
        keyTarget: leftTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "長押しでイベントを削除\nできます",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "member_add",
        keyTarget: memberAddKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "こちらをタップでメンバーを\n追加できます",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "slidable",
        keyTarget: slidableKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "スワイプでメンバーを削除\nできます",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "sort_icon",
        keyTarget: sortKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "こちらをタップで支払い状況順に\n並び変えることができます",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "fab",
        keyTarget: fabKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  "こちらをタップで催促メッセージを\n送信できます\n(現在機能申請中ですのでアップデートを\nお待ちください)",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabController(int newLength) {
    _tabController.dispose();
    _tabController = TabController(length: newLength, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex &&
          !_tabController.indexIsChanging) {
        _currentTabIndex = _tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });
    _tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_tabController.index != _currentTabIndex) {
          _currentTabIndex = _tabController.index;
          _saveTabIndex(_currentTabIndex);
        }
      }
    });
  }

  Future<void> _saveTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTabIndex', index);
  }

  Future<void> _loadSavedTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('lastTabIndex') ?? 0;
    if (mounted && savedIndex < _tabController.length) {
      _currentTabIndex = savedIndex;
      _tabController.animateTo(savedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final tabTitles = ref.watch(tabTitlesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (tabTitles.length != _tabController.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateTabController(tabTitles.length);
            _tabTitles = tabTitles;
            _loadSavedTabIndex();
          });
        }
      });
    } else {
      _tabTitles = tabTitles;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              SizedBox(
                width: screenWidth * 0.04,
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.04),
          child: Stack(
            children: [
              Container(
                height: screenHeight * 0.04,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFC0C8CA),
                      width: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          tabs: _tabTitles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final eventId = entry.value;
                            final event = user!.events.firstWhere(
                              (e) => e.eventId == eventId,
                              orElse: () => const Event(
                                  eventId: "", eventName: '', members: []),
                            );
                            final bool isFullyPaid = event.members.isNotEmpty &&
                                event.members.every((member) =>
                                    member.status != PaymentStatus.unpaid);

                            final Color tabTextColor = isFullyPaid
                                ? const Color(0xFF35C759)
                                : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color ??
                                    Colors.black;

                            final bool isFirstTab = (index == 0);

                            return GestureDetector(
                              key: isFirstTab ? leftTabKey : null,
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteEventDialog(
                                    userId: ref.read(userProvider)!.userId,
                                    eventId: eventId,
                                  );
                                },
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Tab(
                                  child: Text(event.eventName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontSize: 14,
                                              color: tabTextColor)),
                                ),
                              ),
                            );
                          }).toList(),
                          indicatorColor: Colors.black,
                          indicatorWeight: 1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          key: plusKey,
                          icon: SvgPicture.asset(
                            'assets/icons/plus.svg',
                            width: screenWidth * 0.07,
                            height: screenWidth * 0.07,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddEventDialog(
                                  userId: ref.read(userProvider)!.userId,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          width: screenWidth * 0.04,
                        ),
                        // TODO リリース初期段階では、一括削除機能のボタンは非表示
                        // IconButton(
                        //   onPressed: () {
                        //     // TODO 一括削除処理
                        //   },
                        //   icon: SvgPicture.asset('assets/icons/delete.svg'),
                        // ),
                        // const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const TanochanDrawer(),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabTitles.map((eventId) {
                final event = user!.events.firstWhere(
                  (e) => e.eventId == eventId,
                  orElse: () =>
                      const Event(eventId: "", eventName: '', members: []),
                );
                return MemberList(
                  memberAddKey: memberAddKey,
                  slidableKey: slidableKey,
                  sortKey: sortKey,
                  fabKey: fabKey,
                  members: event.eventId != "" ? event.members : [],
                  eventId: event.eventId != "" ? event.eventId : "",
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
