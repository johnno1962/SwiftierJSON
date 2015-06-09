//
//  TestJSONValue.swift
//  Test
//
//  Created by Ruoyu Fu on 14-6-21.
//
//

import XCTest

class SwiftyJSONTests: XCTestCase {
    
    var validJSONData:NSData!
    
    override func setUp() {
        validJSONData = NSData(contentsOfFile : NSBundle(forClass:SwiftyJSONTests.self).pathForResource("Valid", ofType: "JSON")!)
        super.setUp()
    }
    
    func testJSONValueDoesInitWithDictionaryLiteral() {
        let json = JSONValue(["Key": ["SubKey":"Value"]])
        XCTAssertEqual(json["Key"]["SubKey"].string!, "Value", "Wrong unpacked value")
    }
    
    func testJSONValueDoesInitWithValidData() {
        let json = JSONValue(validJSONData)
/*
        switch json{
        case .JInvalid:
            XCTFail()
        default:
            "Pass"
        }
*/
        if !json {
            XCTFail()
        }

        var json2 = JSONValue(validJSONData, options:.MutableContainers )

        if json != json2 {
            XCTFail()
        }

        json2["title"] = JSONValue("changed")

        if json == json2 {
            XCTFail()
        }
    }

    func testJSONValueDoesProduceValidValueWithCorrectKeyPath() {
        let json = JSONValue(validJSONData)
        NSLog( "%@", json.obj as! NSObject )

        let stringValue = json["title"].string
        let urlValue = json["url"].url
        let numberValue = json["id"].number
        let boolValue = json["user"]["site_admin"].bool
        let nullValue = json["closed_by"]
        let arrayValue = json["labels"].array
        let objectValue = json["user"].object
      
        XCTAssert(stringValue == "How do I verify SwiftyJSON workS?")
        XCTAssert(urlValue == NSURL(string: "https://api.github.com/repos/lingoer/SwiftyJSON/issues/2"))
        XCTAssert(numberValue == 36170434)
        XCTAssert(boolValue == false)
//        XCTAssert(nullValue == JSONValue.JNull)
        if nullValue {
            XCTFail()
        }
        XCTAssert(arrayValue != nil)
        XCTAssert(objectValue != nil)

    }
    
    func testJSONString() {
        let JSON = JSONValue("string")
        XCTAssertEqual(JSON.string!, "string", "Wrong unpacked value")
    }
  
    func testJSONURL() {
        let JSON = JSONValue("http://example.com/")
        XCTAssertEqual(JSON.url!, NSURL(string: "http://example.com/")!, "Wrong unpacked value")
    }
  
    func testJSONNumber() {
        let JSON = JSONValue(5)
        XCTAssertEqual(JSON.number!, 5, "Wrong unpacked value")
    }
    
    func testJSONBool() {
        let falseJSON = JSONValue(NSNumber(bool: false))
        XCTAssertEqual(falseJSON.bool!, false, "Wrong unpacked value")
        
        let trueJSON = JSONValue(NSNumber(bool: true))
        XCTAssertEqual(trueJSON.bool!, true, "Wrong unpacked value")
    }
    
    func testJSONArray() {
        let JSON = JSONValue([1, 2])
        let array = [JSONValue(1), JSONValue(2)]
        let result = JSON.array!
        
        XCTAssert(result == array, "Wrong unpacked value")
        XCTAssertEqual(JSON[0].number!, 1, "Wrong unpacked value")
    }
    
    func testJSONObject() {
        let JSON = JSONValue(["name": "Foo", "count": 32])
        let object = ["name": JSONValue("Foo"), "count": JSONValue(32)]
        let result = JSON.object!
        
        XCTAssert(result == object, "Wrong unpacked value")
        XCTAssertEqual(JSON["name"].string!, "Foo", "Wrong unpacked value")
    }
    
    func testPrettyPrintIntegerNumber() {
        let JSON = JSONValue(5.0)
        XCTAssertEqual("5", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintFloatNumber() {
        let JSON = JSONValue(5.1)
        XCTAssertEqual("5.1", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintBool() {
        let trueJSON = JSONValue(true)
        let falseJSON = JSONValue(false)

        XCTAssertEqual("true", trueJSON.description, "Wrong pretty value")
        XCTAssertEqual("false", falseJSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintObject() {
        let JSON = JSONValue(["key": "value"])
        XCTAssertEqual("{\n  \"key\":\"value\"\n}", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintArray() {
        let JSON = JSONValue(["0", "1"])
        XCTAssertEqual("[\n  \"0\",\n  \"1\"\n]", JSON.description, "Wrong pretty value")

    }
    
    func testPrettyPrintNull() {
        let JSON = JSONValue(NSNull())
        XCTAssertEqual("null", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintString() {
        let JSON = JSONValue("Hi")
        XCTAssertEqual("\"Hi\"", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintURL() {
        let JSON = JSONValue("http://example.com/")
        XCTAssertEqual("\"http://example.com/\"", JSON.description, "Wrong pretty value")
    }

    func testWritable() {
        var JSON = JSONValue(NSMutableDictionary())
        JSON["milestone"]["creator"]["login"] = JSONValue( "lingoer")
        let msg = JSON.rawJSONString
        XCTAssertEqual(msg,"{\"milestone\":{\"creator\":{\"login\":\"lingoer\"}}}", "wrong build")
    }

    func testBuilding() {
        var JSON = JSONValue(NSMutableDictionary())

        JSON["url"] = JSONValue("https://api.github.com/repos/lingoer/SwiftyJSON/issues/2")
        JSON["id"] = JSONValue(36170434)
        JSON["number"] = JSONValue(2)
        JSON["title"] = JSONValue("How do I verify SwiftyJSON workS?")
        JSON["user"]["login"] = JSONValue("garnett")
        JSON["user"]["id"] = JSONValue(829783)
        JSON["user"]["avatar_url"] = JSONValue("https://avatars.githubusercontent.com/u/829783?" )
        JSON["user"]["type"] = JSONValue("User")
        JSON["user"]["site_admin"] = JSONValue(false)
        JSON["labels"][0] = JSONValue(NSMutableArray())
        JSON["labels"][1] = JSONValue(NSMutableArray())
        JSON["state"] = JSONValue("open")
        JSON["assignee"] = JSONValue(NSNull())
        JSON["milestone"]["url"] = JSONValue( "https://api.github.com/repos/lingoer/SwiftyJSON/milestones/1" )
        JSON["milestone"]["labels_url"] = JSONValue( "https://api.github.com/repos/lingoer/SwiftyJSON/milestones/1/labels" )
        JSON["milestone"]["id"] = JSONValue(696908)
        JSON["milestone"]["number"] = JSONValue(1)
        JSON["milestone"]["title"] = JSONValue("release 0.1")
        JSON["milestone"]["description"] = JSONValue( "Add a Demo!\r\nBranch out a develop branch, and may be, Git Flow" )
        JSON["milestone"]["creator"]["login"] = JSONValue( "lingoer")
        JSON["milestone"]["creator"]["id"] = JSONValue(3095758)
        JSON["milestone"]["creator"]["avatar_url"] = JSONValue( "https://avatars.githubusercontent.com/u/3095758?" )
        JSON["milestone"]["creator"]["gravatar_id"] = JSONValue( "8ccacafa7f3e7f6a07cdc8d9f1f30471" )
        JSON["milestone"]["creator"]["type"] = JSONValue( "User" )
        JSON["milestone"]["creator"]["site_admin"] = JSONValue(false)
        JSON["milestone"]["open_issues"] = JSONValue(1)
        JSON["milestone"]["closed_issues"] = JSONValue(0)
        JSON["milestone"]["state"] = JSONValue("open")
        JSON["milestone"]["created_at"] = JSONValue("2014-06-20T15:51:59Z")
        JSON["milestone"]["due_on"] = JSONValue(NSNull())
        JSON["comments"] = JSONValue(2)
        JSON["updated_at"] = JSONValue("2014-06-20T16:21:05Z")
        JSON["body"] = JSONValue("I've cloned the source, run Example project and apparently it's empty - no unit tests, no demo :zzz: ££")
        JSON["closed_by"] = JSONValue(NSNull())

        XCTAssertEqual(JSONValue(validJSONData), JSON, "Wrong built value")
    }
}
