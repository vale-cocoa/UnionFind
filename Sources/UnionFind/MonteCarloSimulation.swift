//
//  MonteCarloSimulation.swift
//  UnionFind
//
//  Created by Valeriano Della Longa on 2020/11/13.
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

public struct MonteCarloSimulation {
    public let sideCount: Int
    
    public let sitesCount: Int
    
    public var openSitesCount = 0
    
    public private(set) var elements: [Bool]
    
    private(set) var unionFind: UnionFind
    
    let virtualTop = 0
    
    let virtualBottom: Int
    
    public init(_ sideCount: Int = 5) {
        precondition(sideCount >= 5, "Must use a value greater than or equal to 5")
        self.sideCount = sideCount
        self.sitesCount = sideCount * sideCount
        self.elements = Array(repeating: false, count: sideCount * sideCount)
        self.unionFind = UnionFind((sideCount * sideCount + 2))
        self.virtualBottom = self.unionFind.count - 1
        for i in 1...sideCount {
            unionFind.union(0, i)
        }
        for i in stride(from: virtualBottom - 1, through: virtualBottom - 1 - sideCount, by: -1) {
            unionFind.union(virtualBottom, i)
        }
    }
    
}

extension MonteCarloSimulation {
    public static let pThreshold: Double = /*0.592746*/ 0.596
    
    public var isPercolating: Bool {
        unionFind._fastRootOf(virtualTop) == unionFind._fastRootOf(virtualBottom)
    }
    
    public var p: Double {
        Double(openSitesCount) / Double(sitesCount)
    }
    
}

extension MonteCarloSimulation {
    public mutating func openRandomSite() {
        guard sitesCount != openSitesCount else { return }
        
        let site = _randomClosedSite()
        _openSite(site)
    }
    
    private mutating func _openSite(_ site: Int) {
        guard !elements[site] else { return }
        
        elements[site] = true
        openSitesCount += 1
        
        for adj in _adjacenciesOpened(for: site)  {
            unionFind._fastUnion(site, adj)
        }
    }
    
    private func _randomClosedSite() -> Int {
        var site: Int!
        repeat {
            site = Int.random(in: 1..<sitesCount)
        } while elements[site] == true
        
        return site
    }
    
    private func _adjacenciesOpened(for site: Int) -> [Int] {
        [site - sideCount, site + 1, site + sideCount, site - 1]
            .filter { adj in
                guard elements.startIndex..<elements.endIndex ~= adj else { return false }
                
                return elements[adj]
            }
    }
    
}
