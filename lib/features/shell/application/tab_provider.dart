import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab pada navigasi bawah, urut sama dengan desain acuan.
enum AppTab { home, spell, abc, quiz, album }

class TabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) => state = tab;
}

final tabProvider = NotifierProvider<TabNotifier, AppTab>(TabNotifier.new);
