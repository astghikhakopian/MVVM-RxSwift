//
//  ReadOnce.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/12/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Foundation

class ReadOnce<Value> {
    var isRead: Bool {
        return value == nil
    }
    
    private var value: Value?
    
    init(_ value: Value?) {
        self.value = value
    }
    
    func read() -> Value? {
        defer { value = nil }
        
        if value != nil {
            return value
        }
        
        return nil
    }
}
