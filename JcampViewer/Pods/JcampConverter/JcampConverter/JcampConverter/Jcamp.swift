//
//  Jcamp.swift
//  JcampConverter
//
//  Created by Lan Le on 02.02.22.
//

import Foundation

public class Jcamp {
    
    private let arrTitleData = ["xydata", "peaktable", "peak table", "xypoints", "data table"]
    private let arrTypeDataXPlusY = ["(X++(Y..Y)", "(X++(R..R)", "(X++(I..I)"]
    private let arrTypeDataXY = ["(XY..XY)"]
    
    public var children: [Jcamp]?
    
    public struct Spectra {
        public var xValues: [Double]
        public var yValues: [Double]
        public var isReal = true
    }
    
    public var spectra: [Spectra] = []
    public var dicData: [String: Any] = [:]
    
    public var hasChild: Bool {
        guard let childr = self.children else {
            return false
        }
        return childr.count > 0
    }
    
    public init() {}
    
    public init(originData: [Any]) {
        var arrStartOfX = [Double]()
        var arrNumberOfX = [Int]()
        
        var isReadingData = false
        var dataType = ""
        var userDefineValue = ""
        var isReadingUserDefine = false
        
        var arrX = [Double]()
        var arrY = [Double]()
        var prevHasLastDIF = false
        var isRealData = true
        
        for value in originData {
            if let childData = value as? Array<Any> {
                let childJcamp = Jcamp(originData: childData)
                if (self.children == nil) {
                    self.children = []
                }
                self.children?.append(childJcamp)
            }
            else if let childString = value as? String {
                if !(childString.hasPrefix("$$") || childString.hasPrefix("##")) {
                    if (isReadingData) {
                        var dataString = childString
                        dataString = dataString.replacingOccurrences(of: "$$ checkpoint", with: "")
                        
                        var dataClass = ""
                        if let dClass = self.dicData["##DATA CLASS"] as? String {
                            dataClass = dClass
                            dataClass = dataClass.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        let filterTypeXPlusY = self.arrTypeDataXPlusY.filter { title in
                            return dataType.contains(title)
                        }
                        if (filterTypeXPlusY.count > 0) {
                            // reading (X++(Y..Y) data
                            var firstX = 0.0
                            var lastX = 0.0
                            var npoints = 0.0
                            var xFactor = 1.0
                            var yFactor = 1.0
                            
                            if (dataClass == "NTUPLES") {
                                //check ntuples data
                                var arrNPoints = [String]()
                                var arrFirst = [String]()
                                var arrLast = [String]()
                                var arrFactor = [String]()
                                guard var varDim = self.dicData["##VAR_DIM"] as? String else {
                                    return
                                }
                                varDim = varDim.replacingOccurrences(of: " ", with: "")
                                varDim = varDim.trimmingCharacters(in: .whitespacesAndNewlines)
                                arrNPoints = varDim.components(separatedBy: ",")
                                
                                if var first = self.dicData["##FIRST"] as? String {
                                    first = first.replacingOccurrences(of: " ", with: "")
                                    first = first.trimmingCharacters(in: .whitespacesAndNewlines)
                                    arrFirst = first.components(separatedBy: ",")
                                }
                                
                                if var last = self.dicData["##LAST"] as? String {
                                    last = last.replacingOccurrences(of: " ", with: "")
                                    last = last.trimmingCharacters(in: .whitespacesAndNewlines)
                                    arrLast = last.components(separatedBy: ",")
                                }
                                
                                if var factor = self.dicData["##FACTOR"] as? String {
                                    factor = factor.replacingOccurrences(of: " ", with: "")
                                    factor = factor.trimmingCharacters(in: .whitespacesAndNewlines)
                                    arrFactor = factor.components(separatedBy: ",")
                                }
                                
                                if (arrNPoints.count > 0) {
                                    if let point = arrNPoints[0] as? NSString {
                                        npoints = point.doubleValue
                                    }
                                }
                                
                                if (arrFirst.count > 0) {
                                    if let first = arrFirst[0] as? NSString {
                                        firstX = first.doubleValue
                                    }
                                }
                                
                                if (arrLast.count > 0) {
                                    if let last = arrLast[0] as? NSString {
                                        lastX = last.doubleValue
                                    }
                                }
                                
                                if (arrFactor.count > 0) {
                                    if let factor = arrFactor[0] as? NSString {
                                        xFactor = factor.doubleValue
                                    }
                                }
                                
                                if (arrFactor.count > 1) {
                                    if (dataType.contains("(X++(R..R))")) {
                                        if let factor = arrFactor[1] as? NSString {
                                            yFactor = factor.doubleValue
                                        }
                                    }
                                    else {
                                        if let factor = arrFactor[2] as? NSString {
                                            yFactor = factor.doubleValue
                                        }
                                    }
                                }
                                
                                
                            }
                            else {
                                if let first = self.dicData["##FIRSTX"] as? NSString {
                                    firstX = first.doubleValue
                                }
                                if let last = self.dicData["##LASTX"] as? NSString {
                                    lastX = last.doubleValue
                                }
                                if let point = self.dicData["##NPOINTS"] as? NSString {
                                    npoints = point.doubleValue
                                }
                                if let factor = self.dicData["##XFACTOR"] as? NSString {
                                    xFactor = factor.doubleValue
                                }
                                if let factor = self.dicData["##YFACTOR"] as? NSString {
                                    yFactor = factor.doubleValue
                                }
                            }
                            
                            
                            let parsedData = self.parser(strVal: dataString)
                            let count = parsedData.data.count
                            if (count > 0) {
                                let delta = (lastX-firstX)/npoints
                                var x = parsedData.data[0]
                                x *= xFactor
                                arrX.append(x)
                                
                                arrStartOfX.append(x)
                                arrNumberOfX.append(count-1)
                                
                                var parsedValues = parsedData.data
                                if (arrStartOfX.count > 1 && parsedData.lastDIF) {
                                    parsedValues.removeLast()
                                }
                                else if (prevHasLastDIF && parsedValues.count == 2 && !parsedData.lastDIF) {
                                    //do not add y in last line check point and use the last x
                                    parsedValues.removeLast()
                                    arrX.remove(at: arrX.count-2)
                                }
                                //check previous is DIF form
                                prevHasLastDIF = parsedData.lastDIF
                                
                                for i in 1..<parsedValues.count {
                                    var y = parsedValues[i]
                                    y *= yFactor
                                    arrY.append(y)
                                    if (i > 1) {
                                        x += delta
                                        arrX.append(x)
                                    }
                                }
                            }
                        }
                        else {
                            //other types
                            let filterTypeXY = self.arrTypeDataXY.filter { title in
                                return dataType.contains(title)
                            }
                            if (filterTypeXY.count > 0) {
                                // reading (XY..XY) data
                                dataString = dataString.replacingOccurrences(of: ",", with: "")
                                dataString = dataString.replacingOccurrences(of: ";", with: "")
                                let parsedData = dataString.components(separatedBy: " ")
                                for (idx, val) in parsedData.enumerated() {
                                    if let valStr = val as? NSString {
                                        if (idx%2 == 0) {
                                            arrX.append(valStr.doubleValue)
                                        }
                                        else {
                                            arrY.append(valStr.doubleValue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if (isReadingUserDefine) {
                        //reading user defined values
                        var userDefinedArrData = self.dicData[userDefineValue] as? [String] ?? [String]()
                        
                        userDefinedArrData.append(childString)
                        self.dicData[userDefineValue] = userDefinedArrData
                    }
                }
                else {
                    let arrFilter = self.arrTitleData.filter { title in
                        return childString.lowercased().contains(title)
                    }
                    isReadingData = arrFilter.count > 0
                    
                    //check data type if start reading
                    dataType = ""
                    if (isReadingData) {
                        dataType = childString
                    }
                    else if (arrX.count > 0) {
                        let spec = Spectra(xValues: arrX, yValues: arrY, isReal: isRealData)
                        self.spectra.append(spec)
                        arrX = []
                        arrY = []
                    }
                    
                    let spittedData = childString.components(separatedBy: "=")
                    var lhs = ""
                    var rhs = ""
                    if (spittedData.count > 1) {
                        lhs = spittedData[0]
                        rhs = spittedData[1]
                    }
                    else if (spittedData.count > 0) {
                        lhs = spittedData[0]
                    }
                    
                    if (dataType.contains("(X++(I..I))")) {
                        isRealData = false
                    }
                    else if (dataType.contains("(X++(R..R))")) {
                        isRealData = true
                    }
                    
                    self.dicData[lhs] = rhs
                    
                    //check user defined value
                    isReadingUserDefine = false
                    userDefineValue = ""
                    if (lhs.hasPrefix("##$")) {
                        isReadingUserDefine = true
                        userDefineValue = lhs
                    }
                }
            }
        }
    }
    
    // MARK: - Parsing Jcamp Data
    private func getDIFValue(difStr: Double, prev: Double = 0) -> Double {
        return difStr + prev
    }
    
    private func scanner(strVal: String) -> [String] {
        var result = [String]()
        
        var tmpStr = ""
        var scanStr = strVal
        
//        // check DUP
//        for (idx, c) in strVal.enumerated() {
//            let charString = String(c)
//            if let dupVal = DUP[charString] {
//                let lastChar = strVal[idx-1]
//                for _ in 0..<(dupVal-1) {
//                    scanStr.append(lastChar)
//                }
//            }
//            else {
//                scanStr.append(charString)
//            }
//        }
        var startPoint = -1
        for (idx, c) in scanStr.enumerated() {
            if (idx == startPoint-1) {
                continue
            }
            if (c.isNumeric || c == ".") {
                tmpStr.append(c)
            }
            else {
                if (tmpStr != "") {
                    tmpStr = tmpStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    result.append(tmpStr)
                    tmpStr = ""
                }
                
                let charString = String(c)
                if let dupVal = DUP[charString] {
                    var nextChars = ""
                    if (idx < scanStr.count - 1) {
                        startPoint = idx+1
                        while (scanStr[startPoint].isNumeric) {
                            nextChars.append(scanStr[idx+1])
                            startPoint += 1
                        }
                    }
                    let strDupValFull = "\(dupVal)\(nextChars)"
                    let dupValInt = Int(strDupValFull) ?? dupVal
                    //Check DUP
                    for _ in 0..<(dupValInt-1) {
                        if let lastTmpStr = result.last {
                            result.append(lastTmpStr)
                        }
                    }
                }
                else if let sqzVal = SQZ[charString] {
                    tmpStr.append(sqzVal)
                }
                else {
                    tmpStr.append(c)
                }
            }
        }
        
        if (tmpStr != "") {
            tmpStr = tmpStr.trimmingCharacters(in: .whitespacesAndNewlines)
            result.append(tmpStr)
            tmpStr = ""
        }
        
        
        return result
    }
    
    private func parser(strVal: String) -> (data: [Double], lastDIF: Bool) {
        var result = [Double]()
        
        let scannedResult = self.scanner(strVal: strVal)
        var hasLastDIF = false
        
        for (idx, value) in scannedResult.enumerated() {
            if let doubleVal = Double(value) {
                result.append(doubleVal)
                hasLastDIF = false
            }
            else {
                // DIF value
                let firstChar = value[0]
                let intFirst = DIF[firstChar] ?? ""
                let subVal = value.substring(fromIndex: 1)
                let difValStr = intFirst + subVal
                if let difVal = Double(difValStr) {
                    var convertedDIFVal = 0.0
                    if (result.count > 0) {
                        let prev = result[result.count-1]
                        convertedDIFVal = self.getDIFValue(difStr: difVal, prev: prev)
                    }
                    else {
                        convertedDIFVal = self.getDIFValue(difStr: difVal)
                    }
                    result.append(convertedDIFVal)
                    if (idx == scannedResult.count-1) {
                        hasLastDIF = true
                    }
                }
                
            }
        }
        return (data: result, lastDIF: hasLastDIF)
    }
}
