//
//  PoseOverlayView.swift
//  MoveNet Pose Tracker
//
//  Visual overlay for rendering detected pose keypoints and skeleton
//

import SwiftUI

struct PoseOverlayView: View {
    let pose: Pose?
    
    var body: some View {
        GeometryReader { geometry in
            if let pose = pose {
                ZStack {
                    // Draw skeleton connections
                    ForEach(Array(Pose.connections.enumerated()), id: \.offset) { index, connection in
                        if let startKeypoint = pose.keypoint(for: connection.0),
                           let endKeypoint = pose.keypoint(for: connection.1),
                           startKeypoint.isValid,
                           endKeypoint.isValid {
                            
                            Path { path in
                                let start = denormalizePoint(
                                    startKeypoint.position,
                                    in: geometry.size
                                )
                                let end = denormalizePoint(
                                    endKeypoint.position,
                                    in: geometry.size
                                )
                                
                                path.move(to: start)
                                path.addLine(to: end)
                            }
                            .stroke(
                                lineColor(for: startKeypoint.confidence),
                                style: StrokeStyle(
                                    lineWidth: 3,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        }
                    }
                    
                    // Draw keypoints
                    ForEach(Array(pose.keypoints.enumerated()), id: \.offset) { index, keypoint in
                        if keypoint.isValid {
                            let point = denormalizePoint(keypoint.position, in: geometry.size)
                            
                            Circle()
                                .fill(keypointColor(for: keypoint.confidence))
                                .frame(width: 12, height: 12)
                                .position(point)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                }
            }
        }
    }
    
    private func denormalizePoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        // Convert normalized coordinates (0-1) to screen coordinates
        return CGPoint(
            x: point.x * size.width,
            y: point.y * size.height
        )
    }
    
    private func keypointColor(for confidence: Float) -> Color {
        // Color based on confidence level
        if confidence > 0.7 {
            return Color.green
        } else if confidence > 0.5 {
            return Color.yellow
        } else {
            return Color.orange
        }
    }
    
    private func lineColor(for confidence: Float) -> Color {
        // Slightly transparent version of keypoint color for lines
        if confidence > 0.7 {
            return Color.green.opacity(0.8)
        } else if confidence > 0.5 {
            return Color.yellow.opacity(0.8)
        } else {
            return Color.orange.opacity(0.8)
        }
    }
}

struct PoseOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample pose for preview
        let sampleKeypoints = KeypointType.allCases.map { type in
            Keypoint(
                position: CGPoint(
                    x: CGFloat.random(in: 0.2...0.8),
                    y: CGFloat.random(in: 0.2...0.8)
                ),
                confidence: 0.8,
                type: type
            )
        }
        
        let samplePose = Pose(keypoints: sampleKeypoints, timestamp: Date())
        
        return PoseOverlayView(pose: samplePose)
            .background(Color.black)
    }
}

