class OfflineQueuedException implements Exception {
  final String message;

  const OfflineQueuedException([
    this.message = 'Saved offline, will sync when online.',
  ]);

  @override
  String toString() => message;
}
