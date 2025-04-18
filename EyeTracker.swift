//
//  EyeTracker.swift
//  ADHD Screener
//
//  Created by Jeremy Zhou on 7/1/2025.
//

import SwiftUI
import ARKit
import RealityKit
import Charts

struct EyePosition: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    
    let timestamp: Float
    let x: Float
    let y: Float
}

public class EyeTrackARView: ARView, ARSessionDelegate, ObservableObject {

    @Published public var eyePosition = CGPoint()
    @Published public var isWinking = false
    @Published public var blinkCount = 0
    
    // List of data for graph
    public var raw_positions: [CGPoint] = []
    var timestamps: [Float] = []
    
    var calibrating = false
    var tracking = false
    var calibrating_step = 0
    private var deviation = CGPoint()
    
    private var bottom_right_multiplier = CGPoint(x: 1, y: 1)
    private var bottom_left_multiplier = CGPoint(x: 1, y: 1)
    private var top_right_multiplier = CGPoint(x: 1, y: 1)
    private var top_left_multiplier = CGPoint(x: 1, y: 1)
    
    // Calibration raw points
    var c_raw_points: [CGPoint] = []
    var c_screen_points: [CGPoint] = []
    
    var current_average: [CGPoint] = []
    
    // get data after a certain while
    private var time: TimeInterval = 0
    private var time_started: TimeInterval = 0

    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented!")
    }
    
    dynamic required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented!")
    }
    
    init() {
        super.init(frame: .zero)
        
        session.delegate = self
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        // calibration points
        
        c_screen_points = [
            CGPoint(x: width/2, y: height/2),
            CGPoint(x: width * 0.9, y: height * 0.9),
            CGPoint(x: width * 0.1, y: height * 0.1),
            CGPoint(x: width * 0.9, y: height * 0.1),
            CGPoint(x: width * 0.1, y: height * 0.9)
        ]
        
        // before calibration
        c_raw_points = [
            CGPoint(),
            CGPoint(),
            CGPoint(),
            CGPoint(),
            CGPoint()
        ]
        
        // Face tracking config!
        let config = ARFaceTrackingConfiguration()
        session.run(config)
        
        
        
        print("Initialized!")
        
        
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        time = frame.timestamp
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        
        guard let faceAnchor = session.currentFrame?.anchors.compactMap({$0 as? ARFaceAnchor}).first else {
            return
        }
        
        if (tracking) {
            trackEyes(faceAnchor: faceAnchor)
            detectWink(faceAnchor: faceAnchor)
        }
        
        if (calibrating) {
            calibrate(eyePosition: eyePosition, calibration_step: calibrating_step)
        }
        
    }
    
    public func pauseSession() {
        session.pause()
    }
    
    public func continueSession() {
        let config = ARFaceTrackingConfiguration()
        session.run(config)
    }
    
    func trackEyes(faceAnchor: ARFaceAnchor) {
        // Track the eyes here

        // Width and Height
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        // Credit to Shiru99 for calculation and the awesome medium article that taught me how it works!!
        let lookAtPoint = faceAnchor.lookAtPoint
                
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }
        
        let lookAtPointInWorld = faceAnchor.transform * simd_float4(lookAtPoint, 1)
        
        let transformedLookAtPoint = simd_mul(simd_inverse(cameraTransform), lookAtPointInWorld)
        
        var screenX = (transformedLookAtPoint.y / (Float(width) / 2)) * Float(width) * Float(width) // Portrait by default
        var screenY = (transformedLookAtPoint.x / (Float(height) / 2)) * Float(height) * Float(height)
        
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            screenX = (transformedLookAtPoint.x / (Float(width) / 2)) * Float(width) * Float(width)
            screenY = Float(height) - ((transformedLookAtPoint.y / (Float(height) / 2)) * Float(height) * Float(height))
            
        } 

        
        var focusPoint = CGPoint()

        if (!calibrating) {
            
            focusPoint = CGPoint(
                x: (CGFloat(screenX) - deviation.x),
                y: (CGFloat(screenY) - deviation.y)
            )
            // Top right area
            if (focusPoint.x >= width/2 && focusPoint.y <= height/2) {
                focusPoint.x = ((focusPoint.x - width/2) * top_right_multiplier.x) + width/2
                focusPoint.y = ((focusPoint.y - height/2) * top_right_multiplier.y) + height/2
            }
            
            // Top left area
            else if (focusPoint.x < width/2 && focusPoint.y <= height/2) {
                focusPoint.x = ((focusPoint.x - width/2) * top_left_multiplier.x) + width/2
                focusPoint.y = ((focusPoint.y - height/2) * top_left_multiplier.y) + height/2
            }
            
            // Bottom right area
            else if (focusPoint.x >= width/2 && focusPoint.y > height/2) {
                focusPoint.x = ((focusPoint.x - width/2) * bottom_right_multiplier.x) + width/2
                focusPoint.y = ((focusPoint.y - height/2) * bottom_right_multiplier.y) + height/2
            }
            
            // Bottom left area
            else if (focusPoint.x < width/2 && focusPoint.y > height/2) {
                focusPoint.x = ((focusPoint.x - width/2) * bottom_left_multiplier.x) + width/2
                focusPoint.y = ((focusPoint.y - height/2) * bottom_left_multiplier.y) + height/2
            }
            
            // Clamp point to screen
            focusPoint.x = max(0, min(focusPoint.x, width))
            focusPoint.y = max(0, min(focusPoint.y, height))

        } else {
            if calibrating_step == 1 {
                
                focusPoint = CGPoint(
                    x: CGFloat(screenX),
                    y: CGFloat(screenY)
                )
            }
            else {
                focusPoint = CGPoint(
                    x: (CGFloat(screenX) - deviation.x),
                    y: (CGFloat(screenY) - deviation.y)
                )
                
            }
        }
        
        self.raw_positions.append(focusPoint)
        self.timestamps.append(Float(time-time_started))
        
        DispatchQueue.main.async {
            self.eyePosition = focusPoint
        }
        
    }
    
    public func calibrate(eyePosition: CGPoint, calibration_step: Int) {
        
        self.current_average.append(eyePosition)
        
    }
    
    public func refreshAverage() {
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let sum = current_average.reduce(CGPoint.zero) { partialResult, point in
            CGPoint(x: partialResult.x + point.x, y: partialResult.y + point.y)
        }
        let count = CGFloat(current_average.count)
        let average = CGPoint(x: sum.x / count, y: sum.y / count)
        
        c_raw_points[calibrating_step-1] = average
        

        switch calibrating_step {
            
        // 1 not included because it is deviation from center
        case 1:
            self.deviation = CGPoint(x: average.x-(width/2), y: average.y-(height/2))
            
        case 2:
            self.bottom_right_multiplier.x = abs(width / ((average.x) - (width / 2))) / 2
            self.bottom_right_multiplier.y = abs(height / ((average.y) - (height / 2))) / 2
            print(self.bottom_right_multiplier)
            break
        
        case 3:
            self.bottom_left_multiplier.x = abs(width / ((width / 2) - average.x)) / 2
            self.bottom_left_multiplier.y = abs(height / ((average.y) - (height / 2))) / 2
            print(self.bottom_left_multiplier)
            break
            
            
        case 4:
            self.top_left_multiplier.x = abs(width / ((width / 2) - average.x)) / 2
            self.top_left_multiplier.y = abs(height / ((height / 2) - average.y)) / 2
            print(self.top_left_multiplier)
            break
            
        
        case 5:
            self.top_right_multiplier.x = abs(width / ((average.x) - (width / 2))) / 2
            self.top_right_multiplier.y = abs(height / ((height / 2) - average.y)) / 2
            print(self.top_right_multiplier)
            break
        
        case -1:
            // Tracking, not calibrating
            break
        
        default:
            print("Wrong calibrating step for multiplier!")
        
        }
        
        self.current_average = []
    }
    
    func getEyePosition() -> CGPoint {
        return eyePosition
    }
    
    func detectWink(faceAnchor: ARFaceAnchor) {
            
        let blendShapes = faceAnchor.blendShapes
        
        if let leftEyeBlink = blendShapes[.eyeBlinkLeft] as? Float,
           let rightEyeBlink = blendShapes[.eyeBlinkRight] as? Float {
            if leftEyeBlink > 0.75 && rightEyeBlink > 0.75 {
                
                if !self.isWinking {
                    self.blinkCount += 1
                }
                
                self.isWinking = true
                
            } else {
                
                self.isWinking = false
                
            }
        }
    }

    func calculateMicroSaccadeNum() -> [EyePosition] {
        var converted: [(velocity: CGFloat, displacement: CGFloat)] = []
        
        for index in 1..<raw_positions.count {
            let previous_position = raw_positions[index - 1]
            let current_position = raw_positions[index]
            let previous_timestamp = timestamps[index - 1]
            let current_timestamp = timestamps[index]
            
            let dx = current_position.x - previous_position.x
            let dy = current_position.y - previous_position.y
            let displacement = sqrt(dx * dx + dy * dy)
            
            let dt = CGFloat(current_timestamp - previous_timestamp)
            let velocity = dt > 0 ? displacement / dt : 0
            
            converted.append((velocity: velocity, displacement: displacement))
        }
        
        var micro_saccades: [EyePosition] = []
        
        var average_velocity: CGFloat = 0
        for data in converted {
            average_velocity += data.velocity
        }
        average_velocity /= CGFloat(converted.count)
        
        
        for (index, data) in converted.enumerated() {
            
            
            let velocity_threshold = average_velocity * 6
            let displacement_threshold = 0.1
            
            if data.velocity > velocity_threshold && data.displacement > displacement_threshold {
                micro_saccades.append(EyePosition(timestamp: timestamps[index], x: Float(raw_positions[index].x), y: Float(raw_positions[index].y)))
            }
            
        }
        
        return micro_saccades
    }
    
    func returnMicroSaccadesCount() -> Int {
        return calculateMicroSaccadeNum().count
    }
    
    func returnData() -> [EyePosition] {
        
        var eye_positions: [EyePosition] = []
        
        
        for index in 0..<raw_positions.count {
            eye_positions.append(EyePosition(timestamp: timestamps[index], x: Float(width - raw_positions[index].x), y: Float(height - raw_positions[index].y)))
        }
        

        return eye_positions
    }
    
    func resetRawPositionsAndTime() {
        raw_positions = []
        time_started = time
    }
    
    
}
