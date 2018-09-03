import Foundation

struct IngemarPrediction: Codable {
    var tagName: String
    var probability: Float
    var tagId: String
}

struct IngemarPredictions: Codable {
    var id: String
    var project: String
    var iteration: String
    var created: String
    var predictions: [IngemarPrediction]
}
