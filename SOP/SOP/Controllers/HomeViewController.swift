//
//  HomeViewController.swift
//  SOP
//
//  Created by Shivam Saini on 06/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit
import CoreLocation
import BarcodeScanner
import SwiftMoment

var isWeightStage:Bool {
    if let stage = UserDefaults.standard.object(forKey: "kUserStage") as? String {
        return ["10","14", "20"].contains(stage.lowercased())
    }else {
        return false
    }
}

var isstageg9:Bool {
    if let stage = UserDefaults.standard.object(forKey: "kUserStage") as? String {
        return ["9"].contains(stage.lowercased())
    } else {
        return false
    }
}

var isPacking:Bool {
    let stage = UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
    return ["20"].contains(stage.lowercased())
}

var isWeightScanInAndOut: Bool {
    let stage = UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
    return ["10"].contains(stage.lowercased())
}

var isWeightAirAndWaterStage: Bool {
    let stage = UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
    return ["3","14"].contains(stage.lowercased())
}

var isStage1: Bool {
    return "stage 1" == (UserDefaults.standard.object(forKey: "kUserStage") as? String ?? "").lowercased()
}

var isBucketStage: Bool {
    let stage = (UserDefaults.standard.object(forKey: "kUserStage") as? String ?? "").lowercased()
    return ["4","18"].contains(stage.lowercased())
}

var isPriority6: Bool {
    let stage = (UserDefaults.standard.object(forKey: "kUserStage") as? String ?? "").lowercased()
    return ["6","21"].contains(stage.lowercased())
}

var checkTimePriority: Bool {
    let stage = (UserDefaults.standard.object(forKey: "kUserStage") as? String ?? "").lowercased()
    return ["12","16","17"].contains(stage.lowercased())
}

var SecondStagePriority: Bool {
    let stage = (UserDefaults.standard.object(forKey: "kUserStage") as? String ?? "").lowercased()
    return ["2"].contains(stage.lowercased())
}

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var barcodeTextField: UITextField!
    @IBOutlet var scanTableView: UITableView!
    @IBOutlet var stageTitleLabel: UILabel!
    @IBOutlet var loaderView: UIView!
    @IBOutlet var totalCount: UILabel!
    @IBOutlet var totalMeters: UILabel!
    @IBOutlet weak var logutBtn: UIBarButtonItem!
    @IBOutlet weak var addRadiatorButton: UIBarButtonItem!
    
    var savedserial = [String]()
    
    // get the current date and time
    let currentDateTime = Date()

    // initialize the date formatter and set the style
    let formatter = DateFormatter()
    let timeformatter = DateFormatter()
    
    let CELL_IDENTIFIRE = "ScanHistoryCell"
    
    let locationManager = CLLocationManager()
    
    var scanHistory:[[String:Any]] = []
    
    var latitutude = String()
    var longitude = String()
    
    var totalRunningMeter = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocationManager()
        self.scanTableView.delegate = self
        self.scanTableView.dataSource = self
        print("datetime:-\(self.GetCurrentdate()):\(self.GetCurrenttime())")
        let addRadiatorButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                target: self,
                                                action: #selector(self.addRadiatorButtonDidPressed))
        addRadiatorButton.tintColor = UIColor.white
        addRadiatorButton.title = "Add"
        if isStage1 {
            self.navigationItem.leftBarButtonItem = addRadiatorButton
        }
        
        // get Scan Histories
        self.loadScanHistory()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getRadiatorScanHostory),
                                               name: NSNotification.Name("ReloadScanHistoryNotification"),
                                               object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func getRadiatorScanHostory() {
        self.loadScanHistory()
    }
    
    @objc func addRadiatorButtonDidPressed() {
        performSegue(withIdentifier: "PresentAddRadiator",
                     sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Request Location
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.222776711, green: 0.5253188014, blue: 0.6992447376, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    @IBAction func barcodeButtonDidPressed(_ sender: UIButton) {
        let barCodeViewController = BarcodeScannerViewController()
        barCodeViewController.codeDelegate = self
        navigationController?.pushViewController(barCodeViewController, animated: true)
    }
    
    @IBAction func logoutButtonDidPressed(_ sender: UIBarButtonItem) {
         UserDefaults.standard.removeObject(forKey: "stageName")
        UserDefaults.standard.removeObject(forKey: "kUserId")
        self.performSegue(withIdentifier: "HomeToLogin", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qualityCheck" {
            if let desitnationVC = segue.destination as? QualityCheckViewController {
                desitnationVC.code = self.barcodeTextField.text ?? ""
                desitnationVC.latitutude = self.latitutude
                desitnationVC.longitude = self.longitude
            }
        }
    }
    
    
    //MARK:- Table-View Delegate and DataSource
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isStage1 {
            return tableView.dequeueReusableCell(withIdentifier: "stage1HeaderCell")!
        }else if isWeightAirAndWaterStage {
            return tableView.dequeueReusableCell(withIdentifier: "stage14headerCell")!
        }else {
            let header =  tableView.dequeueReusableCell(withIdentifier: "headerCell")!
            if let containerView = header.viewWithTag(2),
               let weightHeaderLabel = containerView.viewWithTag(123) as? UILabel{
                weightHeaderLabel.text = isWeightStage ? "Weight" : "R.Mtr"
            }
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scanHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIRE,
                                                 for: indexPath) as! ScanHistoryTableViewCell
        let currentItem = self.scanHistory[indexPath.row]
        let jobItem = currentItem["job_item"] as? [String:Any]
        
        if isStage1 {
            cell.jobNumber.text = String((currentItem["date"] as? String)?.prefix(10) ?? "")
            cell.date.text = "\(currentItem["id"]!)"
            cell.timeIn.text = "\(currentItem["coil_weight"]!)"
            cell.timeOut.text = String(("\(currentItem["coil_thickness"]!)").prefix(3))
            cell.RMeter.text = "\(currentItem["width"]!)"
        }else if isWeightAirAndWaterStage {
            cell.jobNumber.text = jobItem?["serial_no"] as? String ?? ""
            cell.date.text = String((currentItem["created"] as? String)?.prefix(10) ?? "")
            cell.timeIn.text = String(format: "%.1f", jobItem!["weight_in_air"] as? Double ?? 0.0)
            cell.timeOut.text = String(format: "%.1f", jobItem!["weight_in_water"] as? Double ?? 0.0)
            cell.RMeter.text = ""
        }else {
            cell.jobNumber.text = jobItem?["serial_no"] as? String ?? ""
            cell.date.text = String((currentItem["created"] as? String)?.prefix(10) ?? "")
            cell.timeIn.text = currentItem["time_in"] as? String ?? ""
            cell.timeOut.text = currentItem["time_out"] as? String ?? ""
            cell.RMeter.text = isWeightStage ? "\(jobItem!["weight"]!)" : "\(currentItem["running_meter"]!)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- API Calls
    
    func loadScanHistory() {
        if let userId = UserDefaults.standard.object(forKey: "kUserId") as? String,
           let id = Int(userId) {
            self.loaderView.isHidden = false
            if isStage1 {
                NetwokHandler.get(url: .radiatorList) { (response, error) in
                    self.loaderView.isHidden = true
                    if error != nil {
                        self.show(alertWithTitle: "Server Alert",
                                  message: error ?? "")
                    }else {
                        // SafeCasting Response
                        if let dataResponse = response {
                            print(dataResponse)
                            if let apiError = dataResponse["error"] as? Bool,
                               !apiError {
                                if let data = dataResponse["data"] as? [[String:Any]] {
                                    self.scanHistory = data
                                    self.scanTableView.reloadData()
                                }
                            }else {
                                //                            if error == true
                                self.show(alertWithTitle: "Server Alert",
                                          message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                            }
                            
                        }
                        
                    }
                }
            }else {
                NetwokHandler.get(url: .scanHistory(id)) { (response, error) in
                    self.loaderView.isHidden = true
                    if error != nil {
                        self.show(alertWithTitle: "Server Alert",
                                  message: error ?? "")
                    }else {
                        // SafeCasting Response
                        if let dataResponse = response {
                            print(dataResponse)
                            if let apiError = dataResponse["error"] as? Bool,
                               !apiError {
                                self.responseHandler(data: dataResponse)
                            }else {
                                //                            if error == true
                                self.show(alertWithTitle: "Server Alert",
                                          message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                            }
                            
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func isAlreadyScanned(code: String) -> Bool {
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        return alreadyScaned
    }
    
    func uploadScan(code:String, withWeight weight:String = "", isStage14: Bool, WeightofStiffner:String, Weightoffin:String, Weightofpipe:String) {
        self.loaderView.isHidden = false
        var param:[String:Any] = [
            "serial_no" : code,
            "user_id"   : UserDefaults.standard.object(forKey: "kUserId") ?? "",
            "latitude"  : self.latitutude,
            "longitude" : self.longitude,
            "weightofStiffner": WeightofStiffner,
            "Weightoffin": Weightoffin,
            "Weightofpipe": Weightofpipe,
            
            "stage_priority"   : UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
        ]
        
        if weight != "" {
            param[isAlreadyScanned(code: code) ? "weight_out" : "weight_in"] = weight
        }
        
        print("params>>>>",param)
        
        NetwokHandler.post(url: .uploadBarcode, object: param) { (response, error) in
            self.loaderView.isHidden = true
            if error != nil {
                self.show(alertWithTitle: "Server Alert",
                          message: error ?? "")
            }else {
                // SafeCasting Response
                if let dataResponse = response {
                    print(dataResponse)
                    self.loadScanHistory()
                    if let apiError = dataResponse["error"] as? Bool,
                       !apiError {
                        //                        self.loadScanHistory()
                    }else {
                        //                   if error == true
                        self.show(alertWithTitle: "Server Alert",
                                  message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                    }
                    
                }
            }
        }
    }
    
    //MARK:- Supporting Function
    func responseHandler(data: JSON) {
        let jsonData = data["data"] as! Dictionary
        if let jobItemHistories = jsonData["jobItemHistories"] as? [[String:Any]] {
            self.scanHistory = jobItemHistories
            self.scanTableView.reloadData()
            self.totalCount.text = "Total Count - \(jobItemHistories.count)"
            if jobItemHistories.count > 0,
               let stage = jobItemHistories[0]["stage"] as? JSON {
                let stageName = UserDefaults.standard.string(forKey: "stageName")
                print("st:- \(stageName)")
                let setTitle = stageName?.uppercased() ?? "" + " "
                self.stageTitleLabel.text = setTitle + ": \(stage["name"]!)"
                
                self.totalRunningMeter = 0.0
                for item in jobItemHistories {
                    if let meter = item["running_meter"] as? String {
                        self.totalRunningMeter += Double(meter) ?? 0.0
                    }
                }
                
                self.totalMeters.text = "R.Mtr - \(self.totalRunningMeter)"
                
            }
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
}

//MARK:- Barcode Delegate
extension HomeViewController: BarcodeScannerCodeDelegate {
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        
        if isPriority6 {
            if alreadyScaned {
                self.normalScanWithoutWeight(code: code)
            }else {
                self.navigationController?.popViewController(animated: true)
                self.barcodeTextField.text = code
                self.performSegue(withIdentifier: "qualityCheck", sender: nil)
            }
        }else if isBucketStage {
            self.bucketAlert(code: code)
        } else if checkTimePriority {
            self.checkpriority(code: code)
        } else if SecondStagePriority {
            self.SecondStageCoil(code: code)
        }else if isstageg9{
            if alreadyScaned {
                self.normalScanWithoutWeight(code: code)
            } else {
            showstage9alerts(code: code)
            }
        } else {
            if isWeightStage {
                self.showWeightAlert(code: code)
            }else {
                self.normalScanWithoutWeight(code: code)
            }
        }
    }
    
    func normalScanWithoutWeight(code: String) {
        self.navigationController?.popViewController(animated: true)
        self.barcodeTextField.text = code
       self.uploadScan(code: code, withWeight: "", isStage14: isWeightAirAndWaterStage, WeightofStiffner: "", Weightoffin: "", Weightofpipe: "")
        
    }
}


//MARK:- Location Delegate

extension HomeViewController {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let cordinates = manager.location?.coordinate
        print(cordinates!.longitude)
        print(cordinates!.latitude)
        self.latitutude = String(describing: cordinates!.latitude)
        self.longitude = String(describing: cordinates!.longitude)
    }
}

extension HomeViewController {
    
    func showstage9alerts(code:String) {
            let alertController = UIAlertController(title: "Plese Enter Below Details", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                   textField.placeholder = "Enter Weight of Stiffner"
                textField.keyboardType = .decimalPad
               }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                   let weightofsnif = alertController.textFields![0] as UITextField
                   let weightoffin = alertController.textFields![1] as UITextField
                   let weightofpipeinclude = alertController.textFields![2] as UITextField
                if weightofsnif.text?.isEmpty == true ||  weightoffin.text?.isEmpty == true || weightofpipeinclude.text?.isEmpty == true {
                    self.navigationController?.popViewController(animated: true)
                } else {
                 self.navigationController?.popViewController(animated: true)
                            self.barcodeTextField.text = code
                            self.uploadScan(code: code, withWeight: "", isStage14: isWeightAirAndWaterStage, WeightofStiffner: weightofsnif.text ?? "", Weightoffin: weightoffin.text ?? "", Weightofpipe: weightofpipeinclude.text ?? "")
                }
    //
                
               })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                   (action : UIAlertAction!) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addTextField { (textField : UITextField!) -> Void in
                   textField.placeholder = "Weight of 1 fin"
                textField.keyboardType = .decimalPad
               }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Weight of pipe (including accessories)"
                textField.keyboardType = .decimalPad
            }
               
               alertController.addAction(saveAction)
               alertController.addAction(cancelAction)
               
            self.present(alertController, animated: true, completion: nil)
        }
    
    func showWeightAlert(code:String) {
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        
        alreadyScaned = isWeightAirAndWaterStage ? false : alreadyScaned
        
        let weightAlert = UIAlertController(title: "Enter Weight",
                                            message: nil,
                                            preferredStyle: .alert)
        weightAlert.addTextField { (textField) in
            textField.placeholder = "Enter Weight"
            textField.keyboardType = .decimalPad
        }
        
        weightAlert.addAction(UIAlertAction(title: "OK", style: .default,
                                            handler: { [weak weightAlert] (sender) in
                                                let weightTextField = (weightAlert?.textFields?[0])!
                                                let weight = weightTextField.text ?? ""
                                                if weight != "" {
                                                    self.navigationController?.popViewController(animated: true)
                                                    self.barcodeTextField.text = code
                                                
                                                    self.uploadScan(code: code, withWeight: weight, isStage14: isWeightAirAndWaterStage, WeightofStiffner: "", Weightoffin: "", Weightofpipe: "")
                                                }else {
                                                    self.navigationController?.popViewController(animated: true)
                                                }
                                                
                                            }))
        
        weightAlert.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: { (_) in
                                                self.navigationController?.popViewController(animated: true)
                                            }))
        
        if isWeightScanInAndOut {
            self.present(weightAlert,
                         animated: true,
                         completion: nil)
        }else if alreadyScaned && isPacking{
            self.present(weightAlert,
                         animated: true,
                         completion: nil)
        }else{
            if alreadyScaned || isPacking {
                self.navigationController?.popViewController(animated: true)
                self.barcodeTextField.text = code

                self.uploadScan(code: code, withWeight: "", isStage14: isWeightAirAndWaterStage, WeightofStiffner: "", Weightoffin: "", Weightofpipe: "")
            }else {
                self.present(weightAlert,
                             animated: true,
                             completion: nil)
            }
        }
    }
    
    func bucketAlert(code: String) {
        
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        
        let bucketAlert = UIAlertController(title: "Enter Bucket Number and Weight",
                                            message: nil,
                                            preferredStyle: .alert)
        if !alreadyScaned {
            bucketAlert.addTextField { (textField) in
                textField.placeholder = "Enter Bucket Number"
            }
        }
        bucketAlert.addTextField { (textField) in
            textField.placeholder = "Enter Weight"
            textField.keyboardType = .decimalPad
        }
        
        bucketAlert.addAction(UIAlertAction(title: "OK", style: .default,
                                            handler: { [weak bucketAlert] (sender) in
                                                if alreadyScaned {
                                                    let weightTextField = (bucketAlert?.textFields?[0])!
                                                    let weight = weightTextField.text ?? ""
                                                    if weight != "" {
                                                        self.navigationController?.popViewController(animated: true)
                                                        self.barcodeTextField.text = code
                                                        self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: weight, bucketNumber: "", coil_no: "")
                                                    }else {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }else {
                                                    let bucketTextField = (bucketAlert?.textFields?[0])!
                                                    let bucketNumber = bucketTextField.text ?? ""
                                                    let weightTextField = (bucketAlert?.textFields?[1])!
                                                    let weight = weightTextField.text ?? ""
                                                    if bucketNumber != "" && weight != "" {
                                                        self.navigationController?.popViewController(animated: true)
                                                        self.barcodeTextField.text = code
                                                        self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: weight, bucketNumber: bucketNumber, coil_no: "")
                                                    }else {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }
                                            }))
        
        bucketAlert.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: { (_) in
                                                self.navigationController?.popViewController(animated: true)
                                            }))
        
        self.present(bucketAlert,
                     animated: true,
                     completion: nil)
        
    }
    
    func SecondStageCoil(code: String) {
        
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        
        if alreadyScaned {
            self.navigationController?.popViewController(animated: true)
            self.barcodeTextField.text = code
            self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: "", bucketNumber: "", coil_no: "")
        } else {
            let bucketAlert = UIAlertController(title: "Enter Coil Number",
                                                       message: nil,
                                                       preferredStyle: .alert)
                   
                       bucketAlert.addTextField { (textField) in
                           textField.placeholder = "Enter Coil Number"
                       }
                       bucketAlert.addAction(UIAlertAction(title: "OK", style: .default,
                                                                  handler: { [weak bucketAlert] (sender) in
                                              
                                                                          let bucketTextField = (bucketAlert?.textFields?[0])!
                                                                          let bucketNumber = bucketTextField.text ?? ""
                                                  
                                                                          if bucketNumber != ""{
                                                                              self.navigationController?.popViewController(animated: true)
                                                                              self.barcodeTextField.text = code
                                                                              self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: "", bucketNumber: "", coil_no: bucketNumber)
                                                                          }else {
                                                                              self.navigationController?.popViewController(animated: true)
                                                                          }
                                                                     
                                                                  }))
                              
                              bucketAlert.addAction(UIAlertAction(title: "Cancel",
                                                                  style: .cancel,
                                                                  handler: { (_) in
                                                                      self.navigationController?.popViewController(animated: true)
                                                                  }))
                              
                              self.present(bucketAlert,
                                           animated: true,
                                           completion: nil)
                 
                  
        }
        
       
        
    }

    
    func uploadForBucket(alreadyScanned: Bool, code: String, weigth: String, bucketNumber:String, coil_no:String) {
        self.loaderView.isHidden = false
        let priority = UserDefaults.standard.object(forKey: "kUserStage") as? String ?? ""
        let param:[String:Any] = [
            "serial_no" : code,
            "user_id"   : UserDefaults.standard.object(forKey: "kUserId") ?? "",
            "latitude"  : self.latitutude,
            "longitude" : self.longitude,
            "coil_no" : coil_no,
            "bucket_no_\(priority)" : bucketNumber,
            alreadyScanned ? "weight_out" : "weight_in" : weigth,
            "stage_priority"   : priority
        ]
        print("params:-\(param)")
        NetwokHandler.post(url: .uploadBarcode, object: param) { (response, error) in
            self.loaderView.isHidden = true
            if error != nil {
                self.show(alertWithTitle: "Server Alert",
                          message: error ?? "")
            }else {
                // SafeCasting Response
                if let dataResponse = response {
                    print(dataResponse)
                    self.loadScanHistory()
                    if let apiError = dataResponse["error"] as? Bool,
                       !apiError {
                        //                        self.loadScanHistory()
                    }else {
                        //                   if error == true
                        self.show(alertWithTitle: "Server Alert",
                                  message: dataResponse["message"] as? String ?? "Something went wrong, Please try again")
                    }
                    
                }
            }
        }
    }
    
    //MARK:- Difference between two times
    func findDateDiff(time1Str: String, time2Str: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "yyyy-MM-dd hh:mm a" //"hh:mm a"
        print("chlal:-\(time1Str):\(time2Str)")
        guard let time1 = timeformatter.date(from: time1Str),
        let time2 = timeformatter.date(from: time2Str) else { return "" }

        //You can directly use from here if you have two dates

        let interval = time2.timeIntervalSince(time1)
        let hour = interval / 3600;
        _ = interval.truncatingRemainder(dividingBy: 3600) / 60
        _ = Int(interval)
        return "\(Int(hour))"
    }
    
    //MARK:- Supporting Functions
    
    func GetCurrenttime() -> String {
       timeformatter.timeStyle = .short
        // get the date time String from the date object
        let cu = timeformatter.string(from: currentDateTime)
        print("timecur:-\(cu)")
       return cu
    }
    
    func GetCurrentdate() -> String {
     //  formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // get the date time String from the date object
        let cu = formatter.string(from: currentDateTime)
        print("timecur:-\(cu)")
       return cu
    }
    
    func getFullcurrent() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd hh:mm a"
        let x = f.string(from: currentDateTime)
        return x
    }
    
    func findDateDiff2(time1Str: String, time2Str: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let time1 = timeformatter.date(from: time1Str),
            let time2 = timeformatter.date(from: time2Str) else { return "" }

        //You can directly use from here if you have two dates

        let interval = time2.timeIntervalSince(time1)
        let hour = interval / 3600;
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        _ = Int(interval)
        return "\(Int(hour)) Hours \(Int(minute)) Minutes"
    }
    
    func validateTimeDifference(code:String) -> Bool {
          for i in self.scanHistory {
                    let ser = i["job_item"]as? [String:Any]
                    print("print;\(ser?["serial_no"] as? String ?? "")")
                    let currentserialno = ser?["serial_no"] as? String ?? ""
            if code == currentserialno {
                let data = String((i["created"] as? String)?.prefix(10) ?? "")
                print("dt:-\(data)")
                let currentdate = self.GetCurrentdate()
             //   if data == currentdate {
                    
                    let time = i["time_in"] as? String ?? ""
                    print("tt:-\(time)")
                
                //MARK:- Merge Time & Date
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
                let string = data + " " + time
                let cpr = self.getFullcurrent()
                print("march:-\(string):cur:-\(cpr)")// "March 24, 2017 at 7:00 AM"
                let finalDate = dateFormatter.date(from: string)
                _ = finalDate?.description ?? ""
                let co = dateFormatter.string(from: finalDate!)
                
                let dated = moment(finalDate!)
                print("finest:-\(co):\(dated + 6.hours):\(currentdate)")
                let added = dated + 6.hours
                _ = "2020-02-20 01:20 PM"
                    let currenttime = self.GetCurrenttime()
               
                    let diff = self.findDateDiff(time1Str: string, time2Str: cpr)
                    print("yo:-\(diff)")
                    print("time:-\(time): \(currenttime)")
                    let conver = Int(diff)
                let timeformatter = DateFormatter()
                       timeformatter.dateFormat = "yyyy-MM-dd hh:mm a" //"hh:mm a"
                     
                      let timee = timeformatter.date(from: string)
                let mhour = moment(timee!)
                   
                _ = Calendar.current.date(byAdding: .minute, value: 360, to: timee!)
                print("addhour:-\(mhour + 6.hours)")
                let prefix = mhour + 6.hours
                let changestringprefix = "\(prefix)"
                let hardestprefix = changestringprefix.prefix(16)
                
                let mess = hardestprefix.suffix(5)
                print("print:-\(mess.description)")
                let changestring = "\(added)".prefix(19)
                 print("tiert:-\(changestring):cure:\(currentdate)")
                let messagetime = self.findDateDiff2(time1Str: currentdate, time2Str: String(changestring))
                print("lefthours:-\(messagetime)")
                    guard conver! >= 6 else {
                       // Create the alert controller
                        let alertController = UIAlertController(title: "SOP Alert", message: "Please wait till " + mess.description + " before you can time out", preferredStyle: .alert)
                        // Create the actions
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                            UIAlertAction in
                            self.navigationController?.popViewController(animated: true)
                        }
                        // Add the actions
                        alertController.addAction(okAction)
                        // Present the controller
                        self.present(alertController, animated: true, completion: nil)
                    return false
              }
            }
         }
           return true
    }
    
    func checkpriority(code: String) {
        
        var alreadyScaned = false
        
        for item in self.scanHistory {
            if let jobItem = item["job_item"] as? [String:Any] {
                print("mycode:-\(jobItem["serial_no"] as! String):\(code)")
                if jobItem["serial_no"] as! String == code {
                    alreadyScaned = true
                    break
                }
            }
        }
        
        let bucketAlert = UIAlertController(title: "Enter Bucket Number and Weight",
                                            message: nil,
                                            preferredStyle: .alert)
        if !alreadyScaned {
            bucketAlert.addTextField { (textField) in
                textField.placeholder = "Enter Bucket Number"
            }
        }
        
        bucketAlert.addTextField { (textField) in
            textField.placeholder = "Enter Weight"
            textField.keyboardType = .decimalPad
        }
        
        bucketAlert.addAction(UIAlertAction(title: "OK", style: .default,
                                            handler: { [weak bucketAlert] (sender) in
                                                if alreadyScaned {
                                                    if self.validateTimeDifference(code: code) {
                                                        let weightTextField = (bucketAlert?.textFields?[0])!
                                                        let weight = weightTextField.text ?? ""
                                                        if weight != "" {
                                                            self.navigationController?.popViewController(animated: true)
                                                            self.barcodeTextField.text = code
                                                            self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: weight, bucketNumber: "", coil_no: "")
                                                        }else {
                                                            self.navigationController?.popViewController(animated: true)
                                                        }
                                                    }
                                                }else {
                                                    let bucketTextField = (bucketAlert?.textFields?[0])!
                                                    let bucketNumber = bucketTextField.text ?? ""
                                                    let weightTextField = (bucketAlert?.textFields?[1])!
                                                    let weight = weightTextField.text ?? ""
                                                    if bucketNumber != "" && weight != "" {
                                                        self.navigationController?.popViewController(animated: true)
                                                        self.barcodeTextField.text = code
                                                        self.uploadForBucket(alreadyScanned: alreadyScaned, code: code, weigth: weight, bucketNumber: bucketNumber, coil_no: "")
                                                    }else {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }
                                            }))
        
        bucketAlert.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: { (_) in
                                                self.navigationController?.popViewController(animated: true)
                                            }))
        
        self.present(bucketAlert,
                     animated: true,
                     completion: nil)
        
    }

    
}
