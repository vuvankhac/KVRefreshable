//
//  KVConstants.swift
//  KVRefreshable
//
//  Created by Vu Van Khac on 1/24/17.
//  Copyright © 2017 Janle. All rights reserved.
//

public enum KVState {
    case triggered
    case loading
    case stopped
    
    func value() -> Int {
        switch self {
        case .triggered:
            return 0
            
        case .loading:
            return 1
            
        case .stopped:
            return 2
        }
    }
}
