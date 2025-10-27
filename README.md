# MoveNet Pose Tracking iOS App

A real-time on-device pose tracking app using Google's MoveNet model with TensorFlow Lite on iOS.

## Features

- Real-time pose detection using device camera
- On-device inference with TensorFlow Lite
- Visual overlay of detected keypoints and skeleton
- Supports both front and back camera
- Optimized for mobile performance

## Requirements

- iOS 14.0+
- Xcode 13.0+
- CocoaPods

## Installation

1. Install CocoaPods if you haven't already:
```bash
sudo gem install cocoapods
```

2. Install dependencies:
```bash
pod install
```

3. Download MoveNet model:
   - Download the MoveNet SinglePose Lightning model from TensorFlow Hub
   - Place `movenet_singlepose_lightning.tflite` in the project directory
   - Or download from: https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/int8/4

4. Open the project:
```bash
open MoveNetPoseTracker.xcworkspace
```

5. Build and run on a physical device (camera required)

## Model Information

This app uses MoveNet SinglePose Lightning, which:
- Detects 17 keypoints on a single person
- Runs at 30+ FPS on modern iOS devices
- Works entirely on-device without internet connection
- Input: 192x192 RGB image
- Output: 17 keypoints with (y, x, confidence) coordinates

## Keypoints Detected

1. Nose
2. Left Eye
3. Right Eye
4. Left Ear
5. Right Ear
6. Left Shoulder
7. Right Shoulder
8. Left Elbow
9. Right Elbow
10. Left Wrist
11. Right Wrist
12. Left Hip
13. Right Hip
14. Left Knee
15. Right Knee
16. Left Ankle
17. Right Ankle

## Project Structure

- `MoveNetApp.swift` - Main app entry point
- `ContentView.swift` - Main UI view
- `CameraManager.swift` - Camera capture and frame processing
- `MoveNetModel.swift` - TensorFlow Lite model handling
- `PoseOverlayView.swift` - Visual rendering of pose keypoints
- `PoseData.swift` - Data structures for pose information

## License

MIT License - Feel free to use this code for your projects.

