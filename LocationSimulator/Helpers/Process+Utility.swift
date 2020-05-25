//
//  Process+Utility.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
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

        do {
            try process.run()

            let data = file.readDataToEndOfFile()
            file.closeFile()

            let output = String(data: data, encoding: .utf8) ?? ""

            return output

        } catch {
            return error.localizedDescription
        }
    }

}
