//
//  ContentView.swift
//  ADHD Screener
//
//  Created by Jeremy Zhou on 7/1/2025.
//

import SwiftUI

struct RandomDots {
    var circles: Int
    var positions: [CGPoint]
    var colors: [Color]
    var sizes: [Int]
}

struct EyeTrackingTest: View {
    
    
    @StateObject var eyeTracker = EyeTrackARView()
    
    @State private var moveCircleAnimation = false
    @State private var calibratingDone = false
    @State private var testing = false
    @State private var newCircle = false // new circle placed in random position
    @State private var random_dots = RandomDots(circles: 1, positions: [CGPoint(x: 0, y: 0)], colors: [Color(red: 0, green: 0, blue: 0)], sizes: [])
    
    @Binding var currentView: CurrentView
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    func startCalibration() async {
        // Start calibration
        await MainActor.run {
            eyeTracker.tracking = true
            eyeTracker.calibrating = true
            eyeTracker.calibrating_step = 0
        }
        
        try? await Task.sleep(for: .seconds(0.1))
        
        await MainActor.run {
            moveCircleAnimation = true
        }
        
        try? await Task.sleep(for: .seconds(0.9))
        
        await MainActor.run {
            eyeTracker.calibrating_step = 1
        }
        
        // Calibrate - show circles on screen
        for _ in 0..<5 {
            try? await Task.sleep(for: .seconds(0.1)) // Add short delay so program can detect
            
            await MainActor.run {
                moveCircleAnimation = true
            }
            
            try? await Task.sleep(for: .seconds(4.9))
            
            await MainActor.run {
                eyeTracker.refreshAverage()
                eyeTracker.calibrating_step += 1
                moveCircleAnimation = false
            }
        }
        
        await MainActor.run {
            eyeTracker.calibrating_step = -1
        }
        try? await Task.sleep(for: .seconds(0.1))
        // End calibration
        await MainActor.run {
            moveCircleAnimation = true
            eyeTracker.calibrating = false
            eyeTracker.pauseSession()
        }
        try? await Task.sleep(for: .seconds(0.9))
        
        await MainActor.run {
            calibratingDone = true
        }
        
    }

    
    func startTracking() async {
        
        await MainActor.run {
            eyeTracker.continueSession()
            
            calibratingDone = false
            testing = true
        }
        
        try? await Task.sleep(for: .seconds(0.1)) // Add short delay so program can detect
        await MainActor.run {
            moveCircleAnimation = true
            eyeTracker.resetRawPositionsAndTime()
            eyeTracker.tracking = true
        }
        
        
        // Get random timings
        var timings: [Double] = []
        
        while timings.reduce(0, +) < 15 {
            timings.append(Double.random(in: 0.9...1.8))
            
        }
        
        timings.append(15 - timings.reduce(0, +))
        
        try? await Task.sleep(for: .seconds(5)) // Wait 5 seconds before dots start spawning
        
        for timing in timings {
            newCircle = true
            random_dots.circles = Int.random(in: 1...4)
            
            // Random positions, colors and cizes for circles - serve as a distraction
            var positions: [CGPoint] = []
            var colors: [Color] = []
            var sizes: [Int] = []
            for _ in 0...random_dots.circles {
                positions.append(CGPoint(x: CGFloat(Int.random(in: 0...Int(width))), y: CGFloat(Int.random(in: 0...Int(height)))))
                colors.append(Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)))
                sizes.append(Int.random(in: 40...80))
            }
            random_dots.positions = positions
            random_dots.colors = colors
            random_dots.sizes = sizes
            
            try? await Task.sleep(for: .seconds(timing))
            newCircle = false
        }
        
        
        // Finished tracking - stop tracking and store data
        await MainActor.run {
            eyeTracker.tracking = false
            CurrentResults.eye_locations = eyeTracker.returnData()
            CurrentResults.num_saccades = eyeTracker.returnMicroSaccadesCount()
            CurrentResults.num_blinks = eyeTracker.blinkCount
        }
        
        

    }

    var body: some View {
        
        
        ZStack {
            if (!eyeTracker.tracking) {
                ZStack {
                    VStack {
                        Spacer()
                        Text("The Eye Tracking process will now begin. You must first calibrate.")
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        Text("Five dots will appear on the screen in sequence. Follow them with your head whilst staring at them as they appear.")
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                        Text("Please do not move your head or device while calibrating or testing.")
                            .font(.system(size: 25, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                        Spacer()
                        Button(action: {
                            Task {
                                await startCalibration()
                            }
                        }) {
                            Text("Calibrate")
                                .font(.system(size: 45, weight: .medium).monospaced())
                                .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                                .frame(width: 300, height: 75)
                                .contentShape(Rectangle())
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 40,
                                        style: .continuous
                                    )
                                    .fill(Color(red: 94/255, green: 129/255, blue: 172/255))
                                    .opacity(1)
                                )
                                .hoverEffect(.lift)
                                .padding([.leading, .trailing])
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 320) // Adjust vals later
                    .background(.thinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 6)
                    .padding(30)
                    
                }
                .frame(maxWidth: width * 0.8, maxHeight: .infinity)
                .background(ZStack {
                    Image("Background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(.all)
                    Color(red: 46/255, green: 52/255, blue: 64/255)
                        .opacity(0.85)
                        .ignoresSafeArea(.all)
                })
                .ignoresSafeArea(.all)
                

            } 
            
            if newCircle {
                ForEach(0...random_dots.circles, id: \.self) { i in
                    Circle()
                        .fill(random_dots.colors[i])
                        .frame(width: CGFloat(random_dots.sizes[i]), height: CGFloat(random_dots.sizes[i]))
                        .position(random_dots.positions[i])
                        
                }

            }
            
            // Calibration done
            ZStack {
                VStack {
                    Spacer()
                    Text("Calibration is complete. The test will begin once you click Next.")
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Text("Dots of random colors will appear across your screen. Please fixate your gaze at the dot at the center.")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    Text("Please do not move your head or device while calibrating or testing.")
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    Spacer()
                    Button(action: {
                        Task {
                            await startTracking()
                            await MainActor.run {
                                eyeTracker.pauseSession()
                                currentView = .eyeTrackingTestDone
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 45, weight: .medium).monospaced())
                            .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                            .frame(width: 300, height: 75)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 40,
                                    style: .continuous
                                )
                                .fill(Color(red: 94/255, green: 129/255, blue: 172/255))
                                .opacity(1)
                            )
                            .hoverEffect(.lift)
                            .padding([.leading, .trailing])
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 320) // Adjust vals later
                .background(.thinMaterial)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 6)
                .padding(30)
                
                
            }
            .frame(maxWidth: width * 0.8, maxHeight: .infinity)
            .background(ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                Color(red: 46/255, green: 52/255, blue: 64/255)
                    .opacity(0.85)
                    .ignoresSafeArea(.all)
            })
            .ignoresSafeArea(.all)
            .opacity(calibratingDone ? 1 : 0)
            .animation(.easeInOut(duration: 0.9), value: calibratingDone)
            
            
            
            
            Circle()
                .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                .frame(width: 40, height: 40)
                .position(x: width * 0.5, y: height * 0.5)
                .opacity(testing ? 1 : 0)
                .animation(.linear(duration: 0.9), value: testing)
            
            // Show distractions on screen
            
            
            
            // Calibration dots
            if eyeTracker.calibrating_step == 0 { // fade in
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.5, y: height * 0.5)
                    .opacity(moveCircleAnimation ? 1 : 0)
                    .animation(.linear(duration: 0.9), value: moveCircleAnimation)
            } 
            else if eyeTracker.calibrating_step == 1 {
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.5, y: height * 0.5)
            }
            else if eyeTracker.calibrating_step == 2 {
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.5, y: height * 0.5)
                    .offset(x: moveCircleAnimation ? width * 0.4 : 0, y: moveCircleAnimation ? height * 0.4 : height * 0)
                    .animation(.easeInOut(duration: 0.9), value: moveCircleAnimation)
            }
            else if eyeTracker.calibrating_step == 3 {
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.9, y: height * 0.9)
                    .offset(x: moveCircleAnimation ? width * -0.8 : 0)
                    .animation(.easeInOut(duration: 0.9), value: moveCircleAnimation)
            }
            else if eyeTracker.calibrating_step == 4 {
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.1, y: height * 0.9)
                    .offset(y: moveCircleAnimation ? height * -0.8 : 0)
                    .animation(.easeInOut(duration: 0.9), value: moveCircleAnimation)
            }
            else if eyeTracker.calibrating_step == 5 {
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.1, y: height * 0.1)
                    .offset(x: moveCircleAnimation ? width * 0.8 : 0)
                    .animation(.easeInOut(duration: 0.9), value: moveCircleAnimation)
            } 
            else if eyeTracker.calibrating_step == -1 { // End of calibration
                Circle()
                    .fill(Color(red: 216/255, green: 222/255, blue: 233/255))
                    .frame(width: 40, height: 40)
                    .position(x: width * 0.9, y: height * 0.1)
                    .opacity(moveCircleAnimation ? 0 : 1)
                    .animation(.linear(duration: 0.9), value: moveCircleAnimation)
            }
        }
        .ignoresSafeArea(.all)
        .background(Color(red: 46/255, green: 52/255, blue: 64/255))
        
    }
}


struct EyeTrackingTestDone: View {
    
    @Binding var currentView: CurrentView
    
    @State var fadeOut = false
    @State var fadeIn = false
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        
        ZStack {
            // Fade out effect
            Circle()
                .fill(Color(red: 94/255, green: 129/255, blue: 172/255))
                .frame(width: 40, height: 40)
                .position(x: width * 0.5, y: height * 0.5)
                .opacity(fadeOut ? 0 : 1)
                .onAppear {
                    fadeOut = true
                }
                .animation(.easeInOut(duration: 0.9), value: fadeOut)
            VStack {
                Spacer()
                Text("The eye tracking test has been completed. Please press Next to continue to the survey.")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Spacer()
                Button(action: {
                    currentView = .survey
                }) {
                    Text("Next")
                        .font(.system(size: 45, weight: .medium).monospaced())
                        .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                        .frame(width: 300, height: 75)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(
                                cornerRadius: 40,
                                style: .continuous
                            )
                            .fill(Color(red: 94/255, green: 129/255, blue: 172/255))
                            .opacity(1)
                        )
                        .hoverEffect(.lift)
                        .padding([.leading, .trailing])
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 320) // Adjust vals later
            .background(.thinMaterial)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 6)
            .padding(30)
            .opacity(fadeIn ? 1 : 0)
            .onAppear {
                fadeIn = true
            }
            .animation(.easeInOut(duration: 0.9), value: fadeIn)
            
        }
        .frame(maxWidth: width * 0.8, maxHeight: .infinity)
        .background(ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            Color(red: 46/255, green: 52/255, blue: 64/255)
                .opacity(0.85)
                .ignoresSafeArea(.all)
        })
        .ignoresSafeArea(.all)
        .opacity(fadeIn ? 1 : 0)
        .onAppear {
            fadeIn = true
        }
        .animation(.easeInOut(duration: 0.9), value: fadeIn)
        
        
    }
}


