import SwiftUI

struct About: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 5, alignment: .center)], spacing: 5) {
            
                Text("About")
                    .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                    .font(Font.system(size: 50).monospaced())
                    .fontWeight(.bold)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .padding()
                VStack {
                    Text("What is ADHD?")
                        .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                        .font(Font.system(size: 30).monospaced())
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(30)
                        .padding(.top)

                    VStack {
                        Image("ADHD illustration")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .padding()
                        Text("ADHD is a neuro-developmental condition that affects over 170 million people (2.2 % of people) worldwide. People who have this condition suffer from inattention, hyperactivity and the development of the brain. Many people with this condition also develop other conditions like depression more commonly later in their lives. Although it is one of the most common neuro-developmental disorders in the world, over 80% do not get proper treatment, and most do not get any diagnosis.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .offset(y: -20)
                    Spacer()
                }.frame(maxWidth: 700, minHeight: 320)
                    .background(.thinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 6)
                    .padding()
                
                VStack {
                    Text("How does this app work?")
                        .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                        .font(Font.system(size: 30).monospaced())
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(30)
                        .padding(.top)
                    
                    
                    VStack {
                        Image("Phone")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                            .padding()
                        Text("This app was created as a concept so that people who suspect they have ADHD can get a diagnosis directly on their devices. It works through the eye tracking, which counts the number of microsaccades (quick, uncontrollable movements of the eye) and blinks over a period of time, both of which are factors that have have a correlation with ADHD. In addition, it also uses a survey, which adds accuracy to the test as a whole.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                            
                        
                    }
                    .offset(y: -20)
                    Spacer()
                }.frame(maxWidth: 700, minHeight: 320)
                    .background(.thinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 6)
                    .padding()
                
                VStack {
                    Text("Where can I see my results?")
                        .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                        .font(Font.system(size: 30).monospaced())
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(30)
                        .padding(.top)
                    
                    
                    VStack {
                        
                        Image("Result")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .padding()
                        Text("You can check your past results in the \"Past Results\" tab. To see more information, you can click on a result. It will display all the information that you were shown after finishing the test.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                    }
                    .offset(y: -20)
                    Spacer()
                }.frame(maxWidth: 700, minHeight: 320)
                    .background(.thinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 6)
                    .padding()
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
