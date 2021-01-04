//
// UnionFind.swift
// UnionFind
//
//  Created by Valeriano Della Longa on 2020/11/10
//  Copyright © 2020 Valeriano Della Longa
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

/// A data structure for modeling dynamic connectivity on a set of distinct elments.
///
/// Dynamic connectivity can be defined by two operations on  a set of *n* distinctive
/// nodes:
/// - **Union Command**: connect two nodes.
/// - **Find/Connected Query**: is there a path connecting two nodes?
/// Assuming *"is connected to"* is an equivalence relation between nodes, that is:
/// - **Reflexive**: *p* is connected to *p*.
/// - **Symmetric**: if *p* is connected to *q*, then *q* is also connected to *p*.
/// - **Transitive**:    if *p* is connected to *q* and *q* is connected to *r*,
///                 then *p* is also connected to *r*.
/// Where *p*, *q*, *r* are distinct nodes from the set.
public struct UnionFind {
    private(set) var ids: [Int] = []
    
    private(set) var sizes: [Int] = []
    
    /// Returns a new instance, initialized with the specified amount of nodes,
    /// without any connection between them.
    ///
    /// - Parameter _:  An Int value representing the number of nodes for the new
    ///                 instance. **Must not be negative**.
    /// - Returns:  A new instance with the specified number of nodes,
    ///             without any connection between them.
    public init(_ k: Int = 0) {
        precondition(k >= 0, "k must not be negative")
        guard k != 0 else { return }
        
        self.ids = Array(0..<k)
        self.sizes = Array(repeating: 1, count: k)
    }
    
}

// MARK: - Public interface
// MARK: - Computed properties
extension UnionFind {
    /// An integer value representing the total number of nodes in this instance.
    public var count: Int { ids.count }
    
    /// A Boolean value, `true` when this instance doesn't contain any node.
    public var isEmpty: Bool { ids.isEmpty }
}

// MARK: - Union-Find functionalities
extension UnionFind {
    /// Increases the number of nodes by the specified amount.
    ///
    /// - Parameter by: An Int value representing the number of additional nodes
    ///                 to add to this instance. **Must be positive**.
    /// - Note: Added nodes will be disconnected from any other one, either already in the
    ///         instance before the operation, or new one.
    /// - Complexity: O(log *m*) where *m* is the count of added nodes.
    public mutating func increaseNodesCount(by k: Int = 1) {
        precondition(k > 0, "k must be greater than zero")
        
        let idsToAppend = ids.count..<(ids.count + k)
        ids.append(contentsOf: idsToAppend)
        sizes.append(contentsOf: Array(repeating: 1, count: k))
    }
    
    /// Find the root node for the specified node.
    ///
    /// - Parameter _:  An Int value representing the id of the node to find the root of.
    ///                 **Must not be negative and less than the count of nodes of this instance**.
    /// - Returns:  An Int value representing the id of the root node for the specified
    ///             node id.
    /// - Complexity: O(log *n*) where *n* is the count of instance's nodes.
    /// - Note: Nodes are uniquevely identified by an Int value in range `0..<count`
    public func find(_ id: Int) -> Int {
        _checkID(id)
        
        return _fastRootOf(id)
    }
    
    /// Connectes the specified nodes.
    ///
    /// - Parameter _:  An Int value representing the id of one of the nodes to
    ///                 connect to the other one. **Must not be negative and less than the count of nodes of this instance**.
    /// - Parameter _:  An Int value representing the id of one of the nodes to
    ///                 connect to the other one. **Must not be negative and less than the count of nodes of this instance**.
    /// - Complexity: O(log *n*) where *n* is the count of nodes of the instance.
    /// - Note: Nodes are uniquevely identified by an Int value in range `0..<count`
    public mutating func union(_ lhs: Int, _ rhs: Int) {
        _checkID(lhs)
        _checkID(rhs)
        _fastUnion(lhs, rhs)
    }
    
    /// Returns `true` if the two specified nodes are connected, otherwise `false`.
    ///
    /// - Parameter _:  An Int value representing the id of one of the nodes to
    ///                 check if is connected to the other one. **Must not be negative and less than the count of nodes of this instance**.
    /// - Parameter _:  An Int value representing the id of one of the nodes to
    ///                 check if is connected to the other one. **Must not be negative and less than the count of nodes of this instance**.
    /// - Returns: `true` if the two nodes at the specified ids are connected,
    ///             otherwise `false`.
    /// - Complexity: O(log *n*) where *n* is the count of nodes of the instance.
    /// - Note: Nodes are uniquevely identified by an Int value in range `0..<count`
    public func areConnected(_ lhs: Int, _ rhs: Int) -> Bool {
        _checkID(lhs)
        _checkID(rhs)
        
        return _fastRootOf(lhs) == _fastRootOf(rhs)
    }
    
}

// MARK: - Internal and Private interface
extension UnionFind {
    @usableFromInline
    internal mutating func _fastUnion(_ lhs: Int, _ rhs: Int) {
        guard lhs != rhs else { return }
        
        let lhsRoot = _fastCompactingRootOf(lhs)
        let rhsRoot = _fastCompactingRootOf(rhs)
        guard lhsRoot != rhsRoot else { return }
        
        sizes.withUnsafeMutableBufferPointer { sizesBuff in
            ids.withUnsafeMutableBufferPointer { idsBuff in
                if sizesBuff[lhsRoot] < sizesBuff[rhsRoot] {
                    idsBuff[lhsRoot] = rhsRoot
                    sizesBuff[rhsRoot] += sizesBuff[lhsRoot]
                } else {
                    idsBuff[rhsRoot] = lhsRoot
                    sizesBuff[lhsRoot] += sizesBuff[rhsRoot]
                }
            }
        }
    }
    
    @usableFromInline
    internal func _fastRootOf(_ id: Int) -> Int {
        var i = id
        ids.withUnsafeBufferPointer { buff in
            while buff[i] != i {
                i = buff[i]
            }
        }
        
        return i
    }
    
    @inline(__always)
    private mutating func _fastCompactingRootOf(_ id: Int) -> Int {
        var i = id
        ids.withUnsafeMutableBufferPointer { buff in
            while buff[i] != i {
                buff[i] = buff[buff[i]]
                i = buff[i]
            }
        }
        
        return i
    }
    
    @inline(__always)
    private func _checkID(_ id: Int) {
        precondition(ids.indices ~= id, "Id out of range")
    }
    
}

