//  /*
//
//  Project: 3DParallaxMotion
//  File: ContentView.swift
//  Created by: Elaidzha Shchukin
//  Date: 21.04.2024
//
//  */

import SwiftUI
import CoreMotion

struct ContentView: View {
    @State var motion: CMDeviceMotion? = nil
    let motionManager = CMMotionManager()
    
    let thresholdPitch: Double = 35 * .pi / 180
    let maxRotationAngle = 20
    
    var rotation: (x: Double, y: Double) {
        if let motion = motion {
            let pitchDegrees: Double = min(Double(maxRotationAngle), motion.attitude.pitch > thresholdPitch ? (motion.attitude.pitch - thresholdPitch) * (100 / .pi) : 0)
            let rollDegrees: Double = min(Double(maxRotationAngle), motion.attitude.roll * (100 / .pi))
            return (x: -pitchDegrees, y: rollDegrees)
        }
        return (x: 0, y: 0)
    }
    
    var circleYOffset: CGFloat {
        if let motion = motion, motion.attitude.pitch > thresholdPitch {
            return CGFloat((motion.attitude.pitch - thresholdPitch) * 600 / .pi)
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            Image("nft")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black, radius: 10, x: 0, y:  0)
                .rotation3DEffect(
                    .init(degrees: rotation.x),
                    axis: (x: 1.0, y: 1.0, z: 0.0)
                )
                .rotation3DEffect(
                    .init(degrees: rotation.y),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            
            Circle()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.white.opacity(0.6))
                .blur(radius: 40)
                .offset(x: motion != nil ? CGFloat(motion!.gravity.x * 500) : 0, y: circleYOffset)
                .mask(
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 350)
                        .rotation3DEffect(
                            .init(degrees: rotation.x),
                            axis: (x: 1.0, y: 1.0, z: 0.0)
                        )
                        .rotation3DEffect(
                            .init(degrees: rotation.y),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                )
                .onAppear {
                    if motionManager.isDeviceMotionAvailable {
                        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60
                        self.motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                            if let validData = data {
                                self.motion = validData
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
