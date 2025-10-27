//
//  MoveNetModel.swift
//  MoveNet Pose Tracker
//
//  TensorFlow Lite model handler for MoveNet pose detection
//

import UIKit
import TensorFlowLite
import CoreGraphics
import Accelerate

class MoveNetModel {
    // Model configuration
    private let modelFileName = "movenet_singlepose_lightning"
    private let inputWidth = 192
    private let inputHeight = 192
    private let numberOfKeypoints = 17
    
    // TensorFlow Lite interpreter
    private var interpreter: Interpreter?
    
    // Thread count for inference
    private let threadCount = 2
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        guard let modelPath = Bundle.main.path(
            forResource: modelFileName,
            ofType: "tflite"
        ) else {
            print("Failed to load model from bundle. Please add \(modelFileName).tflite to your project.")
            return
        }
        
        do {
            // Create interpreter options
            var options = Interpreter.Options()
            options.threadCount = threadCount
            
            // Create the interpreter
            interpreter = try Interpreter(modelPath: modelPath, options: options)
            
            // Allocate tensors
            try interpreter?.allocateTensors()
            
            print("MoveNet model loaded successfully")
            
            // Print input/output tensor info for debugging
            if let inputTensor = try? interpreter?.input(at: 0) {
                print("Input tensor shape: \(inputTensor.shape)")
                print("Input tensor data type: \(inputTensor.dataType)")
            }
            
        } catch {
            print("Failed to create interpreter: \(error)")
        }
    }
    
    func detectPose(in image: UIImage) -> Pose? {
        guard let interpreter = interpreter else {
            return nil
        }
        
        // Preprocess image
        guard let inputData = preprocessImage(image) else {
            return nil
        }
        
        do {
            // Copy input data to interpreter
            try interpreter.copy(inputData, toInputAt: 0)
            
            // Run inference
            try interpreter.invoke()
            
            // Get output tensor
            let outputTensor = try interpreter.output(at: 0)
            
            // Parse output
            let keypoints = parseOutput(outputTensor)
            
            return Pose(keypoints: keypoints, timestamp: Date())
            
        } catch {
            print("Failed to run inference: \(error)")
            return nil
        }
    }
    
    private func preprocessImage(_ image: UIImage) -> Data? {
        // Resize and convert to RGB format expected by MoveNet
        guard let resizedImage = image.resized(to: CGSize(
            width: inputWidth,
            height: inputHeight
        )) else {
            return nil
        }
        
        guard let pixelBuffer = resizedImage.pixelBuffer() else {
            return nil
        }
        
        // Convert pixel buffer to input tensor format
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        var inputData = Data()
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * bytesPerRow + x * 4
                let pixel = baseAddress.advanced(by: pixelIndex)
                
                // Get RGB values (BGRA format)
                let b = pixel.load(fromByteOffset: 0, as: UInt8.self)
                let g = pixel.load(fromByteOffset: 1, as: UInt8.self)
                let r = pixel.load(fromByteOffset: 2, as: UInt8.self)
                
                // Append RGB bytes
                inputData.append(r)
                inputData.append(g)
                inputData.append(b)
            }
        }
        
        return inputData
    }
    
    private func parseOutput(_ outputTensor: Tensor) -> [Keypoint] {
        // MoveNet output format: [1, 1, 17, 3]
        // 17 keypoints with [y, x, confidence] for each
        
        guard let data = [Float](unsafeData: outputTensor.data) else {
            return []
        }
        
        var keypoints: [Keypoint] = []
        
        for i in 0..<numberOfKeypoints {
            let baseIndex = i * 3
            
            let y = CGFloat(data[baseIndex])      // Normalized y (0-1)
            let x = CGFloat(data[baseIndex + 1])  // Normalized x (0-1)
            let confidence = data[baseIndex + 2]
            
            if let keypointType = KeypointType(rawValue: i) {
                let keypoint = Keypoint(
                    position: CGPoint(x: x, y: y),
                    confidence: confidence,
                    type: keypointType
                )
                keypoints.append(keypoint)
            }
        }
        
        return keypoints
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
    }
}

// MARK: - Array Extension for Tensor Data
extension Array where Element == Float {
    init?(unsafeData: Data) {
        guard unsafeData.count % MemoryLayout<Float>.stride == 0 else {
            return nil
        }
        
        self = unsafeData.withUnsafeBytes { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }
}

