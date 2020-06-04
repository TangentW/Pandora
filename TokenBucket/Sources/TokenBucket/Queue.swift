//
//  Queue.swift
//  TokenBucket
//
//  Created by Tangent on 2020/6/3.
//

struct Queue<Element> {
    
    init(capacity: Int = 2) {
        _initialCapacity = capacity
        _storage = .init(repeating: nil, count: capacity + 1)
    }
    
    private var _initialCapacity: Int
    private var _storage: _Storage
    private typealias _Storage = ContiguousArray<Element?>
    
    private var _headIndex = 0
    private var _tailIndex = 0
}

extension Queue {
    
    var isEmpty: Bool { _headIndex == _tailIndex }
    

    var count: Int {
        let diff = _tailIndex - _headIndex
        return diff >= 0 ? diff : _capacity + diff
    }
    
    var head: Element? {
        guard !isEmpty else { return nil }
        return _storage[_headIndex]
    }
    
    mutating func enqueue(_ element: Element) {
        if (_tailIndex + 1) % _capacity == _headIndex {
            _resize(to: 2 * _capacity)
        }
        _storage[_tailIndex] = element
        _tailIndex = (_tailIndex + 1) % _capacity
    }
    
    mutating func dequeue() -> Element? {
        guard !isEmpty else { return nil }
        let result = _storage[_headIndex]
        _storage[_headIndex] = nil
        _headIndex = (_headIndex + 1) % _capacity
        
        if count < _capacity / 4, (_capacity / 2) >= _initialCapacity {
            _resize(to: _capacity / 2)
        }
        
        return result
   }
}

private extension Queue {
    
    var _capacity: Int { _storage.count }
    
    mutating func _resize(to capacity: Int) {
        var newStorage = _Storage(repeating: nil, count: capacity)
        for index in (0..<count) {
            newStorage[index] = _storage[(_headIndex + index) % _capacity]
        }
        _tailIndex = count
        _headIndex = 0
        _storage = newStorage
    }
}
