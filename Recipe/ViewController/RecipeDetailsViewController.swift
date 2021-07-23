//
//  RecipeDetailsViewController.swift
//  Recipe
//
//  Created by 2018MAC04 on 17/07/2021.
//

import UIKit
import SQLite

class RecipeDetailsViewController: UIViewController {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeCategoryLabel: UILabel!
    
    @IBOutlet weak var recipeIngredientsLabel: UILabel!
    @IBOutlet weak var recipeIngredientsData: UILabel!
    
    @IBOutlet weak var recipeStepLabel: UILabel!
    @IBOutlet weak var recipeStepData: UILabel!
    
    @IBOutlet weak var buttonDelete: UIButton!

    var recipeDetails = Recipe(id: 0, name: "", category: "", image: "", ingredient: "", step: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details Page"
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupView()
    }
    
    func setupView(){
        
        do{
            let db = try dbConnection()
            
            let table = Table("Recipe")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let category = Expression<String>("category")
            let image = Expression<String>("image")
            let ingredient = Expression<String>("ingredient")
            let step = Expression<String>("step")
            
            //SELECT * FROM Recipe WHERE id = recipeDetails.id
            let query = table.filter(id == Int64(recipeDetails.id))
            for result in try db.prepare(query){
                recipeNameLabel.text = result[name]
                recipeCategoryLabel.text = result[category]
                
                if let dataDecoded = NSData(base64Encoded: result[image], options: .ignoreUnknownCharacters){
                    let decodedimage = UIImage(data: dataDecoded as Data)
                    recipeImageView.image = decodedimage
                }
                
                recipeIngredientsData.text = result[ingredient]
                recipeStepData.text = result[step]
            }
            
        }catch{
            print(error)
        }
    }
    
    func setupButton(){
        let buttonTopEdit = UIButton()
        buttonTopEdit.setImage(UIImage(named:"icn-edit"), for: .normal)
        let barButton = UIBarButtonItem(customView: buttonTopEdit)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        buttonTopEdit.addTarget(self, action: #selector(doBtnEdit), for: .touchUpInside)
        buttonDelete.addTarget(self, action: #selector(doBtnDelete), for: .touchUpInside)
    }
    
    //MARK:- Event Action
    @objc func doBtnEdit(){
        let vc = NewRecipeViewController(nibName: "NewRecipeViewController", bundle: nil)
        
        vc.isEdit = true
        vc.recipeDetails = recipeDetails
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func doBtnDelete(){
        let alertController = UIAlertController(
            title: "Confirm", message: "Are you sure want to delete this recipe?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in
        })
        let OkAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            
            do{
                let db = try dbConnection()
                
                let table = Table("Recipe")
                let id = Expression<Int64>("id")
                
                let alice = table.filter(id == Int64(self.recipeDetails.id))
                try db.run(alice.delete())
                
                let alertController = UIAlertController(
                    title: "", message: "Recipe Deleted",
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
        })
        
        alertController.addAction(OkAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
