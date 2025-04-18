import SwiftUI

struct MissingCamera: View {
    
    @Binding var currentView: CurrentView
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        // TODO: fix description
        ZStack {
            VStack {
                Spacer()
                Text("As a camera is missing, the eye tracking section of the test will be skipped.")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Text("Click Next to be redirected directly to the survey.")
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(action: {
                    CurrentResults.num_saccades = 0
                    CurrentResults.num_blinks = 0
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
}
