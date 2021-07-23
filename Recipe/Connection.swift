//
//  Connection.swift
//  Recipe
//
//  Created by 2018MAC04 on 22/07/2021.
//

import Foundation
import SQLite

func firstTimeLaunchApp() -> Bool{
    if let firstLaunch = UserDefaults.standard.value(forKey: "isFirstTimeLaunch") as? Bool{
        return firstLaunch
    }
    return true
}

func dbConnection() throws -> Connection {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let db = try Connection("\(path)/db.sqlite3")
    return db
}

func createAndInitDb(){
    do{
        let db = try dbConnection()
                
        let table = Table("Recipe")
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        let category = Expression<String>("category")
        let image = Expression<String>("image")
        let ingredient = Expression<String>("ingredient")
        let step = Expression<String>("step")
        
        //"CREATE TABLE "Recipe"
        //("id" INTEGER PRIMARY KEY NOT NULL,
        //"name" TEXT NOT NULL,
        //"category" TEXT NOT NULL,
        //"image" BLOB NOT NULL,
        //"ingredient" TEXT NOT NULL,
        //"step" TEXT NOT NULL)"
        try db.run(table.create{ t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(category)
            t.column(image)
            t.column(ingredient)
            t.column(step)
        })
        
        if let path = Bundle.main.path(forResource: "recipeData", ofType: "plist") {
            guard let recipeDict = NSDictionary(contentsOfFile: path) else {
                return
            }

            let recipePlist = recipeDict["Recipe"] as! [[String: Any]]

            for index in 0 ..< recipePlist.count{
                
                let recipeName = recipePlist[index]["Name"] as! String
                let recipeCategory = recipePlist[index]["Category"] as! String
                
                //convert image to base64
                let imageStr = UIImage(named: recipePlist[index]["Image"] as! String)!
                let imageData = imageStr.pngData()! as NSData
                let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                
                let recipeIngredient = recipePlist[index]["Ingredient"] as! String
                let recipeStep = recipePlist[index]["Step"] as! String

                try db.run(table.insert(id <- Int64(1000 + index), name <- recipeName,
                                        category <- recipeCategory, image <- strBase64,
                                        ingredient <- recipeIngredient, step <- recipeStep))
            }
        }
    }catch{
        print(error)
    }
}
