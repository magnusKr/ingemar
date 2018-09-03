import UIKit
import AVKit
import Vision
import AVFoundation

enum Tags: String {
    case fake
    case stenmark
    
    func name() -> String {
        return self.rawValue
    }
}

//enum Machine {
//    case local
//    case server
//}

class ViewController: UIViewController {
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var fakeStamp: UIImageView!
    @IBOutlet weak var okStamp: UIImageView!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var worker = Worker()
    var machine = Machine.server
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func buffer(from image: UIImage) -> CVPixelBuffer? {
//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        var pixelBuffer : CVPixelBuffer?
//        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
//        guard (status == kCVReturnSuccess) else {
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//
//        context?.translateBy(x: 0, y: image.size.height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//
//        UIGraphicsPushContext(context!)
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        UIGraphicsPopContext()
//        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//        return pixelBuffer
//    }

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        fakeStamp.alpha = 0
        okStamp.alpha = 0
        confidenceLabel.text = ""
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showResult(name: String?, confidence: Float?){
        guard let name = name else { return }
        guard let confidence = confidence else { return }
        confidenceLabel.text = "Det är fan \(name) med \(confidence*100)%"
       if name == Tags.stenmark.name() {
            self.okStamp.alpha = 1.0
        } else if name == Tags.fake.name() {
            self.fakeStamp.alpha = 1.0
        }
    }
    
    func getResultFromLocalMachine(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: ingemar().model) else { return }
        guard let pixelBuffer = buffer(from: image) else { return }
        
        let request = VNCoreMLRequest(model: model) { [weak self] (finishedRequest, error) in
            guard error == nil else { return }
            guard let results = finishedRequest.results else { return }
            guard let observation = results.first as? VNClassificationObservation else { return }
            DispatchQueue.main.async(execute: {
                self?.showResult(name: observation.identifier, confidence: observation.confidence)
            })
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func getResultFromServerMachine(image: UIImage) {
        guard let compressData = UIImageJPEGRepresentation(image, 0.5) else { return }
        spinner.startAnimating()
        worker.makeHTTPPost(data: compressData){ [weak self] ingemarPredections in
            DispatchQueue.main.async(execute: {
                self?.spinner.stopAnimating()
                self?.showResult(name: ingemarPredections.predictions.first?.tagName, confidence: ingemarPredections.predictions.first?.probability)
            })
            //print(ingemarPredections.predictions.first)
        }
    }
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image

        PredictionService().getPredictionFrom(image) { (observation) in
            self.showResult(name: observation.first?.tagName, confidence: observation.first?.probability)
        }
//        switch machine {
//            case .local:
//                getResultFromLocalMachine(image: image)
//            case .server:
//                getResultFromServerMachine(image: image)
//        }

        
        guard let imageData = UIImagePNGRepresentation(image) else { return }
        
//        guard let model = try? VNCoreMLModel(for: ingemar().model) else { return }
//        guard let pixelBuffer = buffer(from: image) else { return }
//        
//        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
//            guard error == nil else { return }
//            
//            guard let results = finishedRequest.results else { return }
//            
//            guard let observation = results.first as? VNClassificationObservation else { return }
//            
//            if observation.identifier == Tags.stenmark.name() {
//                self.okStamp.alpha = 1.0
//            } else if observation.identifier == Tags.fake.name() {
//                self.fakeStamp.alpha = 1.0
//            }
//            print(observation.identifier, observation.confidence)
//        }
//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
