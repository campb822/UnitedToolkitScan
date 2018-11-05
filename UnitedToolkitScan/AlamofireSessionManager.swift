//
//  AlamofireSessionManager.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 11/1/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator


class loadSession {
    var manager : SessionManager?
    
    init(){
        print("Initializing manager from type ", type(of: manager))
        self.manager = self.getManager()
    }
    
    
    func getManager() -> SessionManager  {
        if self.manager != nil {
            print("Manager is not nil. Returning unwrapped manager")
            //print(type(of: (self.manager)))
            return self.manager!
        }
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "35.9.22.103": .disableEvaluation
        ]
        
        self.manager = Alamofire.SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return self.manager!
    }
}
