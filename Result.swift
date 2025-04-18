import SwiftUI

struct Result: Codable, Identifiable, Hashable, Equatable {
    var id = UUID()
    
    let num_saccades: Int
    let num_blinks: Int
    let survey_score: Int
    let adhd_score: Double
    let eye_locations: [EyePosition]
    let date_done: Date
}

struct CurrentResults {
    static var num_saccades = 0
    static var num_blinks = 0
    static var survey_score = 0
    static var adhd_score = 0.0
    static var eye_locations: [EyePosition] = []
    static var date_done: Date = Date()
}


class SaveResults: ObservableObject {
    
    let key = "Results"
    @Published var results: [Result] = [] {
        didSet {
            saveResultsToUD()
        }
    }
    
    init() {
        loadResults()
    }
    
    func saveResultsToUD() {
        if let json_encoded = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(json_encoded, forKey: key)
        }
    }
    
    func loadResults() {
        if let pastResults = UserDefaults.standard.data(forKey: key) {
            if let decodedPastResults = try? JSONDecoder().decode([Result].self, from: pastResults) {
                results = decodedPastResults
            }
        }
    }
    
    func addResult(num_saccades: Int, num_blinks: Int, survey_score: Int, adhd_score: Double, eye_locations: [EyePosition], date_done: Date) {
        let result = Result(num_saccades: num_saccades, num_blinks: num_blinks, survey_score: survey_score, adhd_score: adhd_score, eye_locations: eye_locations, date_done: date_done)
        
        results.append(result)
    }

}
