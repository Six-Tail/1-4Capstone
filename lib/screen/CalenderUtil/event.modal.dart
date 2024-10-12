  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';

  import 'event.model.dart'; // Firestore 추가

  class EventModal extends StatefulWidget {
    final DateTime selectedDate;
    final Function(String, String, DateTime, DateTime, String)
        onSave; // 수정된 이벤트를 저장하는 콜백
    final String? initialValue;
    final String? initialTime;
    final String? initialEndTime;
    final bool editMode;

    const EventModal({
      super.key,
      required this.selectedDate,
      required this.onSave, // onSave를 사용합니다.
      this.initialValue,
      this.initialTime,
      this.initialEndTime,
      this.editMode = false,
    });

    @override
    _EventModalState createState() => _EventModalState();
  }

  class _EventModalState extends State<EventModal> {
    late TextEditingController eventController;
    DateTime? selectedEndDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool _isAllDay = false;
    DateTime? startDate;
    DateTime? endDate;
    bool _showError = false; // 에러 메시지 표시 여부
    String _errorMessage = ''; // 에러 메시지 내용
    String _selectedRepeat = '반복 없음'; // 기본 반복 주기

    final List<String> _repeatOptions = [
      '반복 없음',
      '매일',
      '매주',
      '매월',
      '매년',
    ];

    @override
    void initState() {
      super.initState();
      eventController = TextEditingController(text: widget.initialValue ?? "");
      startDate = widget.selectedDate;
      endDate = widget.selectedDate;

      if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
        final parts = widget.initialTime!.split(':');
        if (parts.length == 2) {
          startTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      if (widget.initialEndTime != null && widget.initialEndTime!.isNotEmpty) {
        final parts = widget.initialEndTime!.split(':');
        if (parts.length == 2) {
          endTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }

    @override
    void dispose() {
      eventController.dispose();
      super.dispose();
    }

    Future<void> _selectDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate! : (endDate ?? startDate!),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (picked != null && mounted) {
        // mounted 체크 추가
        setState(() {
          if (isStartDate) {
            if (picked.isAfter(endDate!)) {
              endDate = picked;
            }
            startDate = picked;
          } else {
            if (picked.isBefore(startDate!)) {
              startDate = picked;
            }
            endDate = picked.isBefore(startDate!) ? startDate : picked;
          }
        });
      }
    }

    Future<void> _selectTime(BuildContext context, bool isStartTime) async {
      final TimeOfDay? pickedTime = await showCupertinoDialog<TimeOfDay>(
        context: context,
        builder: (BuildContext context) {
          TimeOfDay selectedTime = isStartTime
              ? (startTime ?? TimeOfDay.now())
              : (endTime ?? TimeOfDay.now());

          return CupertinoAlertDialog(
            title: Text(isStartTime ? '시작 시간 선택' : '종료 시간 선택'),
            content: SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime:
                    DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute),
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedTime = TimeOfDay(
                      hour: newDateTime.hour, minute: newDateTime.minute);
                },
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(selectedTime);
                },
              ),
              CupertinoDialogAction(
                child: const Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          if (isStartTime) {
            startTime = pickedTime;
          } else {
            endTime = pickedTime;
          }
        });
      }
    }

    // Firestore에 이벤트 추가 또는 수정
    Future<void> _addOrUpdateEventToFirestore(Event event,
        {String? eventId}) async {
      final eventCollection = FirebaseFirestore.instance.collection('events');

      try {
        if (eventId != null) {
          // 이벤트 ID가 있을 경우, 해당 이벤트 업데이트
          await eventCollection.doc(eventId).update(event.toFirestore());
          // 성공 메시지를 콘솔에 출력
          if (kDebugMode) {
            print('이벤트가 Firestore에서 수정되었습니다.');
          }
        } else {
          // 이벤트 ID가 없으면 새 이벤트 추가
          await eventCollection.add(event.toFirestore());
          // 성공 메시지를 콘솔에 출력
          if (kDebugMode) {
            print('이벤트가 Firestore에 등록되었습니다.');
          }
        }
      } catch (e) {
        // 실패 메시지를 콘솔에 출력
        if (kDebugMode) {
          print('이벤트 등록 또는 수정에 실패했습니다. 오류: $e');
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.85,
            maxWidth: screenWidth * 0.9, // 가로 길이를 화면의 90%로 설정
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.editMode ? '일정 수정' : '일정 등록',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextField(
                    controller: eventController,
                    decoration: const InputDecoration(hintText: '일정 내용을 입력하세요'),
                    maxLines: 3,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // 경고 메시지 표시
                  if (_showError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      SizedBox(width: screenWidth * 0.02),
                      const Text('하루 종일'),
                      Transform.scale(
                        scale: 0.6,
                        child: Switch(
                          value: _isAllDay,
                          onChanged: (value) {
                            setState(() {
                              _isAllDay = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // 시작 날짜와 종료 날짜를 선택하는 UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(
                            DateFormat('yy년 MM월 dd일').format(startDate!),
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis), // 텍스트 오버플로우 처리
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            DateFormat('yy년 MM월 dd일').format(endDate!),
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis), // 텍스트 오버플로우 처리
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 시작 시간 및 종료 시간 선택 UI
                  if (!_isAllDay) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            TextButton(
                              onPressed: () => _selectTime(context, true),
                              child: Text(startTime != null
                                  ? startTime!.format(context)
                                  : '시작 시간'),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () => _selectTime(context, false),
                              child: Text(
                                endTime != null
                                    ? endTime!.format(context)
                                    : '종료 시간',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  // 반복 주기 선택 UI
                  Row(
                    children: [
                      const Icon(Icons.repeat),
                      SizedBox(width: screenWidth * 0.02),
                      const Text('반복'),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedRepeat,
                        items: _repeatOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRepeat = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (eventController.text.isNotEmpty) {
                            if (!_isAllDay &&
                                (startTime == null || endTime == null)) {
                              // 시작 시간 또는 종료 시간이 설정되지 않았을 때 경고 메시지 표시
                              setState(() {
                                _showError = true;
                                _errorMessage =
                                    '시작 시간과 종료 시간을 모두 선택해 주세요.'; // 경고 메시지 설정
                              });
                              return; // 이벤트 등록을 중단
                            } else {
                              // 에러 메시지 숨기기
                              setState(() {
                                _showError = false;
                              });
                            }

                            String startTimeString = _isAllDay
                                ? '하루 종일'
                                : '${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}';
                            String endTimeString = _isAllDay
                                ? '하루 종일'
                                : '${endTime?.hour.toString().padLeft(2, '0')}:${endTime?.minute.toString().padLeft(2, '0')}';

                            // Event 객체 생성
                            Event newEvent = Event(
                              name: eventController.text,
                              time: _isAllDay
                                  ? '하루 종일'
                                  : '$startTimeString - $endTimeString',
                              startDate: startDate!,
                              // 팝업에서 선택한 시작 날짜
                              endDate: endDate!,
                              // 팝업에서 선택한 종료 날짜
                              repeat: _selectedRepeat, // 반복 주기 추가
                            );

                            // Firestore에 이벤트 추가 또는 수정
                            if (widget.editMode) {
                              _addOrUpdateEventToFirestore(newEvent,
                                  eventId:
                                      widget.initialValue); // 수정할 때 이벤트 ID 전달
                            } else {
                              _addOrUpdateEventToFirestore(newEvent); // 새 이벤트 추가
                            }

                            // onSave 콜백 호출하여 수정된 이벤트 전달
                            widget.onSave(
                              eventController.text,
                              _isAllDay
                                  ? '하루 종일'
                                  : '$startTimeString - $endTimeString',
                              startDate!, // 팝업에서 선택한 시작 날짜
                              endDate!, // 팝업에서 선택한 종료 날짜
                              _selectedRepeat, // 반복 주기 전달
                            );

                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          }
                        },
                        child: Text(widget.editMode ? '수정' : '등록'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
