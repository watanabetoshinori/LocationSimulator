//
//  Process+Utility.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 6/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Cocoa

extension Process {
    
    class func isExists(_ command: String) -> Bool {
        let output = execute("which \(command)")
        return !output.isEmpty
    }

    class func execute(_ command: String) -> String {
        let pipe = Pipe()
        let file = pipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-l", "-c", command]
        process.standardOutput = pipe
        
        process.launch()
        
        let data = file.readDataToEndOfFile()
        file.closeFile()
        
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return output
    }

}
