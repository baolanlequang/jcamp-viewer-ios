//
//  Jcamp.swift
//  JCAMPConveter
//
//  Created by Lan Le on 09.06.23.
//

import Foundation

public class Jcamp {
    
    public lazy var spectra: [Spectrum] = []
    public lazy var labeledDataRecords: [[String: String]] = []
    
    private lazy var originData: [String] = []
    
    public init(_ stringData: String) {
        if let fileURL = URL(string: stringData) {
            do {
                let data = try String(contentsOf: fileURL, encoding: .ascii)
                self.originData = data.components(separatedBy: .newlines)
                self.readData()
            }
            catch {
                print(error)
            }
        }
        else {
            self.originData = stringData.components(separatedBy: .newlines)
            self.readData()
        }
    }
    
    private func getSpectrum(arrData: [String], dataRecords: [String]) {
        if (arrData.count == 0) {
            return
        }
        
        var dicDataRecord: [String: String] = [:]
        for record in dataRecords {
            let values = record.components(separatedBy: "=")
            let label = values[0]
            
            dicDataRecord[label] = values.count > 1 ? values[1] : ""
        }
        
        let dataFormatValue = dicDataRecord["DATAFORMAT"]?.components(separatedBy: ",").first as? String ?? ""
        
        var firstXValue = 0.0, lastXValue = 0.0
        var factorXValue = 1.0, factorYValue = 1.0
        
        if var firstX = dicDataRecord["##FIRSTX"] {
            firstX = firstX.replacingOccurrences(of: " ", with: "")
            firstXValue = Double(firstX) ?? 0.0
        }
        else if var first = dicDataRecord["##FIRST"] {
            first = first.replacingOccurrences(of: " ", with: "")
            let arrFirst = first.components(separatedBy: ",")
            let firstX = arrFirst[0]
            let firstR = arrFirst[1]
            let firstI = arrFirst[2]
            dicDataRecord["##FIRSTX"] = firstX
            dicDataRecord["##FIRSTR"] = firstR
            dicDataRecord["##FIRSTI"] = firstI
            
            firstXValue = Double(firstX) ?? 0.0
        }
        else if let prevDicDataRecord = self.labeledDataRecords.last, let firstX = prevDicDataRecord["##FIRSTX"] {
            firstXValue = Double(firstX) ?? 0.0
        }
        
        if var lastX = dicDataRecord["##LASTX"] {
            lastX = lastX.replacingOccurrences(of: " ", with: "")
            lastXValue = Double(lastX) ?? 0.0
        }
        else if var last = dicDataRecord["##LAST"] {
            last = last.replacingOccurrences(of: " ", with: "")
            let arrLast = last.components(separatedBy: ",")
            let lastX = arrLast[0]
            let lastR = arrLast[1]
            let lastI = arrLast[2]
            dicDataRecord["##LASTX"] = lastX
            dicDataRecord["##LASTR"] = lastR
            dicDataRecord["##LASTI"] = lastI
            
            lastXValue = Double(lastX) ?? 0.0
        }
        else if let prevDicDataRecord = self.labeledDataRecords.last, let lastX = prevDicDataRecord["##LASTX"] {
            lastXValue = Double(lastX) ?? 0.0
        }
        
        if var factorX = dicDataRecord["##XFACTOR"] {
            factorX = factorX.replacingOccurrences(of: " ", with: "")
            factorXValue = Double(factorX) ?? 1.0
        }
        else if var factor = dicDataRecord["##FACTOR"] {
            factor = factor.replacingOccurrences(of: " ", with: "")
            let arrFactors = factor.components(separatedBy: ",")
            let factorX = arrFactors[0]
            let factorR = arrFactors[1]
            let factorI = arrFactors[2]
            dicDataRecord["##XFACTOR"] = factorX
            dicDataRecord["##RFACTOR"] = factorR
            dicDataRecord["##IFACTOR"] = factorI
            
            factorXValue = Double(factorX) ?? 1.0
        }
        else if let prevDicDataRecord = self.labeledDataRecords.last, let factorX = prevDicDataRecord["##XFACTOR"] {
            factorXValue = Double(factorX) ?? 1.0
        }
        
        if var factorY = dicDataRecord["##YFACTOR"] {
            factorY = factorY.replacingOccurrences(of: " ", with: "")
            factorYValue = Double(factorY) ?? 1.0
        }
        else if let factorR = dicDataRecord["##RFACTOR"] {
            factorYValue = Double(factorR) ?? 1.0
        }
        else if let prevDicDataRecord = self.labeledDataRecords.last, let factorI = prevDicDataRecord["##IFACTOR"] {
            factorYValue = Double(factorI) ?? 1.0
        }
        
        let data = arrData.joined(separator: "\n")
        let spectrum = Spectrum(data, dataFormat: dataFormatValue, factorX: factorXValue, factorY: factorYValue, firstX: firstXValue, lastX: lastXValue )
        self.spectra.append(spectrum)
        self.labeledDataRecords.append(dicDataRecord)
    }
    
    private func readData() {
        var readingData = false
        var storeDataForReading: [String] = []
        var storeLabelDataRecords: [String] = []
        for line in originData {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine == "") {
                //ignore empty line
                continue
            }
            if (trimmedLine.hasPrefix("##")) {
                if (trimmedLine.hasPrefix("##XYDATA=") || trimmedLine.hasPrefix("##XYPOINTS=") || trimmedLine.hasPrefix("##PEAK TABLE=") || trimmedLine.hasPrefix("##PEAK ASSIGNMENTS=") || trimmedLine.hasPrefix("##DATA TABLE=")) {
                    
                    let seperatedLine = trimmedLine.components(separatedBy: "=")
                    let dataFormatStr = "DATAFORMAT=\(seperatedLine[1])"
                    storeLabelDataRecords.append(dataFormatStr)
                    
                    if (storeDataForReading.count > 0) {
                        self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                        storeDataForReading = []
                    }
                    readingData = true
                }
                else {
                    readingData = false
                    self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                    
                    if (storeDataForReading.count > 0) {
                        storeLabelDataRecords = []
                    }
                    
                    storeDataForReading = []
                    
                    storeLabelDataRecords.append(trimmedLine)
                }
            }
            else if (!trimmedLine.hasPrefix("$") && readingData) {
                storeDataForReading.append(trimmedLine)
            }
            else {
                readingData = false
                self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                
                if (storeDataForReading.count > 0) {
                    storeLabelDataRecords = []
                }
                
                storeDataForReading = []
                
                storeLabelDataRecords.append(trimmedLine)
                
            }
        }
    }
}
