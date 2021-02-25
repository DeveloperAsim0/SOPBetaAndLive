//
//  QualityCheckViewController.swift
//  SOP
//
//  Created by Shivam Saini on 08/03/20.
//  Copyright © 2020 StarTrack. All rights reserved.
//

import UIKit

class QualityCheckViewController: BaseViewController {
    
    @IBOutlet weak var centerToCenterTxt: UITextField!
    @IBOutlet weak var FlangeThicknessTxt: UITextField!
    @IBOutlet weak var minDiameterHoleTxt: UITextField!
    @IBOutlet weak var finThicknessTxt: UITextField!
    @IBOutlet weak var rodThicknessText: UITextField!
    
    @IBOutlet weak var diagonalDeflectionSwitch: UISwitch!
    @IBOutlet weak var asPerDrawingSwitch: UISwitch!
    @IBOutlet weak var dimensionCheckSwitch: UISwitch!
    
    @IBOutlet weak var loadingView: UIView!
    
    var latitutude = String()
    var longitude = String()
    var code = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func isValidated() -> Bool {
        guard self.centerToCenterTxt.text!.count > 0 else {return false}
        guard self.FlangeThicknessTxt.text!.count > 0 else {return false}
        guard self.minDiameterHoleTxt.text!.count > 0 else {return false}
        guard self.finThicknessTxt.text!.count > 0 else {return false}
        guard self.rodThicknessText.text!.count > 0 else {return false}
        return true
    }
    
    func paramGenerator() -> [String:Any] {
        return [ "serial_no" : code,
                 "user_id"   : UserDefaults.standard.object(forKey: "kUserId") ?? "",
                 "latitude"  : self.latitutude,
                 "longitude" : self.longitude,
                 "center_to_center": self.centerToCenterTxt.text!,
                 "flange_thickness": self.FlangeThicknessTxt.text!,
                 "min_dia_of_hole": self.minDiameterHoleTxt.text!,
                 "min_fin_thickness": self.finThicknessTxt.text!,
                 "min_rod_thickness": self.rodThicknessText.text!,
                 "diagonal_deflection": self.diagonalDeflectionSwitch.isOn ? 1 : 0,
                 "as_per_drawing": self.asPerDrawingSwitch.isOn ? 1 : 0,
                 "all_diamension_check": self.dimensionCheckSwitch.isOn ? 1 : 0,
                 "stage_priority"   : UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
        ]
    }
    
    func uploadScan() {
        self.loadingView.isHidden = false
        
        NetwokHandler.post(url: .uploadBarcode, object: self.paramGenerator()) { (response, error) in
            self.loadingView.isHidden = true
            if error != nil {
                self.show(alertWithTitle: "Server Alert",
                          message: error ?? "")
            }else {
                // SafeCasting Response
                if let dataResponse = response {
                    print(dataResponse)
                    if let apiError = dataResponse["error"] as? Bool,
                        !apiError {
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("ReloadScanHistoryNotification"), object: nil)
                    }else {
                        self.show(alertWithTitle: "Server Alert",
                                  message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                    }
                    
                }
            }
        }
    }
    
    @IBAction func cancelButtonDidPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonDidPressed(_ sender: UIButton) {
        if self.isValidated() {
            self.uploadScan()
        }else {
            self.show(alertWithTitle: "SOP Alert", message: "Please Enter All Fields.")
        }
    }
    
    
}
