//
//  Logger.swift
//  Core
//
//  Created by Ahmed Chebbi on 06/10/2024.
//

import Foundation

public class Logger {
    
    public static func logInfo(_ log: String) {
#if DEBUG
        print(" ℹ️ ℹ️ ℹ️ [\(Date())] [INFO] ℹ️ ℹ️ ℹ️ \(Logger.self) -> \(#function) : \(log)")
#endif
    }
    
    public static func logError(_ log: String) {
#if DEBUG
        print("❌ ❌ ❌ [\(Date())] [ERROR] ❌ ❌ ❌ \(Logger.self) -> \(#function) : \(log)")
#endif
    }
    
    public static func logWarning(_ log: String) {
#if DEBUG
        print("⚠️ ⚠️ ⚠️ [\(Date())] [WARNING] ⚠️ ⚠️ ⚠️ \(Logger.self) -> \(#function) : \(log)")
#endif
    }
}
