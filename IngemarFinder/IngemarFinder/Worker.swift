import Foundation

struct Worker {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func makeHTTPPost(data: Data, completion: @escaping (IngemarPredictions) -> ()) {
        let endpoint = "https://southcentralus.api.cognitive.microsoft.com/customvision/v2.0/Prediction/3af81597-fa2c-434a-8a20-57bf8fcbde63/image?iterationId=72c2e889-db98-4c5f-9a8e-94eafd98784d"
        
        guard let endpointUrl = URL(string: endpoint) else { return }
        var UrlRequest = URLRequest(url: endpointUrl)
        UrlRequest.httpMethod = "POST"
        UrlRequest.setValue("f120a2f803dc4d778a618bb3d8041407", forHTTPHeaderField: "Prediction-Key")
        UrlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        UrlRequest.httpBody = data
        let session = URLSession.shared
        let task = session.dataTask(with: UrlRequest as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let predictions = try decoder.decode(IngemarPredictions.self, from: data)
                completion(predictions)

            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}