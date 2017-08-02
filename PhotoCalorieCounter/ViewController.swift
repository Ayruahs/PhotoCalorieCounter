//
//  ViewController.swift
//  PhotoCalorieCounter
//
//  Created by Shaurya Sinha on 28/07/17.
//  Copyright © 2017 Shaurya Sinha. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    //Get API key and version from another file, not included in git tracking
    let api = ApiInfo()
    
    
    var classificationResults: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image =  image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [] )
            
            let foodClassifier = VisualRecognition(apiKey: api.apiKey, version: api.version)
            
            
            foodClassifier.classify(imageFile: fileURL, success: { (classifiedImages) in
                print(classifiedImages)
                let possibleClasses = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for i in 0..<possibleClasses.count {
                    self.classificationResults.append(possibleClasses[i].classification)
                }
                // Figure out how to use this:
                let googleUrl = "https://www.google.com/search?q=hotdog+calories&oq=hotdog+calories"
                let url = NSURL(string: googleUrl)
                URLSession.shared.dataTask(with: url! as URL) {
                    (data, response, error) in
                    // deal with error etc accordingly       
                    print("Data: \n")
                    print(data as Any)
                    print("response: \n")
                    print(response as Any)
                    print("error: \n")
                    print(error as Any)
                    
                }.resume()
                
            })
            
        } else {
            print("there was an error.")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing =  false
        
        present(imagePicker, animated: true, completion: nil)
    }
    


}

