# Project Structure

This document explains the architecture and file organization of the MoveNet Pose Tracker app.

## File Overview

```
movenet4mobile/
│
├── Swift Source Files
│   ├── MoveNetApp.swift           # App entry point
│   ├── ContentView.swift          # Main UI view with camera preview
│   ├── CameraManager.swift        # Camera capture and frame processing
│   ├── MoveNetModel.swift         # TensorFlow Lite model interface
│   ├── PoseData.swift             # Data structures for pose/keypoints
│   └── PoseOverlayView.swift      # Visual rendering of detected pose
│
├── Configuration
│   ├── Info.plist                 # App configuration and permissions
│   ├── Podfile                    # CocoaPods dependencies
│   └── .gitignore                 # Git ignore rules
│
├── Documentation
│   ├── README.md                  # Project overview and features
│   ├── SETUP.md                   # Detailed setup instructions
│   ├── QUICKSTART.md              # Quick start guide
│   └── PROJECT_STRUCTURE.md       # This file
│
├── Scripts
│   └── download_model.sh          # Downloads MoveNet TFLite model
│
└── Model (generated)
    └── movenet_singlepose_lightning.tflite  # MoveNet model file
```

## Architecture

### Layer 1: UI Layer (SwiftUI)
- **MoveNetApp.swift**: Application entry point using SwiftUI App protocol
- **ContentView.swift**: Main view composing camera preview, pose overlay, and controls
- **PoseOverlayView.swift**: Custom view for drawing keypoints and skeleton

### Layer 2: Business Logic
- **CameraManager.swift**: Orchestrates camera capture and connects to model
  - Manages AVCaptureSession
  - Handles camera permissions
  - Processes video frames
  - Calculates FPS
  - Publishes pose updates

### Layer 3: Model Layer
- **MoveNetModel.swift**: TensorFlow Lite model wrapper
  - Loads .tflite model
  - Preprocesses images (resize to 192x192)
  - Runs inference
  - Parses output tensors into keypoints

### Layer 4: Data Layer
- **PoseData.swift**: Core data structures
  - `Keypoint`: Single body point with position and confidence
  - `KeypointType`: Enum of 17 MoveNet keypoint types
  - `Pose`: Collection of keypoints with metadata
  - Skeleton connection definitions

## Data Flow

```
Camera → CameraManager → MoveNetModel → Pose → PoseOverlayView
   ↓           ↓              ↓           ↓          ↓
 Frame    CMSampleBuffer  UIImage    Keypoints  Visual Render
```

### Detailed Flow

1. **Camera Capture** (CameraManager)
   - AVCaptureSession captures video frames
   - Delegate receives CMSampleBuffer

2. **Frame Processing** (CameraManager)
   - Convert CMSampleBuffer to UIImage
   - Pass to MoveNet model

3. **Inference** (MoveNetModel)
   - Resize image to 192x192
   - Convert to RGB tensor
   - Run TensorFlow Lite inference
   - Parse output into keypoints

4. **UI Update** (ContentView + PoseOverlayView)
   - Receive Pose via @Published property
   - Draw keypoints and skeleton
   - Update FPS counter

## Key Components

### CameraManager (ObservableObject)
```swift
@Published var currentPose: Pose?
@Published var fps: Double?
```
- Manages camera lifecycle
- Implements AVCaptureVideoDataOutputSampleBufferDelegate
- Runs inference on background queue
- Updates UI on main thread

### MoveNetModel
```swift
func detectPose(in image: UIImage) -> Pose?
```
- Encapsulates TensorFlow Lite interpreter
- Thread-safe inference
- Returns structured pose data

### Pose Visualization
- Uses SwiftUI Path and GeometryReader
- Normalizes coordinates (0-1) to screen space
- Color-codes confidence levels:
  - Green: >70%
  - Yellow: 50-70%
  - Orange: 30-50%

## Performance Considerations

### Camera Processing
- Video queue runs on background thread (QoS: userInteractive)
- Prevents blocking main thread
- Frame drops gracefully under load

### Model Inference
- Uses 2 CPU threads for TensorFlow Lite
- ~30ms per frame on modern devices
- Input size: 192x192 (balance of speed/accuracy)

### UI Updates
- Only updates on main thread
- Uses @Published for reactive updates
- Efficient SwiftUI rendering

## Extension Points

### Adding New Features

1. **Pose Classification**
   - Create `PoseClassifier.swift`
   - Analyze keypoint positions
   - Return pose type (standing, sitting, etc.)

2. **Exercise Counting**
   - Track keypoint movements over time
   - Detect repetitive patterns
   - Count reps (squats, push-ups, etc.)

3. **Multi-Person Support**
   - Switch to MoveNet MultiPose model
   - Update output parsing for multiple poses
   - Modify overlay to handle arrays of poses

4. **Recording/Replay**
   - Store pose sequences with timestamps
   - Save to CoreData or JSON
   - Add playback visualization

## Dependencies

### External
- **TensorFlowLiteSwift** (~2.13.0)
  - Provides ML inference runtime
  - Includes Metal acceleration support

### iOS Frameworks
- **SwiftUI**: Modern declarative UI
- **AVFoundation**: Camera capture
- **CoreGraphics**: Coordinate transformations
- **Accelerate**: Performance primitives (future optimization)

## Build Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+
- CocoaPods for dependency management

## Model Specifications

**MoveNet SinglePose Lightning (INT8 Quantized)**
- Input: [1, 192, 192, 3] uint8 RGB tensor
- Output: [1, 1, 17, 3] float32 tensor
- 17 keypoints × (y, x, confidence)
- Model size: ~3MB
- Optimized for mobile inference

## Future Improvements

1. **Performance**
   - Add Metal GPU acceleration
   - Implement frame skipping for older devices
   - Use Vision framework for pre-processing

2. **Features**
   - Add pose history tracking
   - Implement smoothing/filtering
   - Add 3D pose estimation

3. **UI/UX**
   - Add settings screen
   - Configurable visualization options
   - Dark/light mode support
   - Landscape orientation support

4. **Code Quality**
   - Add unit tests
   - Add UI tests
   - Improve error handling
   - Add logging framework

## License

All code is provided as-is for educational and commercial use. TensorFlow Lite and MoveNet are licensed under Apache 2.0 by Google.

