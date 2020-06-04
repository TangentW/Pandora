
import Foundation

let limiter = RateLimiter(tokensPerInterval: 3, interval: 0.5, capacity: 20, initialTokens: 5)

for i in (1...20) {
    limiter.execute {
        print("+++ \(i)")
        return true
    }
}

sleep(10)

for i in (21...100) {
    limiter.execute {
        print("--- \(i)")
        return true
    }
}

RunLoop.current.run()
