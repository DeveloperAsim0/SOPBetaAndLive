//
//  UrlPaths.swift
//  SOP
//
//  Created by Shivam Saini on 06/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit

let baseURl: String = "http://sop.sparklemanufacturing.com/"
//http://sop.sparklemanufacturing.com/
enum UrlPaths {
    
    case login
    case uploadBarcode
    case scanHistory(Int)
    case radiatorList
    case radiatorVolume
    
    var urlString: String {
        return baseURl + self.stringBuilder()
    }
    
    var apiUrl: URL {
        return URL(string: self.urlString)!
    }
    
    private func stringBuilder() -> String {
        switch self {
        case .login:
            return "adminUsers/loginApp.json"
        case .uploadBarcode:
            return "jobItems/scanAppNew.json"
        case .scanHistory(let userID):
            return "jobItemHistories/userDashboardApp.json?user_id=\(userID)"
        case .radiatorVolume :
            return "radiatorVolumes/add.json"
        case .radiatorList:
            return "radiatorVolumes/getList.json"
        }
    }
}
