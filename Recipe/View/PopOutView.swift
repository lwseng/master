//
//  PopOutView.swift
//  Recipe
//
//  Created by 2018MAC04 on 16/07/2021.
//

import UIKit

protocol PopOutViewDelegate {
    func doBtnOk(itemSelected: String)
}

class PopOutView: UIView {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    
    var category = [String]()
    var selectedCategory = ""
    var delegate: PopOutViewDelegate?
    
    func setupView(){
        setupButton()
    }
    
    func setupPickerView(item: [String]){
        for index in 0 ..< item.count{
            category.append(item[index])
        }
        pickerView.selectRow(1, inComponent: 0, animated: true)
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func setupButton(){
        btnCancel.addTarget(self, action: #selector(doBtnCancel), for: .touchUpInside)
        btnOk.addTarget(self, action: #selector(doBtnOk), for: .touchUpInside)
    }
    
    @objc func doBtnCancel(){
        self.removeFromSuperview()
    }
    
    @objc func doBtnOk(){
        self.delegate?.doBtnOk(itemSelected: selectedCategory.isEmpty ? category[0] : selectedCategory)
        self.removeFromSuperview()
    }
}

extension PopOutView: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 17)
        title.textColor = UIColor.black
        title.textAlignment = .center
        title.text = category[row]
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = category[row]
    }
}
