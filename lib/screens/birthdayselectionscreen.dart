import 'package:flutter/material.dart';

class BirthdaySelectionScreen extends StatefulWidget {
  @override
  _BirthdaySelectionScreenState createState() => _BirthdaySelectionScreenState();
}

class _BirthdaySelectionScreenState extends State<BirthdaySelectionScreen> {
  int _selectedYear = 2003;
  int _selectedMonth = 4;
  int _selectedDay = 23;

  List<int> _years = List.generate(100, (index) => 1920 + index); // 1920년부터 100년치 연도 리스트
  List<int> _months = List.generate(12, (index) => index + 1); // 1월부터 12월까지
  List<int> _days = List.generate(31, (index) => index + 1); // 1일부터 31일까지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoBest계정'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '생일을 알려 주세요.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: _selectedYear,
                  items: _years.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text('$year'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: _months.map((month) {
                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text('$month'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _selectedDay,
                  items: _days.map((day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text('$day'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.yellow, // 버튼 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 크기
                ),
                onPressed: () {
                  Navigator.pop(context, '$_selectedYear년 $_selectedMonth월 $_selectedDay일');
                },
                child: Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ProfileDetailScreen에서 생일 선택 화면으로 이동하는 부분 수정
class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  String _birthday = '2003년 4월 23일';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 관리'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // 생일 ListTile 부분
          ListTile(
            title: Text('생일'),
            trailing: Text(_birthday, style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final selectedBirthday = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BirthdaySelectionScreen()),
              );
              if (selectedBirthday != null) {
                setState(() {
                  _birthday = selectedBirthday;
                });
              }
            },
          ),
          // 다른 항목들...
        ],
      ),
    );
  }
}
