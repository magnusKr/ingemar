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

class ViewController: UIViewController {
    
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var fakeStamp: UIImageView!
    @IBOutlet weak var okStamp: UIImageView!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        fakeStamp.alpha = 0
        okStamp.alpha = 0
        confidenceLabel.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func presentResult(name: String?, confidence: Float?) {
        confidenceLabel.isHidden = false
        let name = name ?? "Something went wrong.."
        let confidence = confidence ?? -1.0
        confidenceLabel.text = "Det är \(name) med \(confidence*100)%"
        if name == Tags.stenmark.name() {
            self.okStamp.alpha = 1.0
        } else if name == Tags.fake.name() {
            self.fakeStamp.alpha = 1.0
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image
        PredictionService().getPredictionFrom(image) { [weak self] (observation)  in
            self?.presentResult(name: observation.tagName, confidence: observation.confidence)
        }
    }
}
