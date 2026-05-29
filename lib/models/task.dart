class Task {
  const Task({required this.title, this.isCompleted = false});

  final String title;
  final bool isCompleted;

  Task copyWith({String? title, bool? isCompleted}) {
    return Task(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
