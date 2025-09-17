class Report {
  final String title;
  final String description;
  final String dateTime;
  final String location;
  final String status;
  final List<String> tags;
  final String author;

  Report({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.tags,
    required this.author,
  });
}
