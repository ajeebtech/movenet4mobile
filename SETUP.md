# Setup Instructions

Follow these steps to set up and run the MoveNet Pose Tracking app.

## Prerequisites

- macOS with Xcode 13.0 or later
- iOS device running iOS 14.0 or later (physical device required for camera)
- CocoaPods installed

## Step-by-Step Setup

### 1. Download the MoveNet Model

Run the provided script to download the model:

```bash
chmod +x download_model.sh
./download_model.sh
```

This will download `movenet_singlepose_lightning.tflite` to the current directory.

### 2. Install Dependencies

Install the required CocoaPods:

```bash
pod install
```

This will install TensorFlow Lite Swift framework.

### 3. Create Xcode Project

1. Open Xcode
2. Create a new iOS App project:
   - Product Name: `MoveNetPoseTracker`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Save it in this directory

3. Close the `.xcodeproj` file and open `MoveNetPoseTracker.xcworkspace` instead (important for CocoaPods)

### 4. Add Files to Xcode Project

Add all the Swift files to your project:
- `MoveNetApp.swift` (replace the default App file)
- `ContentView.swift` (replace the default ContentView)
- `CameraManager.swift`
- `MoveNetModel.swift`
- `PoseData.swift`
- `PoseOverlayView.swift`

### 5. Add the Model File

1. Drag `movenet_singlepose_lightning.tflite` into your Xcode project
2. Check "Copy items if needed"
3. Ensure it's added to your app target
4. Verify it appears in Build Phases → Copy Bundle Resources

### 6. Update Info.plist

Replace your project's Info.plist with the provided one, or add these keys:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to perform real-time pose detection using MoveNet.</string>
```

### 7. Configure Build Settings

1. Select your project in Xcode
2. Go to Build Settings
3. Search for "Enable Bitcode" and set it to **No** (TensorFlow Lite doesn't support bitcode)

### 8. Select Your Team

1. Select your project in the navigator
2. Go to "Signing & Capabilities"
3. Select your development team
4. Xcode will automatically handle provisioning

### 9. Build and Run

1. Connect your iOS device
2. Select your device from the scheme menu
3. Click Run (⌘R)
4. Accept camera permissions when prompted

## Troubleshooting

### Model Not Found
- Verify `movenet_singlepose_lightning.tflite` is in your Xcode project
- Check it's listed in Build Phases → Copy Bundle Resources
- Clean build folder (⇧⌘K) and rebuild

### CocoaPods Issues
```bash
pod deintegrate
pod install
```

### Camera Not Working
- Ensure you're running on a physical device (simulator doesn't have camera)
- Check that camera permissions are granted in Settings → Privacy → Camera

### Build Errors
- Make sure you opened `.xcworkspace` not `.xcodeproj`
- Verify bitcode is disabled in build settings
- Clean and rebuild the project

## Performance Tips

- The app should run at 30+ FPS on iPhone 8 and later
- For better performance, ensure good lighting conditions
- Stand 1-2 meters from the camera for optimal detection
- Make sure the full body is visible in the frame

## Model Information

**MoveNet SinglePose Lightning:**
- Input: 192x192 RGB image
- Output: 17 keypoints with (y, x, confidence)
- Model size: ~3MB
- Inference time: ~30ms on modern iOS devices
- Optimized for single person detection

## Next Steps

After successful setup, you can:
- Customize the pose visualization colors in `PoseOverlayView.swift`
- Add pose-based features (e.g., exercise counters, pose classification)
- Record and analyze pose data over time
- Add multiple person tracking (requires different MoveNet model)

## License

This project uses TensorFlow Lite and MoveNet model from Google, licensed under Apache 2.0.

