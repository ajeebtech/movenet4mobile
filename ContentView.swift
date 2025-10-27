//
//  ContentView.swift
//  MoveNet Pose Tracker
//
//  Main view with camera preview and pose overlay
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            // Pose overlay
            PoseOverlayView(pose: cameraManager.currentPose)
                .ignoresSafeArea()
            
            // UI Controls overlay
            VStack {
                // Top bar with info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MoveNet Pose Tracker")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let fps = cameraManager.fps {
                            Text("FPS: \(String(format: "%.1f", fps))")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        
                        if let confidence = cameraManager.currentPose?.averageConfidence {
                            Text("Confidence: \(String(format: "%.0f%%", confidence * 100))")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Camera switch button
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom instructions
                if cameraManager.currentPose == nil {
                    Text("Stand in front of the camera")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStart()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Camera Access"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Camera Preview View using UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        DispatchQueue.main.async {
            let previewLayer = cameraManager.previewLayer
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

