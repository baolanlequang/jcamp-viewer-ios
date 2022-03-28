//
//  Utilities.swift
//  JcampConverter
//
//  Created by Lan Le on 02.02.22.
//

import Foundation

extension String {
    var isNumeric: Bool! {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isDouble: Bool {
        guard self.count > 0 else { return false }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let _ = numberFormatter.number(from: self) else {
            return false
        }
        return true
    }
    
    var arrayNumbers: [Int] {
        guard self.count > 0 else { return [] }
        var result: [Int] = []
        let pattern = "[^[0-9]+]"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let tmpStr = regex.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: " ").trimmingCharacters(in: .whitespaces)
            let tmpArr = tmpStr.split(separator: " ")
            for i in tmpArr {
                if let intVal = Int(i) {
                    result.append(intVal)
                }
            }
        } catch {
            print("Cant convert")
        }
        return result;
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    
}

extension Character {
    var isNumeric: Bool! {
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return nums.contains(self)
    }
}
