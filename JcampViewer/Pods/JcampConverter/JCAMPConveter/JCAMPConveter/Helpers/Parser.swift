//
//  Parser.swift
//  JCAMPConveter
//
//  Created by Lan Le on 03.06.23.
//

import Foundation

class Parser {
    
    private var datasetHelper: DatasetHelper!
    private enum ENCODED_TYPE {
        case NONE, SQZ, DIF, DUP
    }
    
    init() {
        datasetHelper = DatasetHelper()
    }
    
    private func getNumber(_ value: String, _ isDIF: Bool = false, _ storedData: [Double] = []) -> Double? {
        if let doubleNumber = Double(value) {
            return doubleNumber
        }
        
        var convertedStr = ""
        if (!isDIF) {
            convertedStr = datasetHelper.convertSQZ(value)
        }
        else {
            convertedStr = datasetHelper.convertDIF(value)
        }
        
        if let doubleNumber = Double(convertedStr) {
            return doubleNumber
        }
        
        return nil
    }
    
    private func getArrayNumber(_ value: String, _ encodedType: ENCODED_TYPE, _ cachingData: String, _ cachingEncodedType: ENCODED_TYPE, _ data: [Double]) -> [Double] {
        var result: [Double] = []
        switch (encodedType) {
        case .SQZ:
            let convertedStr = datasetHelper.convertSQZ(value)
            if let doubleNumber = Double(convertedStr) {
                result.append(doubleNumber)
            }
        case .DIF:
            if let prevValue = data.last, let difValue = Double(value) {
                let encodedValue = prevValue + difValue
                result.append(encodedValue)
            }
        case .DUP:
            if let prevValue = Double(cachingData), let dupValue = Int(value) {
                for _ in 0..<dupValue-1 {
                    if (cachingEncodedType == .DIF) {
                        if let lastData = data.last {
                            result.append(lastData + prevValue)
                        }
                    }
                    else {
                        result.append(prevValue)
                    }
                }
            }
        default:
            if let doubleNumber = Double(value) {
                result.append(doubleNumber)
            }
        }
        return result
    }
    
    func parse(_ value: String) -> (data: [Double], isDIF: Bool) {
        if let doubleValue = Double(value) {
            return (data: [doubleValue], isDIF: false)
        }
        
        var result: [Double] = []
        
        let arrSplitted = datasetHelper.splitString(value)
        if (arrSplitted.count > 1) {
            for item in arrSplitted {
                if let number = getNumber(item) {
                    result.append(number)
                }
            }
            return (data: result, isDIF: false)
        }
        
        let dataCompressedStr = arrSplitted[0]
        
        var numberStr = ""
        var encodedType = ENCODED_TYPE.NONE
        
        var isDIF = false
        var cachingData = ""
        var cachingEncodedType = ENCODED_TYPE.NONE
        
        for char in dataCompressedStr {
            let charString = String(char)
            var decodedChar = ""
            
            if (char.isNumber || char == ".") {
                numberStr.append(char)
                continue
            }
            
            var currEncodedType = ENCODED_TYPE.SQZ
            
            if let sqzVal = SQZ[charString] {
                decodedChar = String(sqzVal)
                currEncodedType = ENCODED_TYPE.SQZ
                isDIF = false
            }
            else if let difVal = DIF[charString] {
                decodedChar = String(difVal)
                currEncodedType = ENCODED_TYPE.DIF
                isDIF = true
            }
            else if let dupVal = DUP[charString] {
                decodedChar = String(dupVal)
                currEncodedType = ENCODED_TYPE.DUP
            }
            
            let arrData = self.getArrayNumber(numberStr, encodedType, cachingData, cachingEncodedType, result)
            cachingEncodedType = encodedType
            result.append(contentsOf: arrData)
            cachingData = numberStr
            
            numberStr = decodedChar
            encodedType = currEncodedType
        }
        
        // Process the last char
        let arrData = self.getArrayNumber(numberStr, encodedType, cachingData, cachingEncodedType, result)
        cachingEncodedType = encodedType
        result.append(contentsOf: arrData)
        cachingData = numberStr
        
        
        return (data: result, isDIF: isDIF)
    }
}
