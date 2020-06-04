//
//  RateLimiter.swift
//  TokenBucket
//
//  Created by Tangent on 2020/6/5.
//

import Foundation

final class RateLimiter {
    
    struct WorkItem {
        
        typealias Finished = Bool
        let cost: Int
        let work: () -> Finished
        
        init(cost: Int, work: @escaping () -> Finished) {
            self.cost = cost
            self.work = work
        }
    }

    init(
        queue: DispatchQueue = DispatchQueue(label: "RateLimiter"),
        tokensPerInterval: Int,
        interval: TimeInterval,
        capacity: Int,
        initialTokens: Int = 0
    ) {
        _queue = queue
        _tokenBucket = TokenBucket(tokensPerInterval: tokensPerInterval, interval: interval, capacity: capacity, initialTokens: initialTokens)
    }

    private let _queue: DispatchQueue
    private var _tasks = Queue<WorkItem>(capacity: 8)
    private var _tokenBucket: TokenBucket
    private var _isConsuming = false
}

extension RateLimiter {
    
    func execute(cost tokens: Int = 1, with work: @escaping () -> Bool) {
        execute(.init(cost: tokens, work: work))
    }
    
    func execute(_ item: WorkItem) {
        _queue.async { [weak self] in
            self?._execute(item)
        }
    }
}

private extension RateLimiter {
    
    func _execute(_ item: WorkItem) {
        if !_tasks.isEmpty || !_tokenBucket.canConsume(count: item.cost) {
            _tasks.enqueue(item)
            _consumeTasksIfNeeded()
        } else {
            if item.work() {
                _tokenBucket.consume(count: item.cost)
            }
        }
    }
    
    func _consumeTasksIfNeeded() {
        guard !_isConsuming else { return }
        _isConsuming = true
        _queue.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            self?._consumeTasks()
        }
    }
    
    func _consumeTasks() {
        while let item = _tasks.head, _tokenBucket.canConsume(count: item.cost) {
            if item.work() {
                _tokenBucket.consume(count: item.cost)
            }
            _ = _tasks.dequeue()
        }
        _isConsuming = false
        if !_tasks.isEmpty {
            _consumeTasksIfNeeded()
        }
    }
}
