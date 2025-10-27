# Quick Start Guide

Get the MoveNet Pose Tracker app running in under 5 minutes!

## Prerequisites Check

Before you begin, make sure you have:
- ✅ macOS with Xcode 13+ installed
- ✅ An iOS device (iPhone/iPad) with iOS 14+
- ✅ USB cable to connect your device

## Quick Setup (5 Steps)

### 1. Install CocoaPods (if not already installed)

```bash
sudo gem install cocoapods
```

### 2. Download the Model and Install Dependencies

```bash
# Make script executable and download model
chmod +x download_model.sh
./download_model.sh

# Install dependencies
pod install
```

### 3. Create Xcode Project

Open Xcode and create a new iOS App project:
- **File → New → Project**
- Choose "App" template
- Product Name: `MoveNetPoseTracker`
- Interface: **SwiftUI**
- Language: **Swift**
- Save in: This directory

**Important:** Close the `.xcodeproj` and open `MoveNetPoseTracker.xcworkspace` instead!

### 4. Add All Files to Your Project

Drag and drop these files into your Xcode project navigator:

**Swift Files** (replace existing when prompted):
- `MoveNetApp.swift`
- `ContentView.swift` 
- `CameraManager.swift`
- `MoveNetModel.swift`
- `PoseData.swift`
- `PoseOverlayView.swift`

**Model File** (copy when adding):
- `movenet_singlepose_lightning.tflite` ✅ Check "Copy items if needed"

**Configuration** (replace existing):
- `Info.plist`

### 5. Configure and Run

1. **Disable Bitcode:**
   - Select project → Build Settings
   - Search "bitcode"
   - Set to **No**

2. **Sign the app:**
   - Select project → Signing & Capabilities
   - Choose your Team

3. **Run on Device:**
   - Connect your iPhone/iPad
   - Select it from the device menu
   - Press ⌘R to build and run

## Expected Result

When the app launches:
1. It will request camera permission → **Allow**
2. Camera view appears with your live feed
3. Stand in front of camera (1-2 meters away)
4. Green/yellow dots appear on your body showing detected keypoints
5. Lines connect the dots to show your skeleton
6. FPS counter shows in top-left corner

## Troubleshooting

### "Model file not found"
→ Verify `movenet_singlepose_lightning.tflite` is in your project and appears in Build Phases → Copy Bundle Resources

### "No such module 'TensorFlowLite'"
→ Make sure you opened `.xcworkspace` not `.xcodeproj`, then clean build (⇧⌘K) and rebuild

### Camera not working
→ Use a physical device (simulator has no camera)

### Build fails
→ Delete `Pods/` folder, run `pod install` again, clean build folder

## What's Next?

Once it's working, you can:
- 🎨 Customize colors in `PoseOverlayView.swift`
- 📊 Add pose analytics or exercise counters
- 🎯 Build pose-based games or fitness apps
- 📸 Add screenshot/recording features

## Need More Help?

See `SETUP.md` for detailed instructions and troubleshooting.

---

**Enjoy building with MoveNet! 🚀**

