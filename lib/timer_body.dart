import 'package:active_timer/timer.dart';
import 'package:active_timer/timer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  CountDownTimer work = CountDownTimer(workName: "Work", workTime: 30);

  List<CountDownTimer> listOfCD = [];
  int selectedIndex = 0;
  String _workName = "";
  String _workTime = "";
  List<String> listOfCDNames = [];
  List<String> listOfCDTimes = [];
  readData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    listOfCDNames = pref.getStringList("listOfCDNames") ?? [];
    listOfCDTimes = pref.getStringList("listOfCDTimes") ?? [];
    List<CountDownTimer> v = [];
    for (int i = 0; i < listOfCDNames.length; i++) {
      v.add(CountDownTimer(
          workName: listOfCDNames[i], workTime: int.parse(listOfCDTimes[i])));
    }
    setState(() {
      listOfCD = v;
    });
  }

  addData(String name, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    listOfCDNames.add(name);
    listOfCDTimes.add(value);
    pref.setStringList("listOfCDNames", listOfCDNames);
    pref.setStringList("listOfCDTimes", listOfCDTimes);
    await readData();
  }

  removeData(CountDownTimer countDown) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    listOfCDNames.remove(countDown.workName);
    listOfCDTimes.remove(countDown.workTime.toString());
    pref.setStringList("listOfCDNames", listOfCDNames);
    pref.setStringList("listOfCDTimes", listOfCDTimes);
    await readData();
  }

  Future addWorkTimer(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Add",
              style: TextStyle(
                color: Color(0xFF1c7589),
              ),
              textAlign: TextAlign.center,
            ),
            content: Container(
              height: 150,
              child: Column(children: [
                TextField(
                  onChanged: (String val) {
                    setState(() {
                      _workName = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    hintText: "Work Name",
                    filled: true,
                    fillColor: Color(0xff73d6ff),
                    focusColor: Color(0xFF31d6ff),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  onChanged: (String val) {
                    setState(() {
                      _workTime = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    hintText: "Work Time in Minutes",
                    filled: true,
                    fillColor: Color(0xff73d6ff),
                    focusColor: Color(0xFF31d6ff),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_workName.isNotEmpty && _workTime.isNotEmpty) {
                    await addData(_workName, _workTime);

                    Navigator.of(context).pop();
                  }
                },
                child: Text("Add"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    readData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return StreamBuilder<TimerModel>(
          stream: listOfCD.isNotEmpty ? listOfCD[selectedIndex].stream() : null,
          builder: (context, snapshot) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...listOfCD
                            .map(
                              (CountDownTimer countDown) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: InputChip(
                                  deleteIconColor: Colors.white,
                                  onPressed: () {
                                    countDown.startCountDown();

                                    setState(() {
                                      selectedIndex = listOfCD.indexWhere(
                                          (element) =>
                                              element.workName ==
                                                  countDown.workName &&
                                              element.workTime ==
                                                  countDown.workTime);
                                    });
                                  },
                                  label: Text(countDown.workName,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white)),
                                  backgroundColor: selectedIndex ==
                                          listOfCD.indexWhere((element) =>
                                              element.workName ==
                                                  countDown.workName &&
                                              element.workTime ==
                                                  countDown.workTime)
                                      ? Color(0xFF0098be)
                                      : Color(0xFF3198be),
                                  onDeleted: () async {
                                    selectedIndex = 0;
                                    await removeData(countDown);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                        MaterialButton(
                            onPressed: () {
                              addWorkTimer(context);
                            },
                            child: Icon(Icons.add),
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
                snapshot.hasData
                    ? Expanded(
                        child: CircularPercentIndicator(
                          lineWidth: 10,
                          center: Text(
                            snapshot.data!.time,
                            style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF114013),
                                fontWeight: FontWeight.bold),
                          ),
                          radius: constraints.maxWidth > constraints.maxHeight
                              ? constraints.maxHeight * 0.70
                              : constraints.maxWidth * 0.70,
                          //0.0-1.0
                          percent: snapshot.data!.percent,
                          progressColor: Color(0xFF2a7f9e),
                        ),
                      )
                    : Expanded(
                        child: CircularPercentIndicator(
                          lineWidth: 10,
                          center: Text(
                            "00:00",
                            style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF114013),
                                fontWeight: FontWeight.bold),
                          ),
                          radius: constraints.maxWidth > constraints.maxHeight
                              ? constraints.maxHeight * 0.70
                              : constraints.maxWidth * 0.70,
                          //0.0-1.0
                          percent: 1,
                          progressColor: Color(0xFF2a7f9e),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      listOfCD.isNotEmpty
                          ? listOfCD[selectedIndex].isActive
                              ? Expanded(
                                  child: MaterialButton(
                                      color: Color(0xFF2a7f9e),
                                      child: Text("Stop",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white)),
                                      onPressed: () {
                                        listOfCD[selectedIndex].stop();
                                      }),
                                )
                              : Expanded(
                                  child: MaterialButton(
                                      color: Color(0xFF2a7f9e),
                                      child: Text(
                                          listOfCD[selectedIndex].percent == 1
                                              ? "Start"
                                              : "Resume",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white)),
                                      onPressed: () {
                                        listOfCD[selectedIndex].start();
                                      }),
                                )
                          : Expanded(
                              child: MaterialButton(
                                  color: Color(0xFF2a7f9e),
                                  child: Text("Start",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white)),
                                  onPressed: () {}),
                            ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: MaterialButton(
                            color: Color(0xFF2a7f9e),
                            child: Text("Restart",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                            onPressed: () {
                              if (listOfCD.isNotEmpty)
                                listOfCD[selectedIndex].restart();
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
    });
  }
}
