//
//  CardPicker.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class MyPickerPopup: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    let pickerData: [String]
    let pickerView: UIPickerView
    let pickerCover: UILabel
    let pickerToolbar: UIToolbar
    let completion: ((Int) -> Void)

    init(_ pickerData: [String], row: Int, pickerView: UIPickerView, pickerCover: UILabel, pickerToolbar: UIToolbar, completion: @escaping (Int) -> Void) {
        self.pickerData = pickerData
        self.pickerView = pickerView
        self.pickerCover = pickerCover
        self.pickerToolbar = pickerToolbar
        self.completion = completion
        super.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = false
        pickerCover.isHidden = false
        pickerToolbar.isHidden = false

        pickerView.selectRow(row, inComponent: 0, animated: false)

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        pickerToolbar.items = [doneButton]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    @objc func done() {
        pickerToolbar.items = []
        pickerView.isHidden = true
        pickerCover.isHidden = true
        pickerToolbar.isHidden = true
        completion(pickerView.selectedRow(inComponent: 0))
    }

}
