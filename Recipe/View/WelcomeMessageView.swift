//
//  WelcomeMessageView.swift
//  Recipe
//
//  Created by 2018MAC04 on 23/07/2021.
//

import UIKit

class WelcomeMessageView: UIView {

    @IBOutlet weak var btnGetStarted: UIButton!
    
    func setupView(){
        btnGetStarted.addTarget(self, action: #selector(doBtnStart), for: .touchUpInside)
    }
    
    @objc func doBtnStart(){
        UserDefaults.standard.setValue(false, forKey: "isFirstTimeLaunch")
        self.removeFromSuperview()
    }
}
