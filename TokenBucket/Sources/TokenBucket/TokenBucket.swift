//
//  TokenBucket.swift
//  TokenBucket
//
//  Created by Tangent on 2020/6/3.
//

import Foundation

struct TokenBucket {
    
    var tokenCount: Int {
        mutating get {
            _replenish()
            return _tokenCount
        }
    }
    
    init(tokensPerInterval: Int, interval: TimeInterval, capacity: Int, initialTokens: Int = 0) {
        assert(interval != 0)
        _tokensPerInterval = tokensPerInterval
        _interval = interval
        _capacity = capacity
        
        _tokenCount = min(initialTokens, capacity)
        _timestamp = CFAbsoluteTimeGetCurrent()
    }
    
    private let _tokensPerInterval: Int
    private let _interval: TimeInterval
    private let _capacity: Int
    
    private var _tokenCount: Int
    private var _timestamp: TimeInterval
}

extension TokenBucket {
    
    @discardableResult
    mutating func consume(count: Int) -> Bool {
        guard canConsume(count: count) else { return false }
        _tokenCount -= count
        return true
    }
    
    mutating func canConsume(count: Int) -> Bool {
        _replenish()
        return _tokenCount >= count
    }
}

private extension TokenBucket {
    
    mutating func _replenish() {
        let current = CFAbsoluteTimeGetCurrent()
        let interval = current - _timestamp
        guard interval >= _interval else { return }
        let newTokens = _tokensPerInterval * Int(interval / _interval)
        _tokenCount = min(_capacity, _tokenCount + newTokens)
        _timestamp = current
    }
}
