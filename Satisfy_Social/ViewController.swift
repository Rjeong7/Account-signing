//
//  ViewController.swift
//  Satisfy_Social
//
//  Created by Richard Jeong on 7/9/20.
//  Copyright © 2020 Richard Jeong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper

class ViewController: UIViewController {

    override func viewDidLoad() {
           super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
       }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var userImgView: UIImageView!
    
    
    @IBOutlet weak var usernameField: UITextField!
   
    
    @IBOutlet weak var emailField: UITextField!
    
    
    @IBOutlet weak var passwordField: UITextField!
    

    
    var imagePicker: UIImagePickerController!
    
    var selectedImage: UIImage!
    
    
    
    func setupUser(userID: String) {
        
        if let imageData = self.userImgView.image!.jpegData(compressionQuality: 0.2){

            let metaData = StorageMetadata()
            let imgUid = NSUUID().uuidString
            
            Storage.storage().reference().putData(imageData, metadata: metaData ) { (metadata, error) in
                  guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                  }
                  // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                     // You can also access to download URL after upload.
                    Storage.storage().reference().downloadURL { (url, error) in
                        guard url != nil
                        else {
                         // Uh-oh, an error occurred!
                         return
                       }
                }
            }
            
            
            Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metaData, error) in
            
            let userData = [
                
            "username": self.usernameField.text!,
            "userImg": Storage.storage().reference().downloadURL
            
            ] as [String : Any]
            
                Database.database().reference().child("users").child(userID).setValue(userData)
            self.performSegue(withIdentifier: "toFeed", sender: nil)
                
            }
    }
}

    
    
    
    
    @IBAction func signinPressed(_ sender: Any) {
        
        if let email = emailField.text,  let password = passwordField.text{
           
            Auth.auth().signIn(withEmail: email, password: password) { (user, error)
                in
              
                if error != nil && !(self.usernameField.text?.isEmpty)! {
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                      
                        self.setupUser(userID: (user?.user.uid)!)
                        
                        KeychainWrapper.standard.set( (user?.user.uid)!, forKey: "uid")
                        
                        
                    }
                }
                else{
                    
                    if let userID = (user?.user.uid){

                        KeychainWrapper.standard.set( (userID), forKey: "uid")
                        self.performSegue(withIdentifier: "toFeed", sender: nil)
                        
                    }
                    
                }
                
                
            }
            
        }
    }
    @IBAction func getPhoto (_ sender: AnyObject){
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
   


}


//could be this
extension ViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            userImgView.image = image
        }
        else{
            print("image wasn't selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
