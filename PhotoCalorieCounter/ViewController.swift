//
//  ViewController.swift
//  PhotoCalorieCounter
//
//  Created by Shaurya Sinha on 28/07/17.
//  Copyright © 2017 Shaurya Sinha. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var mealInfoLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    //Get API key and version from another file, not included in git tracking
    let api = ApiInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            SVProgressHUD.show()
            
            imageView.image =  image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            var foodDict = Dictionary<Double, String>()
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [] )
            
            let foodClassifier = VisualRecognition(apiKey: api.apiKey, version: api.version)
            
            foodClassifier.classify(imageFile: fileURL, classifierIDs: ["food"], language: "en", success: { (classifiedImages) in
                //print(classifiedImages)
                let possibleClasses = classifiedImages.images.first!.classifiers.first!.classes
                
                for i in 0..<possibleClasses.count {
                    foodDict[possibleClasses[i].score] = possibleClasses[i].classification
                }
        
                let mostProbableFood = foodDict[foodDict.keys.max()!]
                DispatchQueue.main.async {
                    self.mealInfoLabel.text = "Your meal is: " + mostProbableFood!
                }
                
                SVProgressHUD.dismiss()
                
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

