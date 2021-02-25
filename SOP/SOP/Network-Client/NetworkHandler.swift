//
//  NetworkHandler.swift
//  SOP
//
//  Created by Shivam Saini on 06/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

typealias JSON = [String:Any]
typealias RequestComplitionBlock = (JSON?,String?) -> Void

import Foundation

enum HttpMethod:String {
    case GET = "GET"
    case POST = "POST"
}

class NetwokHandler: NSObject {
    
    static func post(url: UrlPaths, object: JSON, completion: @escaping RequestComplitionBlock) {
        let request = requestGenerator(url: url,
                                       object: object,
                                       method: .POST)
        processRequest(request: request,
                       complition: completion)
        
    }
    
    static func get(url: UrlPaths, completion: @escaping RequestComplitionBlock) {
        let urlString  = url.urlString
        
        let requestUrl:URL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let request = URLRequest(url: requestUrl)
        processRequest(request: request,
                       complition: completion)
        
    }
    
    static func requestGenerator(url: UrlPaths, object: JSON, method: HttpMethod) -> URLRequest {
        var request = URLRequest(url: url.apiUrl)
        request.httpMethod = method.rawValue
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: object,
                                                          options: .prettyPrinted)
        }catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    
    static func processRequest(request:URLRequest,complition: @escaping RequestComplitionBlock) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    // networking error
                    print("error = \(String(describing: error!))")
                    complition(nil, error?.localizedDescription)
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("Status Code should be 200, but it is \(httpStatus.statusCode)")
                    
                    let jsonResp = try? JSONSerialization.jsonObject(with: data, options: []) as! JSON
                    complition(jsonResp!,"Status Code should be 200, but it is \(httpStatus.statusCode)")
                    return
                }
                if let jsonResp = ((try? JSONSerialization.jsonObject(with: data, options: []) as? JSON) as JSON??) {
                    return complition(jsonResp, nil)
                }else {
                    return complition(nil, error?.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
}
