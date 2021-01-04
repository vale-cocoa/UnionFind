//
// UnionFindTests.swift
// UnionFindTests
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

import XCTest
@testable import UnionFind

final class UnionFindTests: XCTestCase {
    var sut: UnionFind!
    
    override func setUp() {
        super.setUp()
        
        sut = UnionFind()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Intializers tests
    func testInit_whenKIsZero() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.ids)
        XCTAssertNotNil(sut.sizes)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertTrue(sut.ids.isEmpty)
        XCTAssertTrue(sut.sizes.isEmpty)
    }
    
    func testInit_whenKIsGreaterThanZero() {
        for k in 1...100 {
            sut = UnionFind(k)
            XCTAssertNotNil(sut)
            XCTAssertNotNil(sut.ids)
            XCTAssertNotNil(sut.sizes)
            XCTAssertFalse(sut.isEmpty)
            XCTAssertFalse(sut.ids.isEmpty)
            XCTAssertFalse(sut.sizes.isEmpty)
            XCTAssertEqual(sut.count, k)
            XCTAssertEqual(sut.ids.count, k)
            XCTAssertEqual(sut.sizes.count, k)
            XCTAssertEqual(sut.ids, Array(0..<k))
            XCTAssertEqual(sut.sizes, Array(repeating: 1, count: k))
        }
    }
    
    // MARK: - Computed properties tests
    func testCount() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.count, sut.ids.count)
        
        whenNotEmptyElementsDisconnected()
        XCTAssertFalse(sut.isEmpty)
        XCTAssertGreaterThan(sut.count, 0)
        XCTAssertEqual(sut.count, sut.ids.count)
    }
    
    func testIsEmpty() {
        XCTAssertEqual(sut.count, 0)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.isEmpty, sut.ids.isEmpty)
        
        whenNotEmptyElementsDisconnected()
        XCTAssertGreaterThan(sut.count, 0)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.isEmpty, sut.ids.isEmpty)
    }
    
    // MARK: - Common functionalities tests
    func testIncreaseNodesCount() {
        for _ in 0..<10 {
            let prevCount = sut.count
            sut.increaseNodesCount()
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.ids.count, sut.count)
            XCTAssertEqual(sut.sizes.count, sut.count)
            XCTAssertEqual(sut.ids[prevCount], prevCount)
            XCTAssertEqual(sut.sizes[prevCount], 1)
        }
        
        let prevCount = sut.count
        sut.increaseNodesCount(by: 10)
        XCTAssertEqual(sut.count, prevCount + 10)
        XCTAssertEqual(sut.ids.count, prevCount + 10)
        XCTAssertEqual(sut.sizes.count, prevCount + 10)
        XCTAssertEqual(Array(sut.ids[prevCount..<(prevCount + 10)]), Array(prevCount..<(prevCount + 10)))
        XCTAssertEqual(Array(sut.sizes[prevCount..<(prevCount + 10)]), Array(repeating: 1, count: 10))
    }
    
    func testUnion() {
        whenNotEmptyElementsDisconnected()
        
        // when ids are equal, then nothing changes:
        var prevIDS = sut.ids
        var prevSizes = sut.sizes
        sut.union(0, 0)
        XCTAssertEqual(sut.ids, prevIDS)
        XCTAssertEqual(sut.sizes, prevSizes)
        
        // when ids are different, roots are different,
        // then sets same root and weight of root increases by one:
        XCTAssertNotEqual(sut.ids[0], sut.ids[1])
        XCTAssertEqual(sut.sizes[0], sut.sizes[1])
        sut.union(0, 1)
        XCTAssertEqual(sut.ids[0], sut.ids[1])
        XCTAssertGreaterThan(sut.sizes[sut.ids[0]], 1)
        XCTAssertEqual(2, sut.sizes[sut.ids[0]])
        
        // when ids are different, roots are same,
        // then nothing changes:
        prevIDS = sut.ids
        prevSizes = sut.sizes
        XCTAssertEqual(sut.ids[0], sut.ids[1])
        sut.union(0, 1)
        XCTAssertEqual(sut.ids, prevIDS)
        XCTAssertEqual(sut.sizes, prevSizes)
        
        // when ids and roots are different, leftmost root weight is
        // smaller than rightmost one, then sets common root to
        // rightmost one and increases rightmost root weight by
        // leftmost root weight:
        var lhs = 2
        var rhs = 1
        var lhsRoot = sut.ids[lhs]
        var rhsRoot = sut.ids[rhs]
        XCTAssertNotEqual(lhsRoot, rhsRoot)
        var lhsRootPrevSize = sut.sizes[lhsRoot]
        var rhsRootPrevSize = sut.sizes[rhsRoot]
        XCTAssertGreaterThan(rhsRootPrevSize, lhsRootPrevSize)
        sut.union(lhs, rhs)
        XCTAssertEqual(sut.ids[lhs], sut.ids[rhs])
        XCTAssertEqual(sut.ids[lhs], rhsRoot)
        XCTAssertGreaterThan(sut.sizes[rhsRoot], rhsRootPrevSize)
        XCTAssertEqual(sut.sizes[rhsRoot], rhsRootPrevSize + lhsRootPrevSize)
        XCTAssertEqual(sut.sizes[rhsRoot], 3)
        
        // when ids and roots are different, leftmost root weight is
        // greater than rigthmost one, then sets common root to
        // leftmost one, and increases leftmost root weight by
        // rightmost root weight:
        sut.union(3, 4)
        lhs = 2
        rhs = 3
        lhsRoot = sut.ids[lhs]
        rhsRoot = sut.ids[rhs]
        XCTAssertNotEqual(lhsRoot, rhsRoot)
        lhsRootPrevSize = sut.sizes[lhsRoot]
        rhsRootPrevSize = sut.sizes[rhsRoot]
        XCTAssertGreaterThan(lhsRootPrevSize, rhsRootPrevSize)
        sut.union(lhs, rhs)
        XCTAssertEqual(sut.ids[lhs], sut.ids[rhs])
        XCTAssertEqual(sut.ids[lhs], lhsRoot)
        XCTAssertGreaterThan(sut.sizes[lhsRoot], lhsRootPrevSize)
        XCTAssertEqual(sut.sizes[lhsRoot], rhsRootPrevSize + lhsRootPrevSize)
        XCTAssertEqual(sut.sizes[lhsRoot], 5)
    }
    
    func testAreConnected() {
        whenNotEmptyElementsDisconnected()
        // when lhs is equal to rhs, then returns true:
        XCTAssertTrue(sut.areConnected(0, 0))
        
        // when lhs and rhs are different and have different roots,
        // then return false:
        let lhs = 0
        let rhs = 1
        var lhsRoot = sut.find(lhs)
        var rhsRoot = sut.find(rhs)
        XCTAssertNotEqual(lhsRoot, rhsRoot)
        XCTAssertFalse(sut.areConnected(lhs, rhs))
        
        sut.union(lhs, rhs)
        // when lhs and rhs are different and have same root,
        // then returns true:
        lhsRoot = sut.find(lhs)
        rhsRoot = sut.find(rhs)
        XCTAssertEqual(lhsRoot, rhsRoot)
        XCTAssertTrue(sut.areConnected(lhs, rhs))
    }
    
    
    func testMonteCarloSimulation() {
        for i in 0..<10 {
            var montecarlo = MonteCarloSimulation(1000)
            while montecarlo.p <= MonteCarloSimulation.pThreshold {
                montecarlo.openRandomSite()
            }
            XCTAssertTrue(montecarlo.isPercolating, "Not percolating despite p is greater than p*\np = \(montecarlo.p)\np* = \(MonteCarloSimulation.pThreshold)\nIteration: \(i)\nOpened sites: \(montecarlo.openSitesCount)")
        }
        
    }
    
    // MARK: - Private helpers
    // MARK: - When
    private func whenNotEmptyElementsDisconnected() {
        sut = UnionFind(10)
    }
    
}
