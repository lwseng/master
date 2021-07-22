//
//  NewRecipeViewController.swift
//  Recipe
//
//  Created by 2018MAC04 on 17/07/2021.
//

import UIKit
import AVFoundation

class NewRecipeViewController: UIViewController {
    
    @IBOutlet weak var labelImage: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var buttonImageView: UIButton!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var buttonCategory: UIButton!
    
    @IBOutlet weak var labelIngredients: UILabel!
    @IBOutlet weak var textViewIngredients: UITextView!
    
    @IBOutlet weak var labelStep: UILabel!
    @IBOutlet weak var textViewStep: UITextView!
    
    @IBOutlet weak var buttonSave: UIButton!
    
    let categoryArray = ["All","Main Dish","Side Dish","Dessert"]
    
    var showkey = 0
    var KeyboardH : CGFloat = 0.0
    
    var titleName = "Add New Recipe"
    var isEdit = false
    var recipeDetails = Recipe(name: "", category: "", image: "", ingredient: "", step: "")
    
    var element = ""
    var name = ""
    var category = ""
    var ingredient = ""
    var step = ""
    var image = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = titleName
        
        setupView()
        setupButton()
    }

    func setupView(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        buttonCategory.layer.borderWidth = 0.2
        buttonCategory.layer.borderColor = UIColor.gray.cgColor
        buttonCategory.layer.cornerRadius = 5
        
        textViewIngredients.layer.borderWidth = 0.2
        textViewIngredients.layer.borderColor = UIColor.gray.cgColor
        textViewIngredients.layer.cornerRadius = 5
        
        textViewStep.layer.borderWidth = 0.2
        textViewStep.layer.borderColor = UIColor.gray.cgColor
        textViewStep.layer.cornerRadius = 5
        
        recipeImageView.image = isEdit ? UIImage(named: recipeDetails.image) : UIImage(named: "icn-camera")
        textFieldName.text = isEdit ? recipeDetails.name : ""
        buttonCategory.setTitle(isEdit ? recipeDetails.category : "", for: .normal)
        textViewIngredients.text = isEdit ? recipeDetails.ingredient : ""
        textViewStep.text = isEdit ? recipeDetails.step : ""
    }
    
    func setupButton(){
        buttonImageView.addTarget(self, action: #selector(doBtnImage), for: .touchUpInside)
        buttonCategory.addTarget(self, action: #selector(doBtnCategory), for: .touchUpInside)
        buttonSave.addTarget(self, action: #selector(doBtnSave), for: .touchUpInside)
    }
    
    func checkCameraPermission(){
        let CameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch CameraStatus{
        case .authorized:
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .camera
            cameraPicker.allowsEditing = false
            cameraPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(cameraPicker, animated: true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async{
                        let cameraPicker = UIImagePickerController()
                        cameraPicker.sourceType = .camera
                        cameraPicker.allowsEditing = false
                        cameraPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                        self.present(cameraPicker, animated: true)
                    }
                }
            }
            
        case .denied:
            let alertController = UIAlertController(
                title: "Camera Permission Denied", message: "This app need permission for take photo",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action) in
            })
            alertController.addAction(cancelAction
            )
            self.present(alertController, animated: true, completion: nil)

        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    //MARK:- Event Action
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ sender: Foundation.Notification) {
        let info = sender.userInfo!
        let keyboardHeight:CGFloat = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        let duration:Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if showkey == 0 && sender.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.size.height = frame.size.height - keyboardHeight
                self.view.frame = frame
                
                //modifying the new keyboard ios8
                self.showkey = 1
                self.KeyboardH = keyboardHeight
            })
        } else if showkey == 1 && sender.name == UIResponder.keyboardWillShowNotification{
            //reset keyboard height when change to other keyboard type (eg: emoji keyboard)
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.size.height = frame.size.height + self.KeyboardH
                frame.size.height = frame.size.height - keyboardHeight
                self.view.frame = frame
                           
                self.KeyboardH = keyboardHeight
            })
        } else {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.size.height = frame.size.height + keyboardHeight
                self.view.frame = frame
                
                //modifying the new keyboard ios8
                self.showkey = 0
                self.KeyboardH = keyboardHeight
            })
        }
    }
    
    @objc func doBtnImage(_ sender: AnyObject){
        let actionSheet = UIAlertController(title: nil, message: "Snap/Upload Photo", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) {
            (alert) -> Void in
            
            self.checkCameraPermission()
        }
        
        let photoAction = UIAlertAction(title: "Choose Photo", style: .default) {
            (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePicker, animated: true)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (alert) -> Void in
        }
         
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelButton)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        if self.presentedViewController == nil {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @objc func doBtnCategory(_ sender: AnyObject){
        let actionSheet = UIAlertController(title: nil, message: "Choose Category", preferredStyle: .actionSheet)
        
        for index in 0 ..< categoryArray.count{
            let action = UIAlertAction(title: categoryArray[index], style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.buttonCategory.setTitle(self.categoryArray[index], for: .normal)
            })
            actionSheet.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
        }
        if self.presentedViewController == nil {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @objc func doBtnSave(){
        
        let _ = textFieldName.text
        let _ = buttonCategory.title(for: .normal)
        let _ = textViewIngredients.text
        let _ = textViewStep.text
    }
}


//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let _ = info[.imageURL] as? URL else { return }
        
        self.dismiss(animated: true)

    }
}

