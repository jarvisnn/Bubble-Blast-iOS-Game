//
//  Queue.swift
//  GraphADT
//
//  Created by kunn on 1/24/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

struct Queue<T> {
    private var queue: [T]
    
    init() {
        self.queue = [T]()
    }
    
    //  Adds an element to the tail of the queue.
    mutating func enqueue(item: T) {
        queue.append(item)
    }
    
    //  Removes an element the head of the queue and return it.
    //  If the queue is empty, return nil.
    mutating func dequeue() -> T? {
        let result = queue.first
        if queue.isEmpty == false {
            queue.removeAtIndex(0)
        }
        return result
    }
    
    //  Returns, but does not remove, the element at the head of the queue.
    //  If the queue is empty, returns nil.
    func peek() -> T? {
        return queue.first
    }
    
    // Returns the number of elements currently in the queue.
    var count: Int {
        return queue.count
    }
    
    //  Returns true if the queue is empty and false otherwise.
    var isEmpty: Bool {
        return queue.isEmpty
    }
    
    //  Removes all elements in the queue.
    mutating func removeAll() {
        queue.removeAll()
    }
    
    //  Returns the array of elements of the queue in the order
    //  that they are dequeued i.e. first element in the array
    //  is the first element dequeued.
    func toArray() -> [T] {
        return queue
    }
}