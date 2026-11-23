# end4-pC Dynamic Island Overhaul - Agent Context

## Repository Overview
- **Source**: `/home/wstr/documents/code/end4-pC` (feat/dynamic-island-overhaul)
- **Config**: `/home/wstr/.config/quickshell/end4-pC` (detached HEAD at v1.0-dynamic-island-overhaul)
- **Remote**: https://github.com/Wester4253/end4-pC-add-features.git

## Key Files
- `shell.qml` - Main entry, loads IllogicalImpulseFamily
- `GlobalStates.qml` - Singleton with UI state (barOpen, dynamicIslandEnabled, etc.)
- `Config.qml` - Configuration schema
- `panelFamilies/IllogicalImpulseFamily.qml` - Loads all modules

## Dynamic Island Sections (28 total)
All in `modules/ii/bar/`:
- DiExpandedAiSection, DiExpandedSystemSection, DiExpandedWeatherSection
- DiExpandedCalendarSection, DiExpandedWorldClockSection, DiExpandedMediaSection
- DiExpandedVisualizerSection, DiExpandedNotificationsSection, DiExpandedClipboardSection
- DiExpandedActionsSection, DiExpandedWindowSection, DiExpandedTimerSection
- DiExpandedNetworkSection, DiExpandedBluetoothSection, DiExpandedRecordingSection
- DiExpandedServicesSection, DiExpandedLogsSection, DiExpandedShortcutsSection
- DiExpandedUpdatesSection, DiExpandedVPNSection, DiExpandedDiskSection
- DiExpandedGPUSection, DiExpandedProcessesSection, DiExpandedDockerSection
- DiExpandedProfilesSection, DiExpandedFocusSection, DiExpandedSystemInfoSection
- DiExpandedFileSearchSection, DiExpandedCalculatorSection, DiExpandedTodoSection
- DiExpandedNotesSection, DiExpandedTranslatorSection, DiExpandedSongRecSection

## Key Fixes Applied
See LOCAL_CONFIG_CHANGES.md for detailed diffs.
