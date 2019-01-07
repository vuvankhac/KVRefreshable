//
//  KVConstants.swift
//  KVRefreshable
//
//  Created by Vu Van Khac on 1/24/17.
//  Copyright © 2017 Janle. All rights reserved.
//

public enum KVState {
    case stopped
    case triggered
    case loading
    
    func value() -> Int {
        switch self {
        case .stopped:
            return 0
        case .triggered:
            return 1
        case .loading:
            return 2
        }
    }
}
