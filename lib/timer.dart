import 'package:active_timer/timer_model.dart';

class CountDownTimer {
  String workName;
  int workTime;
  CountDownTimer({required this.workName, required this.workTime});

  Duration _time = Duration();
  Duration _fullTime = Duration();
  double _percent = 1.0;
  bool _isActive = false;
  bool get isActive => _isActive;
  double get percent => _percent;

  void startCountDown() {
    _time = Duration(minutes: workTime);
    _fullTime = _time;
    _percent = 1;
    _isActive = false;
  }

  void stop() {
    _isActive = false;
  }

  void restart() {
    _time = Duration(minutes: workTime);
    _fullTime = _time;
    _percent = 1;
    _isActive = true;
  }

  void start() {
    if (_percent > 0) _isActive = true;
  }

  Stream<TimerModel> stream() async* {
    yield* Stream.periodic(Duration(seconds: 1), (i) {
      if (_isActive) {
        if (_percent > 0) _time = _time - Duration(seconds: 1);
      }
      _percent = _time.inSeconds / _fullTime.inSeconds;
      String inMinutes = _time.inMinutes < 10
          ? "0" + _time.inMinutes.toString()
          : _time.inMinutes.toString();
      int leftSeconds = _time.inSeconds % 60;
      String inSeconds = leftSeconds < 10
          ? "0" + leftSeconds.toString()
          : leftSeconds.toString();
      String time = inMinutes + ":" + inSeconds;

      return TimerModel(time: time, percent: _percent);
    });
  }
}
