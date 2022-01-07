// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'add_finance_screen.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  static const String id = 'finance_screen';

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final User? user = _auth.currentUser;

    try {
      loggedInUser = user;
      print(loggedInUser?.email);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Finances'),
        backgroundColor: Colors.grey[850],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddFinanceScreen.id);
        },
        backgroundColor: Colors.orangeAccent,
        child: Icon(
          Icons.add,
          color: Colors.grey[900],
          size: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: const <Widget>[
            FinanceGoalStream(),
          ],
        ),
      ),
    );
  }
}

class FinanceGoalStream extends StatelessWidget {
  const FinanceGoalStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('financeTasks')
          .where('uid', isEqualTo: loggedInUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        List<TargetBubble> targetsBubbles = [];
        final targets = snapshot.data!.docs
            .reversed; // reverse order of list --> new message at bottom of list

        for (var target in targets) {
          final name = target['name'];
          final goal = target['goal'];
          final current = target['current'];
          final date = target['date'];

          final targetBubble = TargetBubble(
            name: name,
            goal: goal,
            current: current,
            date: date,
          );
          targetsBubbles.add(targetBubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            children: //targets,
                targetsBubbles,
          ),
        );
      },
    );
  }
}

class TargetBubble extends StatelessWidget {
  final String name;
  final String goal;
  final String current;
  final String date;
  final double progress;
  final String percent;

  TargetBubble(
      {required this.name,
      required this.goal,
      required this.current,
      required this.date,
      Key? key})
      : progress = double.parse(current) / double.parse(goal),
        percent = (double.parse(current) / double.parse(goal) * 100)
            .toStringAsFixed(2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 13.0,
              animation: true,
              percent: progress,
              center: Text(
                "$percent%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.orangeAccent,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Goal Amount: $goal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Current Amount: $current',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Date: $date',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
