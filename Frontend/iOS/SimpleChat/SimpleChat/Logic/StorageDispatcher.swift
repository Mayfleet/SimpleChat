//
// Created by Maxim Pervushin on 06/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

class StorageDispatcher {

    static let defaultDispatcher = StorageDispatcher()

    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

    private func filePath(fileName: String) -> String? {
        return (documentsPath as NSString).stringByAppendingPathComponent("\(fileName).json")
    }

    func writeString(string: String, fileName: String) -> Bool {
        do {
            try string.writeToFile(filePath(fileName)!, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
    }

    func readString(fileName: String) -> String? {
        do {
            return try String(contentsOfFile: filePath(fileName)!, encoding: NSUTF8StringEncoding)
        } catch {
            return nil
        }
    }
}
