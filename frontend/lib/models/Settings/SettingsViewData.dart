class SettingsViewData {
  const SettingsViewData({
    required this.uploadOnlyWifi,
    required this.autoSyncOnStart,
    required this.backgroundSync,
    required this.compactDensity,
    required this.selectedUploadQuality,
  });

  factory SettingsViewData.initial() {
    return const SettingsViewData(
      uploadOnlyWifi: true,
      autoSyncOnStart: true,
      backgroundSync: false,
      compactDensity: false,
      selectedUploadQuality: 'High',
    );
  }

  final bool uploadOnlyWifi;
  final bool autoSyncOnStart;
  final bool backgroundSync;
  final bool compactDensity;
  final String selectedUploadQuality;

  SettingsViewData copyWith({
    bool? uploadOnlyWifi,
    bool? autoSyncOnStart,
    bool? backgroundSync,
    bool? compactDensity,
    String? selectedUploadQuality,
  }) {
    return SettingsViewData(
      uploadOnlyWifi: uploadOnlyWifi ?? this.uploadOnlyWifi,
      autoSyncOnStart: autoSyncOnStart ?? this.autoSyncOnStart,
      backgroundSync: backgroundSync ?? this.backgroundSync,
      compactDensity: compactDensity ?? this.compactDensity,
      selectedUploadQuality:
      selectedUploadQuality ?? this.selectedUploadQuality,
    );
  }
}