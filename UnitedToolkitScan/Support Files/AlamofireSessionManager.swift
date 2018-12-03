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
        
        self.manager = self.getManager()
    }
    
    
    func getManager() -> SessionManager  {
        if self.manager != nil {
            return self.manager!
        }
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "35.9.22.103": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        
        self.manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return self.manager!
    }
}
