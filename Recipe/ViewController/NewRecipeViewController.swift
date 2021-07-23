//
//  NewRecipeViewController.swift
//  Recipe
//
//  Created by 2018MAC04 on 17/07/2021.
//

import UIKit
import SQLite
import AVFoundation

class NewRecipeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    let categoryArray = ["Main Dish","Side Dish","Dessert"]
    
    var showkey = 0
    var KeyboardH : CGFloat = 0.0
    
    var isEdit = false
    var recipeDetails = Recipe(id: 0, name: "", category: "", image: "", ingredient: "", step: "")
    
    var recipeName = ""
    var recipeCategory = ""
    var recipeImageData = ""
    var recipeIngredient = ""
    var recipeStep = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = isEdit ? "Edit Recipe" : "Add New Recipe"
        setupView()
        setupButton()
    }

    func setupView(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        buttonCategory.layer.borderWidth = 0.2
        buttonCategory.layer.borderColor = UIColor.gray.cgColor
        buttonCategory.layer.cornerRadius = 5
        
        textViewIngredients.layer.borderWidth = 0.2
        textViewIngredients.layer.borderColor = UIColor.gray.cgColor
        textViewIngredients.layer.cornerRadius = 5
        
        textViewStep.layer.borderWidth = 0.2
        textViewStep.layer.borderColor = UIColor.gray.cgColor
        textViewStep.layer.cornerRadius = 5
        
        if isEdit{ //edit page show original image
            if let dataDecoded = NSData(base64Encoded: recipeDetails.image, options: .ignoreUnknownCharacters){
                let decodedimage = UIImage(data: dataDecoded as Data)
                recipeImageView.image = decodedimage
            }
        }else{ //new page show camera icon
            recipeImageView.image = UIImage(named: "icn-camera")
        }
        
        textFieldName.text = isEdit ? recipeDetails.name : ""
        buttonCategory.setTitle(isEdit ? recipeDetails.category : "", for: .normal)
        textViewIngredients.text = isEdit ? recipeDetails.ingredient : ""
        textViewStep.text = isEdit ? recipeDetails.step : ""
    }
    
    func setupButton(){
        buttonImageView.addTarget(self, action: #selector(doBtnImage), for: .touchUpInside)
        buttonCategory.addTarget(self, action: #selector(doBtnCategory), for: .touchUpInside)
        if isEdit{
            buttonSave.setTitle("Update", for: .normal)
            buttonSave.addTarget(self, action: #selector(doBtnUpdate), for: .touchUpInside)
        }else{
            buttonSave.setTitle("Save", for: .normal)
            buttonSave.addTarget(self, action: #selector(doBtnSave), for: .touchUpInside)
        }
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
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    @objc func doBtnImage(_ sender: AnyObject){
        
        dismissKeyboard()
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
        recipeName = textFieldName.text ?? ""
        recipeCategory = buttonCategory.title(for: .normal) ?? ""
        recipeIngredient = textViewIngredients.text
        recipeStep = textViewStep.text

        //checking not allow empty data
        if recipeName == "" || recipeCategory == "" || recipeImageData == "" || recipeIngredient == "" || recipeStep == ""{
            
            let alertController = UIAlertController(
                title: "", message: "Plese fill up all the data",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action) in
            })
            alertController.addAction(cancelAction
            )
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        do{
            let db = try dbConnection()
            
            let table = Table("Recipe")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let category = Expression<String>("category")
            let image = Expression<String>("image")
            let ingredient = Expression<String>("ingredient")
            let step = Expression<String>("step")
            
            //SELECT MAX(id) FROM Recipe
            if let max = try db.scalar(table.select(id.max)){
                
                //INSERT INTO Recipe VALUES(max+1, name, category, image, ingredient, step)
                try db.run(table.insert(id <- Int64(max+1), name <- recipeName, category <- recipeCategory, image <- recipeImageData, ingredient <- recipeIngredient, step <- recipeStep))
                
                let alertController = UIAlertController(
                    title: "", message: "New Recipe Added",
                    preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                    (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
                        
        }catch{
            print(error)
        }
    }
    
    @objc func doBtnUpdate(){
        recipeName = textFieldName.text ?? ""
        recipeCategory = buttonCategory.title(for: .normal) ?? ""
        recipeImageData = recipeDetails.image
        recipeIngredient = textViewIngredients.text
        recipeStep = textViewStep.text

        //checking not allow empty data
        if recipeName == "" || recipeCategory == "" || recipeImageData == "" || recipeIngredient == "" || recipeStep == ""{
            
            let alertController = UIAlertController(
                title: "", message: "Plese fill up all the data",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action) in
            })
            alertController.addAction(cancelAction
            )
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        do{
            let db = try dbConnection()
            
            let table = Table("Recipe")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let category = Expression<String>("category")
            let image = Expression<String>("image")
            let ingredient = Expression<String>("ingredient")
            let step = Expression<String>("step")
            
            //Get current recipe details id
            let alice = table.filter(id == Int64(recipeDetails.id))
            //UPDATE Recipe Set name = recipeName, category = recipeCategoy, image = recipeImageData, ingredient = recipeIngredient, step = recipeStep WHERE id = alice
            try db.run(alice.update(id <- Int64(recipeDetails.id), name <- recipeName, category <- recipeCategory, image <- recipeImageData, ingredient <- recipeIngredient, step <- recipeStep))
            
            let alertController = UIAlertController(
                title: "", message: "Recipe Updated",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action) in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        
                        
        }catch{
            print(error)
        }

    }
}

//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        //Set the image after pick from album or camera
        recipeImageView.image = image
        
        let imageData = image.pngData()! as NSData
        //image data for insert/update purpose
        recipeImageData = imageData.base64EncodedString(options: .lineLength64Characters)
        
        self.dismiss(animated: true)

    }
}

