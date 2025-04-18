import SwiftUI
import Charts

struct ShowResults: View {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @Binding var coming_from_test: Bool
    @Binding var currentView: CurrentView
    @Binding var result_to_show: Result
    @Binding var focus_result: Bool
    // Display results to user
    
    var body: some View {
        
        ScrollView {
            ZStack {
                VStack {
                    
                    Text("Final Result")
                        .font(Font.system(size: 50).monospaced())
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(.top, 10)
                    VStack {
                        if result_to_show.adhd_score < 1.0 {
                            Text("Highly Unlikely to have ADHD")
                        } else if result_to_show.adhd_score < 1.5 {
                            Text("Unlikely to have ADHD")
                        } else if result_to_show.adhd_score < 2.0 {
                            Text("Likely to have ADHD")
                        } else {
                            Text("Very likely to have ADHD")
                        }
                    }
                        .frame(maxWidth: .infinity, minHeight: 80) // Adjust vals later
                        .background(.thinMaterial)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 6)
                        .padding(30)
                        .font(Font.system(size: 25))
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                    
                    Divider()
                    
                    Text("Survey Score:")
                        .padding(.top, 50)
                    Text("\(String(result_to_show.survey_score)) / 18")
                        .font(Font.system(size: 100))
                        .fontWeight(.bold)
                        .padding(.bottom, 50)
                    
                    
                    Divider()
                    HStack {
                        Spacer()
                        VStack {
                            Text("Number of Microsaccades:")
                                .padding(.top, 50)
                            Text(String(result_to_show.num_saccades))
                                .font(Font.system(size: 100))
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack {
                            Text("Number of Blinks:")
                                .padding(.top, 50)
                            Text(String(result_to_show.num_blinks))
                                .font(Font.system(size: 100))
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    
                   
                    
                    Chart(result_to_show.eye_locations) {
                        PointMark(
                            x: .value("X Position", Float($0.x)),
                            y: .value("Y Position", Float($0.y))
                        )
                    }
                    .padding([.leading, .trailing, .bottom], 25)
                    .frame(width: width * 0.5 ,height:height * 0.5)
                    .chartXScale(domain: [0, Float(width)])
                    .chartYScale(domain: [0, Float(height)])
                    
                    Text("Locations where eye viewed")
                        .font(Font.system(size: 12))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .offset(y: -25)
                        .padding(.bottom)
                    
                    Divider()
                    if coming_from_test {
                        Button(action: {
                            currentView = .main
                        }) {
                            Text("Finished")
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
                                .padding([.leading, .trailing, .top])
                        } 
                    }
                    
                }
                
                
                
            }.padding(40)
        }
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
    
}

