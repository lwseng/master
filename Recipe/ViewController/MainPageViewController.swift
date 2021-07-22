//
//  ViewController.swift
//  Recipe
//
//  Created by 2018MAC04 on 16/07/2021.
//

import UIKit

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var element = ""
    var name = ""
    var category = ""
    var ingredient = ""
    var step = ""
    var image = ""
    var categoryArr = [String]()
    var recipe = [Recipe]()
    var selectedCategory = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home Page"
        
        loadData()
        setupButton()
        setupCollectionView()
    }
    
    func loadData(){
        if let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        
        if let path = Bundle.main.path(forResource: "recipeData", ofType: "plist") {
            guard let recipeDict = NSDictionary(contentsOfFile: path) else {
                return
            }

            let recipePlist = recipeDict["Recipe"] as! [[String: Any]]

            for index in 0 ..< recipePlist.count{
                let name = recipePlist[index]["Name"] as! String
                let category = recipePlist[index]["Category"] as! String
                let image = recipePlist[index]["Image"] as! String
                let ingredient = recipePlist[index]["Ingredient"] as! String
                let step = recipePlist[index]["Step"] as! String

                let itemRecipe = Recipe(name: name, category: category, image: image, ingredient: ingredient, step: step)
                recipe.append(itemRecipe)
            }
        }
    }

    func setupButton(){
        let buttonTopAdd = UIButton()
        buttonTopAdd.setImage(UIImage(named:"icn-add"), for: .normal)
        let barButton = UIBarButtonItem(customView: buttonTopAdd)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        buttonTopAdd.addTarget(self, action: #selector(doBtnAddNewRecipe), for: .touchUpInside)
        btnFilter.addTarget(self, action: #selector(doBtnFilter), for: .touchUpInside)
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        
        let itemWidth = (self.view.bounds.width / 2) - (10/2)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "RecipeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "recipeCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //MARK:- Event Action
    @objc func doBtnFilter(){
        let nib = UINib(nibName: "PopOutView", bundle: nil)
        let myNibView = nib.instantiate(withOwner: self, options: nil)[0] as! PopOutView
        
        myNibView.frame = self.view.bounds
        myNibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myNibView.delegate = self
        myNibView.setupView()
        myNibView.setupPickerView(item: categoryArr)
        
        let currentWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        UIView.transition(with: currentWindow!, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve,
                          animations: {
                            currentWindow!.addSubview(myNibView)
        }, completion: nil)
    }
    
    @objc func doBtnAddNewRecipe(){
        let vc = NewRecipeViewController(nibName: "NewRecipeViewController", bundle: nil)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- XMLParserDelegate
extension MainPageViewController: XMLParserDelegate{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        self.element = elementName

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "category"{
            categoryArr.append(category)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            if element == "category"{
                category = data
            }
        }
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension MainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedCategory != "All"{
            var count = 0
            for index in 0 ..< recipe.count{
                if recipe[index].category == selectedCategory{
                    count += 1
                }
            }
            return count
            
        }else{
            return recipe.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCollectionViewCell
        
        if selectedCategory != "All"{
            var item = [Recipe]()
            for index in 0 ..< recipe.count{
                if recipe[index].category == selectedCategory{
                    item.append(recipe[index])
                }
            }
            cell.recipeName.text = item[indexPath.item].name
            cell.recipeCategory.text = item[indexPath.item].category
            cell.recipeImage.image = UIImage(named: item[indexPath.item].image)
        }else{
            let item = recipe
            
            cell.recipeName.text = item[indexPath.item].name
            cell.recipeCategory.text = item[indexPath.item].category
            cell.recipeImage.image = UIImage(named: item[indexPath.item].image)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = RecipeDetailsViewController(nibName: "RecipeDetailsViewController", bundle: nil)
        
        if selectedCategory != "All"{
            var item = [Recipe]()
            for index in 0 ..< recipe.count{
                if recipe[index].category == selectedCategory{
                    item.append(recipe[index])
                }
            }
            vc.recipeDetails = item[indexPath.item]
        }else{
            vc.recipeDetails = recipe[indexPath.item]
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- PopOutViewDelegate
extension MainPageViewController: PopOutViewDelegate{
    func doBtnOk(itemSelected: String) {
        btnFilter.setTitle(itemSelected, for: .normal)
        
        selectedCategory = itemSelected
        collectionView.reloadData()
    }
}
