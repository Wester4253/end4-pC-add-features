commit d6f717e2ceb1fca02c1dccf191a39efa26965db6
Author: OttoAgent <noah.butterfeild@gmail.com>
Date:   Thu Nov 19 07:27:42 2026 +0000

    feat: Add Project Display & Audio Flyout (Super+P)
    
    - Added ProjectDisplay.qml with 3 tabs: Display, Audio, Brightness/Color
    - Display tab: 4 projection modes (PC only, Mirror, Extend, Second screen), monitor list with resolution/scale/rotation/VRR/DPMS controls
    - Audio tab: Output/input device cards with volume sliders, mute toggle, default device selection
    - Brightness/Color tab: Brightness slider, Night Light with presets, Color profile with gamma sliders
    - Service: ProjectDisplay.qml with monitor/audio refresh, Super+P global shortcut
    - GlobalStates: projectDisplayOpen property + CompositorGlobalShortcut (Super+P)
    - Settings: BarConfig + DashboardSettingsCatalog with full toggle controls
    - Config: projectDisplay.* options for all features

diff --git a/GlobalStates.qml b/GlobalStates.qml
index bc5fed67..4c59a6ef 100644
--- a/GlobalStates.qml
+++ b/GlobalStates.qml
@@ -34,6 +34,7 @@ Singleton {
     property bool superReleaseMightTrigger: true
     property bool wallpaperSelectorOpen: false
     property bool workspaceShowNumbers: false
+    property bool projectDisplayOpen: false
     property var settingsTarget: null
 
     function openSettingsAt(pageId, label, section, subsection) {
@@ -160,4 +161,12 @@ Singleton {
             Config.options.background.centeredWallpaper = !Config.options.background.centeredWallpaper
         }
     }
+
+    CompositorGlobalShortcut {
+        name: "projectDisplay"
+        description: "Toggle Project Display & Audio flyout (Super+P)"
+        onPressed: {
+            root.projectDisplayOpen = !root.projectDisplayOpen;
+        }
+    }
 }
\ No newline at end of file
