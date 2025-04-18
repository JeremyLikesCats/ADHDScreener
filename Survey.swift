    //
    //  Survey.swift
    //  ADHD Screener
    //
    //  Created by Jeremy Zhou on 11/2/2025.
    //

    import SwiftUI

    struct Survey: View {
        
        // Survey taken from https://add.org/wp-content/uploads/2015/03/adhd-questionnaire-ASRS111.pdf
        
        let options = [1,2,3,4,5]
        let width = UIScreen.main.bounds.width
        
        @Binding var currentView: CurrentView
        @Binding var result_to_show: Result
        
        @State var answers = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        @State var questions_not_done = false
        @State var missing_questions: [Int] = []
        @State var missing_question_format = ""
        
        @StateObject private var saveResults = SaveResults()
        
        let questions = [
            "How often do you have trouble wrapping up the final details of a project, once the challenging parts have been done?",
            "How often do you have difficulty getting things in order when you have to do a task that requires organization?",
            "How often do you have problems remembering appointments or obligations?",
            "When you have a task that requires a lot of thought, how often do you avoid or delay getting started?",
            "How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?",
            "How often do you feel overly active and compelled to do things, like you were driven by a motor?",
            "How often do you make careless mistakes when you have to work on a boring or difficult project?",
            "How often do you have difficulty keeping your attention when you are doing boring or repetitive work?",
            "How often do you have difficulty concentrating on what people say to you, even when they are speaking to you directly?",
            "How often do you misplace or have difficulty finding things at home or at work?",
            "How often are you distracted by activity or noise around you?",
            "How often do you leave your seat in meetings or other situations in which you are expected to remain seated?",
            "How often do you feel restless or fidgety?",
            "How often do you have difficulty unwinding and relaxing when you have time to yourself?",
            "How often do you find yourself talking too much when you are in social situations?",
            "When you’re in a conversation, how often do you find yourself finishing the sentences of the people you are talking to, before they can finish them themselves?",
            "How often do you have difficulty waiting your turn in situations when turn taking is required?",
            "How often do you interrupt others when they are busy?"
        ]
        
        
        var body: some View {
                
                
                
                ScrollView {
                    Text("Survey")
                        .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                        .font(Font.system(size: 50).monospaced())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding()
                    ForEach(0..<questions.count, id: \.self) { question in
                        
                        let current_question = question + 1
                     
                        ZStack {
                            VStack {
                                Text("Question " + String(current_question))
                                    .font(.system(size: 23, weight: .bold).monospaced())
                                    .foregroundStyle(Color(red: 236/255, green: 239/255, blue: 244/255))
                                
                                Text(questions[question])
                                    .padding([.top], 10)
                                    .multilineTextAlignment(.center)
                                
                                VStack {
                                    Picker("", selection: $answers[question]) {
                                        ForEach(options, id: \.self) {
                                            Text(String($0)).tag($0)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    
                                    HStack {
                                        Text("Never")
                                        Spacer()
                                        Text("Very Often")     
                                    } 
                                    .padding(.top, 5)
                                    .font(.system(size: 12, weight: .regular).monospaced())
                                }
                                .frame(maxWidth: 500)
                                .padding(.top, 15)
                            }
                            .frame(minWidth: width * 0.6, maxWidth: width * 0.6)
                            .padding(25)
                        }
                        .background(.thinMaterial)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 6)
                        .padding(10)    
                    }
                    
                    if questions_not_done {
                        Text("Please answer all questions! Then, click submit.")
                        Text("Missing Questions: " + missing_question_format)
                    }
                    
                    Button(action: {
                        missing_questions = []
                        missing_question_format = ""
                        
                        if !(answers.contains(0)) {
                            questions_not_done = false
                            
                            let three_shaded_questions = [1,2,3,9,12,16,18]
                            let two_shaded_questions = [4,5,6,7,8,10,11,13,14,15,17]
                            
                            var total = 0
                            
                            for question in 0..<answers.count {
                                let current_question = question + 1
                                if (three_shaded_questions.contains(current_question)) {
                                    if answers[question] >= 3 {
                                        total += 1
                                    }
                                } else if (two_shaded_questions.contains(current_question)) {
                                    if answers[question] >= 4 {
                                        total += 1
                                    }
                                }
                            }
                            
                            CurrentResults.survey_score = total
                            
                            // Check if ADHD is likely
                            
                            if CurrentResults.num_blinks != 0 || CurrentResults.num_saccades != 0 {
                                // Let 40 be the average amount of microsaccades that a person with ADHD has per 15 seconds
                                CurrentResults.adhd_score += (Double(CurrentResults.num_saccades) / 40) * 0.5
                                
                                // Let 10 be the average amount of blinks that a person with ADHD has per 15 seconds
                                CurrentResults.adhd_score += (Double(CurrentResults.num_blinks) / 10) * 0.5
                                
                            } else {
                                // Default
                                CurrentResults.adhd_score += 0.7
                            }
                            
                            // 18 questions
                            CurrentResults.adhd_score += (Double(CurrentResults.survey_score) / 18) * 1
                            
                            // Add date to results
                            CurrentResults.date_done = Date()
                            
                            // Save results to UserDefaults
                            saveResults.addResult(num_saccades: CurrentResults.num_saccades, num_blinks: CurrentResults.num_blinks, survey_score: CurrentResults.survey_score, adhd_score: CurrentResults.adhd_score, eye_locations: CurrentResults.eye_locations, date_done: CurrentResults.date_done)
                            
                            result_to_show = Result(num_saccades: CurrentResults.num_saccades, num_blinks: CurrentResults.num_blinks, survey_score: CurrentResults.survey_score, adhd_score: CurrentResults.adhd_score, eye_locations: CurrentResults.eye_locations, date_done: CurrentResults.date_done)
                            currentView = .results
                            
                        } else {
                            
                            questions_not_done = true
                            for answer in 0..<answers.count {
                                if answers[answer] == 0 {
                                    missing_questions.append(answer + 1)
                                }
                            }
                            
                            for question in missing_questions.sorted() {
                                missing_question_format += "Q" + String(question) + " "
                            }
                            
                        }
                    }){
                        Text("Submit")
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

