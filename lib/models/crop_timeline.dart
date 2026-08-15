enum CropTimelineStatus {
  done,
  upcoming,
  due,
  overdue,
}

class CropTimelineStep {
  final String id;
  final String title;
  final String activityType;
  final int startDay;
  final int dueDay;
  final int endDay;
  final String recommendation;
  final List<String> matchTerms;

  const CropTimelineStep({
    required this.id,
    required this.title,
    required this.activityType,
    required this.startDay,
    required this.dueDay,
    required this.endDay,
    required this.recommendation,
    required this.matchTerms,
  });

  CropTimelineStep copyWith({
    int? startDay,
    int? dueDay,
    int? endDay,
  }) {
    return CropTimelineStep(
      id: id,
      title: title,
      activityType: activityType,
      startDay: startDay ?? this.startDay,
      dueDay: dueDay ?? this.dueDay,
      endDay: endDay ?? this.endDay,
      recommendation: recommendation,
      matchTerms: matchTerms,
    );
  }
}

class CropTimelineEntry {
  final CropTimelineStep step;
  final CropTimelineStatus status;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime endDate;
  final DateTime? completedDate;

  const CropTimelineEntry({
    required this.step,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.endDate,
    this.completedDate,
  });

  bool get isActionable =>
      status == CropTimelineStatus.due ||
      status == CropTimelineStatus.overdue;
}

class CropTimelinePlan {
  final String cropName;
  final String sourceLabel;
  final List<String> sourceUrls;
  final List<CropTimelineEntry> entries;

  const CropTimelinePlan({
    required this.cropName,
    required this.sourceLabel,
    required this.sourceUrls,
    required this.entries,
  });

  CropTimelineEntry? get nextAction {
    for (final entry in entries) {
      if (entry.status == CropTimelineStatus.overdue) return entry;
    }
    for (final entry in entries) {
      if (entry.status == CropTimelineStatus.due) return entry;
    }
    for (final entry in entries) {
      if (entry.status == CropTimelineStatus.upcoming) return entry;
    }
    return null;
  }

  int get completedCount =>
      entries.where((e) => e.status == CropTimelineStatus.done).length;

  int get dueCount => entries.where((e) => e.isActionable).length;
}
