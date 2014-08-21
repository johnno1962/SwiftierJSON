//  SwiftyJSON.swift
//
//  Copyright (c) 2014年 Ruoyu Fu, Denis Lebedev, John Holdsworth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

struct JSONValue {

    var obj: AnyObject!

    var string: String? {
        if let value = obj as? NSString {
            return value
        } else if let value = obj as? NSNumber {
            return value.stringValue
        } else {
            return nil
        }
    }
  
    var url: NSURL? {
        if let value = obj as? NSString {
            return NSURL(string: value)
        } else {
            return nil
        }
    }

    var number: NSNumber? {
        if let value = obj as? NSNumber {
            return value
        } else {
            return nil
        }
    }
    
    var double: Double? {
        if let value = obj as? NSNumber {
            return value.doubleValue
        } else if let value = obj as? NSString {
            return value.doubleValue
        } else {
            return nil
        }
    }
    
    var integer: Int? {
        if let value = obj as? NSNumber {
            return value.integerValue
        } else if let value = obj as? NSString {
            return value.integerValue
        } else {
            return nil
        }
    }
    
    var bool: Bool? {
        if let value = obj as? NSNumber {
            return value.boolValue
        } else if let value = obj as? NSString {
            return value.boolValue
        } else {
            return nil
        }
    }
    
    var array: Array<JSONValue>? {
        if let value = obj as? NSArray {
            return map( value ) { JSONValue($0) }
        } else {
            return nil
        }
    }
    
    var object: Dictionary<String, JSONValue>? {
        if let object = obj as? NSDictionary {
            var out = Dictionary<String, JSONValue>()
            for ( key, value ) in object {
                out[key as String] = JSONValue(value)
            }
            return out
        } else {
            return nil
        }
    }

    var first: JSONValue? {
        if let jsonArray = obj as? NSArray {
            if jsonArray.count > 0 {
                return JSONValue( jsonArray[0] )
            }
        }
        if let jsonDictionary = obj as? NSDictionary {
            for (_, value) in jsonDictionary {
                return JSONValue( value )
            }
        }
        return nil
    }
    
    var last: JSONValue? {
        if let jsonArray = obj as? NSArray {
            if jsonArray.count > 0 {
                return JSONValue( jsonArray[jsonArray.count-1] )
            }
        }
        if let jsonDictionary = obj as? NSDictionary {
            var out: AnyObject!
            for (_, value) in jsonDictionary {
                out = value
            }
            if out {
                return JSONValue( out )
            }
        }
        return nil
    }

    init (_ data: NSData!, options: NSJSONReadingOptions = nil ) {
        if let value = data {
            var error:NSError? = nil
            obj = NSJSONSerialization.JSONObjectWithData(data, options: options, error: &error)
            if !obj {
                obj = NSError(domain: "JSONErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey:"JSON Parser Error: Invalid Raw JSON Data"])
            }
        } else {
            obj = NSError(domain: "JSONErrorDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey:"JSON Init Error: Invalid Value Passed In init()"])
        }
    }
    
    init (_ rawObject: AnyObject) {
        obj = rawObject
        if ( !obj ) {
            obj = NSError(domain: "JSONErrorDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey:"JSON Init Error: Invalid Value Passed In init()"])
        }
    }

    subscript(index: Int) -> JSONValue {
        get {
            if let jsonArray = obj as? NSArray {
                return JSONValue(jsonArray[index])
            }
            if let error = obj as? NSError {
                if let userInfo = error.userInfo {
                    if let breadcrumb = userInfo["JSONErrorBreadCrumbKey"] as? NSString{
                        let newBreadCrumb = (breadcrumb as String) + "/\(index)"
                        let newUserInfo = [NSLocalizedDescriptionKey: "JSON Keypath Error: Incorrect Keypath \"\(newBreadCrumb)\"",
                                           "JSONErrorBreadCrumbKey": newBreadCrumb]
                        return JSONValue(NSError(domain: "JSONErrorDomain", code: 1002, userInfo: newUserInfo))
                    }
                }
                return self
            } else {
                let breadcrumb = "\(index)"
                let newUserInfo = [NSLocalizedDescriptionKey: "JSON Keypath Error: Incorrect Keypath \"\(breadcrumb)\"",
                                    "JSONErrorBreadCrumbKey": breadcrumb]
                return JSONValue(NSError(domain: "JSONErrorDomain", code: 1002, userInfo: newUserInfo))
            }
        }
        set {
            if let jsonArray = obj as? NSMutableArray {
                if ( index < jsonArray.count ) {
                    jsonArray[index] = newValue.obj
                }
                else if ( index == jsonArray.count ) {
                    jsonArray.addObject( newValue.obj )
                }
            }
        }
    }
    
    subscript(key: String) -> JSONValue {
        get {
            if let jsonDictionary = obj as? NSDictionary {
                if let value: AnyObject = jsonDictionary[key] {
                    return JSONValue(value)
                } else {
                    let breadcrumb = "\(key)"
                    let newUserInfo = [NSLocalizedDescriptionKey: "JSON Keypath Error: Incorrect Keypath \"\(breadcrumb)\"",
                                        "JSONErrorBreadCrumbKey": breadcrumb]
                    return JSONValue(NSError(domain: "JSONErrorDomain", code: 1002, userInfo: newUserInfo))
                }
            }
            else if let error = obj as? NSError {
                if let userInfo = error.userInfo {
                    if let breadcrumb = userInfo["JSONErrorBreadCrumbKey"] as? NSString{
                        let newBreadCrumb = (breadcrumb as String) + "/\(key)"
                        let newUserInfo = [NSLocalizedDescriptionKey: "JSON Keypath Error: Incorrect Keypath \"\(newBreadCrumb)\"",
                            "JSONErrorBreadCrumbKey": newBreadCrumb]
                        return JSONValue(NSError(domain: "JSONErrorDomain", code: 1002, userInfo: newUserInfo))
                    }
                }
                return self
            } else {
                let breadcrumb = "/\(key)"
                let newUserInfo = [NSLocalizedDescriptionKey: "JSON Keypath Error: Incorrect Keypath \"\(breadcrumb)\"",
                    "JSONErrorBreadCrumbKey": breadcrumb]
                return JSONValue(NSError(domain: "JSONErrorDomain", code: 1002, userInfo: newUserInfo))
            }
        }
        set {
            if let jsonDictionary = obj as? NSMutableDictionary {
                jsonDictionary[key] = newValue.obj
            }
        }
    }
}

extension JSONValue: Printable {
    var description: String {
        if let error = obj as? NSError {
            return error.localizedDescription
        }
        else {
            return _printableString("")
        }
    }
    
    var rawJSONString: String {
        if let value = obj as? NSNumber {
            if String.fromCString(value.objCType) == "c" {
                return "\(value.boolValue)"
            } else {
                return "\(value)"
            }
        }
        else if let value = obj as? NSString {
            let jsonAbleString = value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.CaseInsensitiveSearch, range:NSMakeRange(0, value.length))
            return "\"\(jsonAbleString)\""
        }
        else if let value = obj as? NSNull {
            return "null"
        }
        else if let array = obj as? NSArray {
            var arrayString = ""
            for (index, value) in enumerate(array) {
                if index != array.count - 1 {
                    arrayString += "\(JSONValue(value).rawJSONString),"
                }else{
                    arrayString += "\(JSONValue(value).rawJSONString)"
                }
            }
            return "[\(arrayString)]"
        }
        else if let object = obj as? NSDictionary {
            var objectString = ""
            var (index, count) = (0, object.count)
            for (key, value) in object {
                if index != count - 1 {
                    objectString += "\"\(key)\":\(JSONValue(value).rawJSONString),"
                } else {
                    objectString += "\"\(key)\":\(JSONValue(value).rawJSONString)"
                }
                index += 1
            }
            return "{\(objectString)}"
        }
        else {//if let error = obj as? NSError {
            return "INVALID_JSON_VALUE"
        }
    }
    
    func _printableString(indent: String) -> String {
        if let object = obj as? NSDictionary {
            var objectString = "{\n"
            var index = 0
            for (key, value) in object {
                let valueString = JSONValue(value)._printableString(indent + "  ")
                if index != object.count - 1 {
                    objectString += "\(indent)  \"\(key)\":\(valueString),\n"
                } else {
                    objectString += "\(indent)  \"\(key)\":\(valueString)\n"
                }
                index += 1
            }
            objectString += "\(indent)}"
            return objectString
        }
        else if let array = obj as? NSArray {
            var arrayString = "[\n"
            for (index, value) in enumerate(array) {
                let valueString = JSONValue(value)._printableString(indent + "  ")
                if index != array.count - 1 {
                    arrayString += "\(indent)  \(valueString),\n"
                }else{
                    arrayString += "\(indent)  \(valueString)\n"
                }
            }
            arrayString += "\(indent)]"
            return arrayString
        } else {
            return rawJSONString
        }
    }
}

extension JSONValue: BooleanType {
    var boolValue: Bool {
        if let error = obj as? NSError {
            return false
        }
        else if let error = obj as? NSNull {
            return false
        }
        else if !obj {
            return false
        }
        else {
            return true
        }
    }
}

extension JSONValue : Equatable {
    
}

func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
    return lhs.obj.isEqual(rhs.obj)
}
