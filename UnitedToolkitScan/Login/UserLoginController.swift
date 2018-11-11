//
//  UserLoginController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 9/30/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import KeychainAccess


class UserLogin: UIViewController, UITextFieldDelegate{
    
    //Text field for username and password
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func adminPortal(_ sender: UIButton) {
        if let url = URL(string: "http://35.9.22.103/admin") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    let sessionManager = loadSession()
    
    //var sessionManager: SessionManager?
    //Decodable JSON for authentication token from Django server
    struct JSONResponse: Decodable{
        let auth_token: String
    }
    
    //When login button is pressed, execute loginButtonPressedFunction below to send username and pass to server for auth
    @IBAction func login(_ sender: UIButton) {
        loginButtonPressed()
    }
    
    //Hide Navigation Controller on login page
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSession()
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    //Enable Navigation Controller after done with login
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false;
        username.text = ""
        password.text = ""
    }
    
    //Enables next button within iOS keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == username){
            username.resignFirstResponder()
            password.becomeFirstResponder()
        }
        else{
            password.resignFirstResponder()
            loginButtonPressed()
        }
        
        return true
    }
    
    //Handoff login credentials to Django server with Alamofire
    func loginButtonPressed(){
        //Does not try to login if user forgets to input username or password
        if(username.text == "" || password.text == ""){
            let alert = UIAlertController(title: "Missing Login Information", message: "A username or password was not entered. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            
            self.present(alert, animated: true)
        }
        
        else{
            //Grab the username and password strings from textboxes
            let parameters:[String: Any] = [
                "username": username.text!,
                "password": password.text!
            ]
            
            //Alamofire passes credentials to url to verify the user exists and will login if possible. Saves auth token to be used by keychain access.
            
            let url = "https://35.9.22.103/image_verifier/api/login/"

            _ = sessionManager.getManager().request(url, method:.post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent)).responseString { response in
                switch response.result {
                case .success:
                    print("success")
                    print(response.description)
                    if(response.description == "SUCCESS: Get outta here")
                    {
                        let loginAlert = UIAlertController(title: "User Not Found", message: "User not found in system. Contact System Administrator.", preferredStyle: .alert)
                        
                        loginAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        
                        
                        self.present(loginAlert, animated: true)
                        print("you cannot login")
                    }
                    else{
                        let jsonData = response.data
                        let decoder = JSONDecoder()
                        guard let decodedKey = try? decoder.decode(JSONResponse.self, from: jsonData!) else{
                            let errorAlert = UIAlertController(title: "ERROR", message: "Failed to login. Invalid credentials.", preferredStyle:.alert)
                            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil))
                            self.present(errorAlert,animated: true)
                            print("error with auth key")
                            return
                        }
                        
                        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
                        keychain["auth_token"] = decodedKey.auth_token
                        
                        
                        let storyboard = UIStoryboard(name: "CheckInCheckOut", bundle: Bundle.main)
                        guard let controller = storyboard.instantiateViewController(withIdentifier: "CheckInCheckOutStoryboard") as? CheckInCheckOutViewController else{
                            print("cannot find view controller")
                            return
                        }
                        
                        print(keychain["auth_token"] ?? "")
                        self.navigationController!.pushViewController(controller, animated: true)
                    }

                case .failure(let error):
                    print(response.description)
                    print(error)
                    let communicationErrorAlert = UIAlertController(title: "ERROR", message: "Server Communication Error. Connect to Appropriate Network.", preferredStyle:.alert)
                    communicationErrorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil))
                    self.present(communicationErrorAlert,animated: true)
                    print("error with communication")
                    return
                }
            }
        }
    }
    
}
