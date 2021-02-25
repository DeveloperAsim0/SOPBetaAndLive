//
//  RadiatorVolumeViewController.swift
//  SOP
//
//  Created by Shivam Saini on 24/06/19.
//  Copyright © 2019 StarTrack. All rights reserved.
//

import UIKit

class RadiatorVolumeViewController: BaseViewController {
    
    @IBOutlet weak var coilWeightTextField: UITextField!
    @IBOutlet weak var coilThicknessTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var loadingView: UIView!
    
    var thicknessPickerView = UIPickerView()
    var widthPickerView = UIPickerView()
    
    var widthData = ["520","305","230"]
    var thicknessData = ["0.9","0.8","1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        thicknessPickerView.delegate = self
        thicknessPickerView.dataSource = self
        
        widthPickerView.delegate = self
        widthPickerView.dataSource = self
        
        coilThicknessTextField.inputView = thicknessPickerView
        widthTextField.inputView = widthPickerView
    }
    
    //MARK:- IB-ACTION'S
    
    
    @IBAction func cancelButtonDidPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonDidPressed(_ sender: Any) {
        if isValidated() {
            self.apiCall()
        }else {
            self.show(alertWithTitle: "SOP Alert", message: "Please Enter All Fields.")
        }
    }
    
    
    //MARK:- Supporting Functions
    func isValidated() -> Bool {
        guard self.coilThicknessTextField.text!.count > 0 else { return false}
        guard self.coilWeightTextField.text!.count > 0 else { return false }
        guard self.widthTextField.text!.count > 0 else { return false }
        return true
    }
    
    func generateParams() -> [String:Any] {
        return ["coil_weight": self.coilWeightTextField.text!,
                "coil_thickness": self.coilThicknessTextField.text!,
                "width": self.widthTextField.text!,
                "stage_priority"   : UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""]
    }
    
    func apiCall() {
        loadingView.isHidden = false
        NetwokHandler.post(url: UrlPaths.radiatorVolume,
                           object: generateParams()) { (response, error) in
                            self.loadingView.isHidden = true
                            if error != nil {
                                self.show(alertWithTitle: "Server Error",
                                          message: error ?? "")
                            }else {
                                if let dataResponse = response {
                                    if let apiError = dataResponse["error"] as? Bool,
                                        !apiError {
                                        self.dismiss(animated  : true,
                                                     completion: nil)
                                        NotificationCenter.default.post(name: NSNotification.Name("ReloadScanHistoryNotification"),
                                                                        object: nil)
                                    }else {
                                        // if error == true
                                        self.show(alertWithTitle: "Server Alert",
                                                  message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                                    }
                                }
                            }
        }
    }
}

extension RadiatorVolumeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case thicknessPickerView:
            return self.thicknessData.count
        case widthPickerView:
            return self.widthData.count
        default:
            return self.thicknessData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case thicknessPickerView:
            return self.thicknessData[row]
        case widthPickerView:
            return self.widthData[row]
        default:
            return self.thicknessData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case thicknessPickerView:
            self.coilThicknessTextField.text = self.thicknessData[row]
        case widthPickerView:
            self.widthTextField.text = self.widthData[row]
        default:
            self.coilThicknessTextField.text = self.thicknessData[row]
        }
    }
    
    
}
