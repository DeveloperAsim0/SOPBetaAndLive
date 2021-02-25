//
//  NewViewController.swift
//  SOP
//
//  Created by Family on 04/11/20.
//  Copyright © 2020 StarTrack. All rights reserved.
//

import UIKit
import Lottie

class NewViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var loginViews: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailfield: UITextField!
    @IBOutlet weak var passwordfield: UITextField!
    @IBOutlet weak var animationView: UIView!
    
    private var LaodingAnimation: AnimationView?
    
    //MARK:- Create Animation
    fileprivate func StartAnimation() {
               animationView.isHidden = false
               self.view.isUserInteractionEnabled = false
               LaodingAnimation = .init(name: "8370-loading")
               
               LaodingAnimation!.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
               
               // 3. Set animation content mode
               
               LaodingAnimation!.contentMode = .scaleAspectFit
               
               // 4. Set animation loop mode
               
               LaodingAnimation!.loopMode = .loop
               
               // 5. Adjust animation speed
               
               LaodingAnimation!.animationSpeed = 2
               
               animationView.addSubview(LaodingAnimation!)
               
               // 6. Play animation
               
               LaodingAnimation!.play()
    }
    
    fileprivate func StopAnimation() {
        animationView.isHidden = true
        self.view.isUserInteractionEnabled = true
        LaodingAnimation!.stop()
    }
    
    //MARK:- Customize UIViews
       fileprivate func CustomizeViews() {
        loginViews.layer.cornerRadius = 15
        loginViews.clipsToBounds = true
        loginViews.layer.masksToBounds = false
        loginViews.layer.shadowRadius = 7
        loginViews.layer.shadowOpacity = 0.6
        loginViews.layer.shadowOffset = CGSize(width: 0, height: 5)
        loginViews.layer.shadowColor = UIColor.gray.cgColor
       }
    
    //MARK:- Customize Textfield
    fileprivate func CustomizeTextfield() {
        emailfield.attributedPlaceholder = NSAttributedString(string: " Enter Email/User Name",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 70/255, blue: 94/255, alpha: 1.0)])
        passwordfield.attributedPlaceholder = NSAttributedString(string: " Enter Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 70/255, blue: 94/255, alpha: 1.0)])
    }
    
    //MARK:- Customize Button
    fileprivate func CustomizeButton() {
        self.loginBtn.layer.cornerRadius = self.loginBtn.bounds.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
               emailfield.delegate = self
               passwordfield.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomizeViews()
        CustomizeButton()
        CustomizeTextfield()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signBtn(buttonDidPressed sender: UIButton) {
        if validate() {
           StartAnimation()
            NetwokHandler.post(url: .login,
                               object: generateParams()) { (response, error) in
                                self.StopAnimation()
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
        guard self.emailfield.text!.count > 0 else {
            self.show(alertWithTitle: "SOP Alert",
                      message: "Please Enter Email/User-ID")
            return false
        }
        guard self.passwordfield.text!.count > 0 else {
            self.show(alertWithTitle: "SOP Alert",
                      message: "Please Enter Password")
            return false
        }
        
        return true
    }
    
    func generateParams() -> Dictionary {
        return ["email"     : self.emailfield.text ?? "",
                "password"  : self.passwordfield.text ?? ""]
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
            self.passwordfield.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
            self.signBtn(buttonDidPressed: UIButton())
        }
        return false
    }
}
