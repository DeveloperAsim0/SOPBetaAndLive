//
//  ViewController.swift
//  SOP
//
//  Created by Shivam Saini on 04/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet var nameStackView: UIStackView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loadingView: UIView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameStackView.alpha = 0
        startAnimation()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func startAnimation() {
        UIView.animate(withDuration: 1) {
            self.nameStackView.alpha = 1.0
        }
    }

    @IBAction func signIn(buttonDidPressed sender: UIButton) {
        if validate() {
            self.loadingView.isHidden = false
            NetwokHandler.post(url: .login,
                               object: generateParams()) { (response, error) in
                                self.loadingView.isHidden = true
                                if error != nil {
                                    self.show(alertWithTitle: "Server Alert",
                                              message: error ?? "")
                                }else {
                                    // SafeCating reponse
                                    if let dataResponse = response {
                                        print(response!)
                                        if let apiError = dataResponse["error"] as? Bool,
                                            !apiError {
                                            self.responseHandler(data: dataResponse)
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
    
    //MARK:- Supporting Functions
    
    func validate() -> Bool {
        guard self.emailTextField.text!.count > 0 else {
            self.show(alertWithTitle: "SOP Alert",
                      message: "Please Enter Email/User-ID")
            return false
        }
        guard self.passwordTextField.text!.count > 0 else {
            self.show(alertWithTitle: "SOP Alert",
                      message: "Please Enter Password")
            return false
        }
        
        return true
    }
    
    func generateParams() -> Dictionary {
        return ["email"     : self.emailTextField.text ?? "",
                "password"  : self.passwordTextField.text ?? ""]
    }
    
    func responseHandler(data: JSON) {
        if let data = data["data"] as? Dictionary {
            if let userId = data["id"] as? Int {
                let stageName = data["name"] as? String
                let stage = data["stages"] as? [[String:Any]] ?? []
                let priority = stage[0]["priority"] as? Int ?? 0
                UserDefaults.standard.set("\(priority)",
                                          forKey: "kUserStage")
                UserDefaults.standard.set("\(userId)", forKey: "kUserId")
                UserDefaults.standard.set(stageName, forKey: "stageName")
                self.performSegue(withIdentifier: "LoginToHome",
                                  sender: nil)
            }
        }
    }
    
    //MARK:- TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.passwordTextField.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
            self.signIn(buttonDidPressed: UIButton())
        }
        return false
    }
    
}

