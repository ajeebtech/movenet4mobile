//
//  CameraManager.swift
//  MoveNet Pose Tracker
//
//  Manages camera capture and frame processing
//

import AVFoundation
import UIKit
import Combine

class CameraManager: NSObject, ObservableObject {
    // Published properties for UI updates
    @Published var currentPose: Pose?
    @Published var fps: Double?
    
    // Camera session
    private let captureSession = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer
    
    // Video output
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "com.movenet.videoQueue", qos: .userInteractive)
    
    // MoveNet model
    private let moveNetModel = MoveNetModel()
    
    // Camera position
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // FPS tracking
    private var lastFrameTime = Date()
    private var frameCount = 0
    private var fpsUpdateTime = Date()
    
    override init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        super.init()
    }
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            print("Camera access denied")
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCameraPosition
        ) else {
            print("Failed to get camera device")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Failed to create video input: \(error)")
            return
        }
        
        // Configure video output
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Set video orientation
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        captureSession.commitConfiguration()
        
        // Start session on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func switchCamera() {
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        captureSession.stopRunning()
        
        // Remove existing inputs
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        
        setupCamera()
    }
    
    func stopCamera() {
        captureSession.stopRunning()
    }
    
    private func updateFPS() {
        frameCount += 1
        let now = Date()
        let elapsed = now.timeIntervalSince(fpsUpdateTime)
        
        if elapsed >= 1.0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.fps = Double(self.frameCount) / elapsed
                self.frameCount = 0
                self.fpsUpdateTime = now
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Update FPS
        updateFPS()
        
        // Convert to UIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        // Run pose detection
        if let pose = moveNetModel.detectPose(in: image) {
            DispatchQueue.main.async { [weak self] in
                self?.currentPose = pose
            }
        }
    }
}

