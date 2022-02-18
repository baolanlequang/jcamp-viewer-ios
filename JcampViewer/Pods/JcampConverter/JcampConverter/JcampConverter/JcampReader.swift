//
//  JcampReader.swift
//  JcampConverter
//
//  Created by Lan Le on 02.02.22.
//

import Foundation

public class JcampReader {
    
    public var jcamp: Jcamp?
    
    public init() {}
    
    public init(filePath: String) {
        do {
            let data = try String(contentsOfFile: filePath, encoding: .ascii)
            let tmpData = data.components(separatedBy: .newlines)
            let structuredData = self.parsingStructure(data: tmpData)
            self.jcamp = Jcamp(originData: structuredData)
        }
        catch {
            print(error)
        }
    }
    
    private func popChildBlock(param: inout (stack: [Any], queue: [Any])) {
        var (stack, queue) = param
        var topStack = stack.peak() as? String
        
        while ((topStack != nil) && !(topStack!.starts(with: "##TITLE="))) {
            if let popValue = stack.pop() {
                queue.insert(popValue, at: 0)
                topStack = stack.peak() as? String
            }
        }

        if let remainTop = stack.peak() as? String, remainTop.starts(with: "##TITLE=") {
            if let popValue = stack.pop() {
                queue.insert(popValue, at: 0)
            }
        }
        
        param = (stack: stack, queue: queue)
    }
    
    private func parsingStructure(data: [String]) -> [Any] {
        var stack = [Any]()
        
        for line in data {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine == "") {
                //ignore empty line
                continue
            }
            
            if let remainTop = stack.peak() as? String, remainTop.starts(with: "##END=") {
                var param = (stack: stack, queue: [])
                self.popChildBlock(param: &param)
                stack = param.stack
                stack.push(item: param.queue)
                stack.push(item: trimmedLine)
            }
            else {
                stack.push(item: trimmedLine)
            }
        }
        
        return stack
    }
}
