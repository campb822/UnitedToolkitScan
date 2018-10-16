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
//            let params = ["username":username.text, "password":password.text] as! Dictionary<String, String>
//
//            var request = URLRequest(url: URL(string: "http://35.9.22.103/image_verifier/accounts/login-ios/")!)
//            request.httpMethod = "POST"
//            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//            request.addValue("text/html", forHTTPHeaderField: "Content-Type")
//            request.addValue(username.text!, forHTTPHeaderField: "username")
//            request.addValue(password.text!, forHTTPHeaderField: "password")
//            request.allHTTPHeaderFields = params
//            print("request: ")
//            print(request, "\n")
//            print(username.text!)
//            print(request.httpBody as Any)
//            let session = URLSession.shared
//            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//                print(response!)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//                    print(json)
//
//                } catch {
//                    print("error with database communication")
//                }
//            })
//
//            task.resume()
            
//            let headers: HTTPHeaders = [
//                "Content-Type": "text/html",
////                "csrftoken": "g27nuaAgrYyoqKUP66MjkI4BGswAfWJ3eRvHPrugFBZsL7Ur3XIOOpOtUeWN39bu",
//                "username" : "childsev@msu.edu",
//                "password" : "djangopass"
//            ]
            

            let parameters:[String: Any] = [
                "username": "childsev@msu.edu",
               "password": "djangopass"
            ]
            print(username.text!)
            
            let url = "http://35.9.22.103/image_verifier/accounts/login-ios/"
            let request = Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default).responseString { response in
                //debugPrint(response)
                
                //print("Request: \(String(describing: response.request))")
                //print("Response: \(String(describing: response.response))")
                
                let statusCode = (response.response?.statusCode)!
                
                switch response.result {
                case .success:
                    //print(response)
                    print(statusCode)
                    
                case .failure(let error):
                    print("error")
                    //print("error: ")
                    print(error)
                    //print("response: ")
                    //print(response)
                    //failure(0,"Error")
                
                    
                }
            }
            //debugPrint(request)
        }
    }
}
