enum BoardType {
  freeBoard('자유게시판'),
  goalShareBord('목표 공유 게시판'),
  sdTipBoard('자기계발 팁 게시판'),
  mentoringBoard('멘토링 요청 게시판'),
  promotionBoard('홍보 게시판');

  final String name;

  const BoardType(this.name);
}

class Board {
  final BoardType boardType; // 게시판 타입
  final String title;        // 게시판 제목
  final String content;      // 게시판 내용
  int likeCount;             // 좋아요 수
  int commentCount;          // 댓글 수

  Board({
    required this.boardType,
    required this.title,
    required this.content,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  // 좋아요 추가
  void like() {
    likeCount++;
  }

  // 댓글 추가
  void addComment() {
    commentCount++;
  }

  @override
  String toString() {
    return '[${boardType.name}] $title\n$content\n좋아요: $likeCount, 댓글: $commentCount';
  }
}
