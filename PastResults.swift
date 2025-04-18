//
//  Untitled.swift
//  ADHD Screener
//
//  Created by Jeremy Zhou on 8/2/2025.
//

import SwiftUI
import Charts

struct PastResults: View {
    @Namespace private var animation
    @StateObject private var pastResults = SaveResults()
    @State private var focusResult = false
    @State var result_to_show: Result
    @State private var coming_from_test = false
    @State var currentView: CurrentView = .main
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var body: some View {
        PastResultsGrid(focusResult: $focusResult, result_to_show: $result_to_show)
        .sheet(isPresented: $focusResult) {
            ShowResults(coming_from_test: $coming_from_test, currentView: $currentView, result_to_show: $result_to_show, focus_result: $focusResult)
        }

    }
}

struct PastResultsGrid: View {
    @StateObject private var pastResults = SaveResults()
    @Binding var focusResult: Bool
    @Binding var result_to_show: Result
    
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView {
            Spacer()
            
            Text("Past Results")
                .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                .font(Font.system(size: 50).monospaced())
                .fontWeight(.bold)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .padding()
            
            
            Spacer()
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 5, alignment: .center), GridItem(.flexible(), spacing: 5, alignment: .center)], spacing: 5) {
                ForEach(pastResults.results.reversed(), id: \.self) { result in
                    Button(action: {
                        result_to_show = result
                        withAnimation {
                            focusResult = true
                        }
                    }) {
                        VStack {
                            VStack {
                                VStack {
                                    if result.adhd_score < 1.0 {
                                        Text("Highly Unlikely to have ADHD")
                                    } else if result.adhd_score < 1.5 {
                                        Text("Unlikely to have ADHD")
                                    } else if result.adhd_score < 2.0 {
                                        Text("Likely to have ADHD")
                                    } else {
                                        Text("Very likely to have ADHD")
                                    }
                                }.padding([.top, .leading, .trailing])
                                    .font(Font.system(size: 25))
                                    .fontWeight(.bold)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                
                                Text("Date: \(result.date_done.formatted(.dateTime.year().month().day())) at \(result.date_done.formatted(.dateTime.hour().minute()))")
                                    .font(Font.system(size: 12))
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                    .padding(.bottom)
                                
                                
                                Chart(result.eye_locations) {
                                    PointMark(
                                        x: .value("X Position", Float($0.x)),
                                        y: .value("Y Position", Float($0.y))
                                    )
                                }
                                .frame(width: 200, height: 200)
                                .chartXScale(domain: [0, Float(width)])
                                .chartYScale(domain: [0, Float(height)])
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, minHeight: 320) // Adjust vals later
                        .background(.thinMaterial)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 6)
                        .hoverEffect(.lift)
                        .padding()
                    }
                    
                    
                }
                
                    
            }
            .padding([.top, .leading, .trailing],10)
            .buttonStyle(PlainButtonStyle())
            if pastResults.results.count == 0 {
                Text("Do a test and it will appear here!")
                    .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                    .font(Font.system(size: 12).monospaced())
            }
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
