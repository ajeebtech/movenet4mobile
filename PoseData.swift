//
//  PoseData.swift
//  MoveNet Pose Tracker
//
//  Data structures for pose estimation
//

import Foundation
import CoreGraphics

// Represents a single keypoint in the pose
struct Keypoint {
    let position: CGPoint  // Normalized coordinates (0-1)
    let confidence: Float
    let type: KeypointType
    
    var isValid: Bool {
        return confidence > 0.3  // Threshold for considering a keypoint valid
    }
}

// MoveNet keypoint types (17 keypoints)
enum KeypointType: Int, CaseIterable {
    case nose = 0
    case leftEye = 1
    case rightEye = 2
    case leftEar = 3
    case rightEar = 4
    case leftShoulder = 5
    case rightShoulder = 6
    case leftElbow = 7
    case rightElbow = 8
    case leftWrist = 9
    case rightWrist = 10
    case leftHip = 11
    case rightHip = 12
    case leftKnee = 13
    case rightKnee = 14
    case leftAnkle = 15
    case rightAnkle = 16
    
    var name: String {
        switch self {
        case .nose: return "Nose"
        case .leftEye: return "Left Eye"
        case .rightEye: return "Right Eye"
        case .leftEar: return "Left Ear"
        case .rightEar: return "Right Ear"
        case .leftShoulder: return "Left Shoulder"
        case .rightShoulder: return "Right Shoulder"
        case .leftElbow: return "Left Elbow"
        case .rightElbow: return "Right Elbow"
        case .leftWrist: return "Left Wrist"
        case .rightWrist: return "Right Wrist"
        case .leftHip: return "Left Hip"
        case .rightHip: return "Right Hip"
        case .leftKnee: return "Left Knee"
        case .rightKnee: return "Right Knee"
        case .leftAnkle: return "Left Ankle"
        case .rightAnkle: return "Right Ankle"
        }
    }
}

// Represents the full pose with all keypoints
struct Pose {
    let keypoints: [Keypoint]
    let timestamp: Date
    
    var averageConfidence: Float {
        let validKeypoints = keypoints.filter { $0.isValid }
        guard !validKeypoints.isEmpty else { return 0 }
        return validKeypoints.reduce(0) { $0 + $1.confidence } / Float(validKeypoints.count)
    }
    
    func keypoint(for type: KeypointType) -> Keypoint? {
        return keypoints.first { $0.type == type }
    }
    
    // Skeleton connections for drawing
    static let connections: [(KeypointType, KeypointType)] = [
        // Face
        (.leftEar, .leftEye),
        (.leftEye, .nose),
        (.nose, .rightEye),
        (.rightEye, .rightEar),
        
        // Torso
        (.leftShoulder, .rightShoulder),
        (.leftShoulder, .leftHip),
        (.rightShoulder, .rightHip),
        (.leftHip, .rightHip),
        
        // Left arm
        (.leftShoulder, .leftElbow),
        (.leftElbow, .leftWrist),
        
        // Right arm
        (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist),
        
        // Left leg
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),
        
        // Right leg
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle)
    ]
}

