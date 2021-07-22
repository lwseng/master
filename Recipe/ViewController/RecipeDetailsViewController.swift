//
//  RecipeDetailsViewController.swift
//  Recipe
//
//  Created by 2018MAC04 on 17/07/2021.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeCategoryLabel: UILabel!
    
    @IBOutlet weak var recipeIngredientsLabel: UILabel!
    @IBOutlet weak var recipeIngredientsData: UILabel!
    
    @IBOutlet weak var recipeStepLabel: UILabel!
    @IBOutlet weak var recipeStepData: UILabel!

    var recipeDetails = Recipe(name: "", category: "", image: "", ingredient: "", step: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details Page"
        
        setupView()
        setupButton()
    }
    
    func setupView(){
        recipeNameLabel.text = recipeDetails.name
        recipeCategoryLabel.text = recipeDetails.category
        recipeImageView.image = UIImage(named: recipeDetails.image)
        recipeIngredientsData.text = recipeDetails.ingredient
        recipeStepData.text = recipeDetails.step
    }
    
    func setupButton(){
        let buttonTopEdit = UIButton()
        buttonTopEdit.setImage(UIImage(named:"icn-edit"), for: .normal)
        let barButton = UIBarButtonItem(customView: buttonTopEdit)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        buttonTopEdit.addTarget(self, action: #selector(doBtnEdit), for: .touchUpInside)
    }
    
    @objc func doBtnEdit(){
        let vc = NewRecipeViewController(nibName: "NewRecipeViewController", bundle: nil)
        
        vc.titleName = "Edit Recipe"
        vc.isEdit = true
        vc.recipeDetails = recipeDetails
        
        navigationController?.pushViewController(vc, animated: true)
    }

}
