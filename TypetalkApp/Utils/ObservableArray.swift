//
//  ObservableArray.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/19.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import RxSwift

public enum ArrayElementsChangeEvent<T> {
    case Inserted([Int])
    case Deleted([Int], [T])
    case Updated([Int])
}

public class ObservableArray<T> {
    public typealias Element = T
    public typealias EventType = ArrayElementsChangeEvent<T>
    public typealias EventObservableType = Observable<EventType>
    public typealias ArrayObservableType = Observable<[T]>

    public  var rx_event: EventObservableType {
        return eventSubject
    }
    public  var rx_elements: ArrayObservableType {
        return elementsSubject
    }
    private var eventSubject: PublishSubject<EventType>!
    private var elementsSubject: PublishSubject<[T]>!
    private var elements = [Element]()
    private var valueChangedClosure: (EventType -> ())?

    public var startIndex: Int          { return elements.startIndex }
    public var endIndex: Int            { return elements.endIndex }
    public var count: Int               { return elements.count }
    public var capacity: Int            { return elements.capacity }
    public var isEmpty: Bool            { return elements.isEmpty }
    public var first: T?                { return elements.first }
    public var last: T?                 { return elements.last }
    public var description: String      { return elements.description }
    public var debugDescription: String { return elements.debugDescription }

    public init() {
        eventSubject = PublishSubject<EventType>()
        elementsSubject = PublishSubject<[T]>()

        valueChangedClosure = { diff -> () in
            self.elementsSubject.on(.Next(self.elements))
            self.eventSubject.on(.Next(diff))
        }
    }

    public func reserveCapacity(minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }

    public func append(newElement: T) {
        elements.append(newElement)
        valueChangedClosure?(.Inserted([elements.count - 1]))
    }

    public func extend(newElements: [T]) {
        let c = elements.count
        elements.appendContentsOf(newElements)
        valueChangedClosure?(.Inserted(Array<Int>(c..<elements.count)))
    }

    public func removeLast() -> T {
        let e = elements.removeLast()
        valueChangedClosure?(.Deleted([elements.count], [e]))
        return e
    }

    public func insert(newElement: T, atIndex i: Int) {
        elements.insert(newElement, atIndex: i)
        valueChangedClosure?(.Inserted([i]))
    }

    public func removeAtIndex(index: Int) -> T {
        let e = elements.removeAtIndex(index)
        valueChangedClosure?(.Deleted([index], [e]))
        return e
    }

    public func removeAll(keepCapacity: Bool = false) {
        let es = elements
        elements.removeAll(keepCapacity: keepCapacity)
        valueChangedClosure?(.Deleted(Array<Int>(0..<es.count), es))
    }

    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        return elements.reduce(initial, combine: combine)
    }

    public func sorted(isOrderedBefore: (T, T) -> Bool) -> [T] {
        return elements.sort(isOrderedBefore)
    }

    public func map<U>(transform: (T) -> U) -> [U] {
        return elements.map(transform)
    }

    public func reverse() -> [T] {
        return reverse()
    }

    public func filter(includeElement: (T) -> Bool) -> [T] {
        return elements.filter(includeElement)
    }

    public func splice(newElements: [T], atIndex i: Int) {
        if !newElements.isEmpty {
            elements.insertContentsOf(newElements, at: i)
            valueChangedClosure?(.Inserted(Array<Int>(i..<i + newElements.count)))
        }
    }

    func removeRange(subRange: Range<Int>) {
        var es = [T]()
        for i in subRange {
            es.append(elements[i])
        }
        valueChangedClosure?(.Deleted(Array<Int>(subRange), es))
    }

}

extension ObservableArray: CollectionType {
    public subscript(index: Int) -> T {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
            if index == elements.count {
                valueChangedClosure?(.Inserted([index]))
            } else {
                valueChangedClosure?(.Updated([index]))
            }
        }
    }

    public func generate() -> IndexingGenerator<[T]> {
        return elements.generate()
    }
}
