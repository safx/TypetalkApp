//
//  ObservableArray.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/19.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import RxSwift

public struct ArrayChangeEvent {
    public let insertedIndeces: [Int]
    public let deletedIndeces: [Int]
    public let updatedIndeces: [Int]

    init(inserted: [Int] = [], deleted: [Int] = [], updated: [Int] = []) {
        assert(inserted.count + deleted.count + updated.count > 0)
        self.insertedIndeces = inserted
        self.deletedIndeces = deleted
        self.updatedIndeces = updated
    }
}

public struct ObservableArray<Element> {
    public typealias EventType = ArrayChangeEvent

    private var eventSubject = PublishSubject<EventType>()
    private var elementsSubject = PublishSubject<[Element]>()
    private var elements = [Element]()

    public init() {
    }
}

extension ObservableArray {
    public typealias EventObservableType = Observable<EventType>
    public typealias ArrayObservableType = Observable<[Element]>

    public var rx_elements: ArrayObservableType {
        return elementsSubject
    }

    public var rx_event: EventObservableType {
        return eventSubject
    }

    private func arrayDidChanged(event: EventType) {
        elementsSubject.on(.Next(self.elements))
        eventSubject.on(.Next(event))
    }
}

extension ObservableArray: Indexable {
    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }
}

extension ObservableArray: RangeReplaceableCollectionType {
    public var capacity: Int {
        return elements.capacity
    }

    public mutating func reserveCapacity(minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }

    public mutating func append(newElement: Element) {
        elements.append(newElement)
        arrayDidChanged(ArrayChangeEvent(inserted: [elements.count - 1]))
    }

    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
        let end = elements.count
        elements.appendContentsOf(newElements)
        arrayDidChanged(ArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    public mutating func appendContentsOf<C : CollectionType where C.Generator.Element == Element>(newElements: C) {
        let end = elements.count
        elements.appendContentsOf(newElements)
        arrayDidChanged(ArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    public mutating func removeLast() -> Element {
        let e = elements.removeLast()
        arrayDidChanged(ArrayChangeEvent(deleted: [elements.count]))
        return e
    }

    public mutating func insert(newElement: Element, atIndex i: Int) {
        elements.insert(newElement, atIndex: i)
        arrayDidChanged(ArrayChangeEvent(inserted: [i]))
    }

    public mutating func removeAtIndex(index: Int) -> Element {
        let e = elements.removeAtIndex(index)
        arrayDidChanged(ArrayChangeEvent(deleted: [index]))
        return e
    }

    public mutating func removeAll(keepCapacity: Bool = false) {
        let es = elements
        elements.removeAll(keepCapacity: keepCapacity)
        guard !es.isEmpty else { return }
        arrayDidChanged(ArrayChangeEvent(deleted: Array(0..<es.count)))
    }

    public mutating func splice(newElements: [Element], atIndex i: Int) {
        if !newElements.isEmpty {
            elements.insertContentsOf(newElements, at: i)
            arrayDidChanged(ArrayChangeEvent(inserted: Array(i..<i + newElements.count)))
        }
    }

    public func removeRange(subRange: Range<Int>) {
        var es = [Element]()
        for i in subRange {
            es.append(elements[i])
        }
        arrayDidChanged(ArrayChangeEvent(deleted: Array(subRange)))
    }

    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Element>(subRange: Range<Int>, with newCollection: C) {
        elements.replaceRange(subRange, with: newCollection)
    }

    public mutating func popLast() -> Element? {
        let e = elements.popLast()
        if e != nil {
            arrayDidChanged(ArrayChangeEvent(deleted: [elements.count - 1]))
        }
        return e
    }
}

extension ObservableArray: CustomDebugStringConvertible {
    public var description: String {
        return elements.description
    }
}

extension ObservableArray: CustomStringConvertible {
    public var debugDescription: String {
        return elements.debugDescription
    }
}

extension ObservableArray: CollectionType {

    public subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
            if index == elements.count {
                arrayDidChanged(ArrayChangeEvent(inserted: [index]))
            } else {
                arrayDidChanged(ArrayChangeEvent(updated: [index]))
            }
        }
    }
}

extension ObservableArray: MutableSliceable {

    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return elements[bounds]
        }
        set {
            elements[bounds] = newValue
            guard let first = bounds.first else { return }
            arrayDidChanged(ArrayChangeEvent(inserted: Array(first..<first + newValue.count),
                                             deleted: Array(bounds)))
        }
    }
}
