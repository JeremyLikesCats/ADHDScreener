//
//  ADHDTest.swift
//  ADHD Screener
//
//  Created by Jeremy Zhou on 11/2/2025.
//

import SwiftUI

enum CurrentView {
    case main
    case eyeTrackingTest
    case eyeTrackingTestDone
    case missingCamera
    case survey
    case results
}

struct ADHDTest: View {
    @Binding var currentView: CurrentView
    var body: some View {
        ZStack(alignment: .topLeading) {
                
            VStack {
                
                Text("ADHD Test")
                    .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                    .font(Font.system(size: 80).monospaced())
                    .fontWeight(.bold)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .padding()
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .frame(width: 150, height: 170)
                    .padding()
                    .foregroundStyle(Color.white)
                
                Text("Test yourself for ADHD through eye tracking.")
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                    .padding()
                    .font(.system(size: 15).monospaced())
                
                Spacer()
                Spacer()
                
                
                Button(action: {
                    currentView = .eyeTrackingTest
                }) {
                    Text("Start")
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
                }
                
                
                
                
                Button("I don't have a camera") {
                    currentView = .missingCamera
                }
                .font(.system(size: 17))
                .frame(width: 300, height: 40)
                .foregroundStyle(Color(red: 216/255, green: 222/255, blue: 233/255))
                .hoverEffect(.lift)
                Spacer()
                
            }.padding()
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            Color(red: 46/255, green: 52/255, blue: 64/255)
                .opacity(0.85)
                .ignoresSafeArea(.all)
        })
        
        

    }
}


struct ViewSwitcher: View {
    
    @State var currentView: CurrentView = .main
    @State var start = false
    @State var survey = false
    @State var results = false
    @State var eye_track_test_done = false
    @State var coming_from_test = true
    @State var result = Result(num_saccades: CurrentResults.num_saccades, num_blinks: CurrentResults.num_blinks, survey_score: CurrentResults.survey_score, adhd_score: CurrentResults.adhd_score, eye_locations: CurrentResults.eye_locations, date_done: CurrentResults.date_done)
    @State var focus_result = false
    
    @StateObject private var pastResults = SaveResults()
    
    var body: some View {
        switch currentView {
        case .main:
            TabView {
                // Swap between Test and Past results and TODO: add about
                
                Tab ("Test", systemImage: "testtube.2") {
                    ADHDTest(currentView: $currentView)
                }
                Tab("Past Results", systemImage: "folder") {
                    PastResults(result_to_show: result)
                }
                Tab ("About", systemImage: "info.circle.fill") {
                    About()
                }
                
            } 
        
        case .eyeTrackingTest:
            EyeTrackingTest(currentView: $currentView)
            
        case .eyeTrackingTestDone:
            EyeTrackingTestDone(currentView: $currentView)
        
        case .missingCamera:
            MissingCamera(currentView: $currentView)
            
        case .survey:
            Survey(currentView: $currentView, result_to_show: $result)
        
        case .results:
            ShowResults(coming_from_test: $coming_from_test, currentView: $currentView, result_to_show: $result, focus_result: $focus_result)
            
        }
    }
}

