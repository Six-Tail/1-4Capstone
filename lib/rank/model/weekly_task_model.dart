class WeeklyTask {
  String name;
  bool isCompleted;
  int xp;
  bool hasClaimedXP;
  DateTime? lastClaimedTime; // 각 미션의 마지막 경험치 획득 시간 추가
  int currentAttendance;

  WeeklyTask({
    required this.name,
    required this.isCompleted,
    required this.xp,
    required this.hasClaimedXP,
    this.lastClaimedTime,
    this.currentAttendance = 0,
  });
}
