class DiscussionPost {
  final String content;
  final String author;
  final String dateTime;
  int likes;
  int comments;

  DiscussionPost({
    required this.content,
    required this.author,
    required this.dateTime,
    this.likes = 0,
    this.comments = 0,
  });
}
