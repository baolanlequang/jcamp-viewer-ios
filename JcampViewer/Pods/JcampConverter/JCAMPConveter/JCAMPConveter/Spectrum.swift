//
//  JCamp.swift
//  JCAMPConveter
//
//  Created by Lan Le on 05.06.23.
//

import Foundation

public class Spectrum {
    private var dataString: String!
    
    private var parser: Parser!
    
    private var listX: [[Double]] = [], listY: [[Double]] = []
    private var factorX: Double, factorY: Double
    private var firstX: Double, lastX: Double
    
    public init(_ data: String, dataFormat: String, factorX: Double = 1.0, factorY: Double = 1.0, firstX: Double = 0.0, lastX: Double = 0.0) {
        self.dataString = data
        self.parser = Parser()
        self.factorX = factorX
        self.factorY = factorY
        self.firstX = firstX
        self.lastX = lastX
        
        let trimmedFormat = dataFormat.replacingOccurrences(of: " ", with: "")
        switch (trimmedFormat) {
        case "(X++(Y..Y))", "(X++(R..R))", "(X++(I..I))":
            self.parsePseudoData()
        default:
            self.parseXYData()
        }
        
    }
    
    private func parsePseudoData() {
        var arrStartX: [Double] = []
        
        let dataLines = self.dataString.components(separatedBy: .newlines)
        
        var nPoints = 0.0
        var isSkipCheckPoint = false
        for (lineIdx, line) in dataLines.enumerated() {
            let parsedLine = self.parser.parse(line)
            let parsedData = parsedLine.data
            let parsedDataCount = parsedData.count
            if (parsedDataCount > 1) {
                arrStartX.append(parsedData[0])
                var arrY: [Double] = []
                if (!isSkipCheckPoint) {
                    arrY = Array(parsedData[1..<parsedDataCount])
                }
                else {
                    var prevLine = self.listY[lineIdx - 1]
                    prevLine.removeLast()
                    self.listY[lineIdx-1] = prevLine
                    nPoints -= 1
                    arrY = Array(parsedData[1..<parsedDataCount])
                }
                
                self.listY.append(arrY)
                nPoints += Double(arrY.count)
                
                isSkipCheckPoint = parsedLine.isDIF
            }
        }
        
        let deltaX = (self.lastX - self.firstX) / (nPoints - 1)

        for (idx, startX) in arrStartX.enumerated() {
            var realXValue = startX * self.factorX
            var arrX: [Double] = [realXValue]
            let arrY = self.listY[idx]
            let arrCount = arrY.count
            if (arrCount > 2) {
                for _ in 1..<arrY.count {
                    realXValue += deltaX
                    arrX.append(realXValue)
                }
            }

            self.listX.append(arrX)

        }
    }
    
    private func parseXYData() {
        let dataLines = self.dataString.components(separatedBy: .newlines)
        
        for line in dataLines {
            let removedSpaceLine = line.replacingOccurrences(of: " ", with: "")
            let arrXY = removedSpaceLine.components(separatedBy: ";")
            var arrX: [Double] = [], arrY: [Double] = []
            for xy in arrXY {
                let values = xy.components(separatedBy: ",")
                if (values.count < 2) {
                    return
                }
                guard let xValue = Double(values[0]), let yValue = Double(values[1]) else {
                    return
                }
                
                arrX.append(xValue)
                arrY.append(yValue)
            }
            self.listX.append(arrX)
            self.listY.append(arrY)
        }
    }
    
    public func getListX() -> [Double] {
        var result: [Double] = []
        for line in self.listX {
            for xValue in line {
                result.append(xValue)
            }
        }
        return result
    }
    
    public func getListY() -> [Double] {
        var result: [Double] = []
        for line in self.listY {
            for yValue in line {
                let realY = yValue * self.factorY
                result.append(realY)
            }
        }
        return result
    }
}
