//
//  UserLoginController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 9/30/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import Foundation
import UIKit

class UserLogin: UIViewController, UITextFieldDelegate{
    

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBAction func login(_ sender: UIButton) {
        loginButtonPressed()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    
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
    
    func loginButtonPressed(){
        if(username.text == "" || password.text == ""){
            let alert = UIAlertController(title: "Missing Login Information", message: "A username or password was not entered. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            
            self.present(alert, animated: true)
        }
        
        else{
            let params = ["username":username.text, "password":password.text] as! Dictionary<String, String>
            
            var request = URLRequest(url: URL(string: "http://35.9.22.103/accounts/login/")!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                print(response!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    print(json)
                } catch {
                    print("error with database communication")
                }
            })
            
            task.resume()
        }
    }
}
