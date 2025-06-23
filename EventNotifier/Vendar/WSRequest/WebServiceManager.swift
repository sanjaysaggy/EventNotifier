//
//  WebServiceManager.swift
//  DoggiePaddle
//
//  Created by Sanjay on 07/03/19.
//  Copyright © 2018 Sanjay. All rights reserved.
//

import UIKit
import Alamofire



class WebServiceManager: NSObject {
    
    public static let sharedInstance: WebServiceManager = {
        
        return WebServiceManager()
    }()
    
    func WebServiceRequest(parametersDict:[String:Any]!,APIName:String!,Method:HTTPMethod, completionHandler:@escaping (_ status:Bool, _ message:String , _ userData : [String:Any])-> Void) {
        
        let urlString = BaseURL + APIName
        print("urlString : ",urlString)
        Alamofire.request(urlString, method: Method, parameters: parametersDict!, encoding: URLEncoding.default)
            .responseJSON { (JSON) in
                
                guard JSON.result.isSuccess else {
                    completionHandler(false, SometingWentWrongMessage, [:])
                    return
                }
                print("Parameters : \(String(describing: parametersDict!))")
                if let jsonObj = JSON.result.value as? [String:Any] {
//                    completionHandler(true, "",jsonObj)
                    print("Response : \(jsonObj)")
                    let message = jsonObj["message"] as! String
                    if jsonObj["message_code"] as? Int  == 1 {
                        completionHandler(true, message,jsonObj)
                    } else {
                        completionHandler(false, message,jsonObj)
                    }
                } else {
                    completionHandler(false, SometingWentWrongMessage,[:])
                }
        }
    }
}


/*
class WebServiceManager: NSObject {
    
    public static let sharedInstance: WebServiceManager = {
        
        return WebServiceManager()
    }()
    
    struct NetworkDemo{
        
        enum Router: URLRequestConvertible {
            
            static let baseURLString = BaseURL
            
            case WebServiceRequest(parametersDict:[String:Any],APIName:String,Method:HTTPMethod)
            
            func asURLRequest() throws -> URLRequest {
                
                let (path, parameters, method): (String, [String:Any]?, HTTPMethod) = {
                    switch self {
                    case .WebServiceRequest( let parameterDict,let APIName, let Method) :
                        let params = parameterDict
                        return(APIName, params, Method)
                    }
                }()
                
                let url = URL(string: Router.baseURLString)
                var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")//application/x-www-form-urlencoded
                urlRequest.httpMethod = method.rawValue
                urlRequest.timeoutInterval = 120
                let encoding = URLEncoding.default
                
                //add common params
                
                print("Request_URL : \(urlRequest)")
                print("Request_Parameters : \(String(describing: parameters!))")
                
                return try encoding.encode(urlRequest, with: parameters)
            }
        }
    }
    
    
    func WebServiceRequest(parametersDict:[String:Any]!,APIName:String!,Method:HTTPMethod, completionHandler:@escaping (_ status:Bool, _ message:String , _ userData : [String:Any])-> Void) {
        
        request(NetworkDemo.Router.WebServiceRequest(parametersDict: parametersDict, APIName: APIName, Method: Method))
            
            .responseJSON { (JSON) in
                
                //                 print("response =\(JSON)")
                
                guard JSON.result.isSuccess else{
                    completionHandler(false, "Api Error", [:])
                    return
                }
                
                
                
                if let jsonObj = JSON.result.value as? [String:Any]{
                    completionHandler(true, "",jsonObj)
                    //                    print("Response : \(jsonObj)")
                    //                    let message = jsonObj["message"] as! String
                    //                    if jsonObj["message_code"] as? Int  == 1
                    //                    {
                    //                        completionHandler(true, message,jsonObj)
                    //                    }
                    //                    else
                    //                    {
                    //                        completionHandler(false, message,jsonObj)
                    //                    }
                }
                else {
                    completionHandler(false, "Api Error",[:])
                }
        }
    }
}
*/
