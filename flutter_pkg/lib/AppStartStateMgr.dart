class AppStartStateMgr {
  List<Function> changeCallBacks = [];
  String _state;

  String get state => _state;

  void changeState(String state, {int count, int total}) {
    _state = state;
    emitCallBack(state, count: count, total: total);
  }

  void emitCallBack(String state, {int count, int total}) {
    if (changeCallBacks.isEmpty) return;
    for (Function changeCallBack in changeCallBacks) {
      changeCallBack(state, count, total);
    }
  }

  void addChangeCallBack(Function changeCallBack) {
    changeCallBacks.add(changeCallBack);
  }

  void deleteChangeCallBack(Function changeCallBack) {
    if (changeCallBacks.contains(changeCallBack)) {
      changeCallBacks.remove(changeCallBack);
    }
  }
}

AppStartStateMgr appStartStateMgr = AppStartStateMgr();
