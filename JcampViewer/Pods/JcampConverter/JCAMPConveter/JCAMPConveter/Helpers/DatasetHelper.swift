//
//  DatasetHelper.swift
//  JCAMPConveter
//
//  Created by Lan Le on 03.06.23.
//

import Foundation

class DatasetHelper {
    
    func isAFFN(_ value: String) -> Bool {
        if value == "" {
            return false
        }
        
        let regexPattern = #"^[+-]?(\d+(\.\d*)?|\.\d+)([Ee][+-]?\d+)?$"#

        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let range = NSRange(location: 0, length: value.utf16.count)

            if let _ = regex.firstMatch(in: value, options: [], range: range) {
                return true
            }
        } catch {
//            print("Error creating regex: \(error)")
        }
        return false
    }
    
    func convertDUP(_ value: String) -> String {
        var convertedStr = ""
        
        for (idx, char) in value.enumerated() {
            let charString = String(char)
            if let dupValue = DUP[charString] {
                let prevChar = value[idx-1]
                let newChars = Array(repeating: prevChar, count: dupValue-1)
                convertedStr += newChars.joined()
            }
            else {
                convertedStr += charString
            }
        }
        
        return convertedStr
    }
    
    func convertSQZ(_ value: String) -> String {
        var convertedStr = ""
        
        for char in value {
            let charString = String(char)
            if let sqzValue = SQZ[charString] {
                convertedStr += String(sqzValue)
            }
            else {
                convertedStr += charString
            }
        }
        
        return convertedStr
    }
    
    func convertDIF(_ value: String) -> String {
        var convertedStr = ""
        var previousNumberStr = ""
        
        for char in value {
            let charString = String(char)
            if let difValue = DIF[charString] {
                let previousValue = Double(previousNumberStr) ?? 0.0
                let numberValue = previousValue + Double(difValue)
                convertedStr = String(numberValue)
            }
            else {
                previousNumberStr += charString
            }
        }
        
        return convertedStr
    }
    
    func splitString(_ value: String) -> [String] {
        let asdfRegexPattern = "[a-sA-Z@%]"

        do {
            let regex = try NSRegularExpression(pattern: asdfRegexPattern)
            let range = NSRange(location: 0, length: value.utf16.count)

            if let _ = regex.firstMatch(in: value, options: [], range: range) {
                return [value]
            }
        } catch {
//            print("Error creating regex: \(error)")
        }
        
        let regexPattern = "[+-]?\\d+(\\.\\d+)?"

        let matches = value.matches(regexPattern)
//        print(matches)

        let numbersArray = matches.map { match in
            let startIndex = value.index(value.startIndex, offsetBy: match.range.lowerBound)
            let endIndex = value.index(value.startIndex, offsetBy: match.range.upperBound)
            return String(value[startIndex..<endIndex])
        }
        return numbersArray.count > 1 ? numbersArray : [value]
    }
}
