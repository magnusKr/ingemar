import UIKit
import AVKit
import Vision
import AVFoundation

struct ResultViewModel {
    let tagName: String?
    let confidence: Float?
}

struct PredictionService {

    func getPredictionFrom(_ image: UIImage, completion: @escaping (ResultViewModel) -> ()){
        let serverMode = UserDefaults.standard.bool(forKey: "server_mode")
        if serverMode {
            getPredictionFromServerMachine(image) { (ingemarPredections) in
            let viewModel = ResultViewModel(tagName: ingemarPredections.predictions.first?.tagName,
                                            confidence: ingemarPredections.predictions.first?.probability)
                completion(viewModel)
            }
        } else {
            getResultFromLocalMachine(image) { (observation) in
                let viewModel = ResultViewModel(tagName: observation.identifier, confidence: observation.confidence)
                completion(viewModel)
            }
        }
    }

    //Use server side Model
    private func getPredictionFromServerMachine(_ image: UIImage, completion: @escaping (IngemarPredictions) -> ()){
        guard let compressData = UIImageJPEGRepresentation(image, 0.5) else { return }
        Worker().makeHTTPPost(data: compressData){ ingemarPredections in
            DispatchQueue.main.async(execute: {
                completion(ingemarPredections)
            })
        }
    }
    //Use local mlmodel
    private func getResultFromLocalMachine(_ image: UIImage, completion: @escaping (VNClassificationObservation) -> ()) {
        guard let model = try? VNCoreMLModel(for: ingemar().model), let pixelBuffer = buffer(from: image) else { return }

        let request = VNCoreMLRequest(model: model) {(finishedRequest, error) in
            guard error == nil else { return }
            guard let results = finishedRequest.results, let observation = results.first as? VNClassificationObservation else { return }
            DispatchQueue.main.async(execute: {
                completion(observation)
            })
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
