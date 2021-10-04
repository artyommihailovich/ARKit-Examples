//
//  Functional.swift
//  RealityKit-Shaders2
//
//  Created by Artyom Mihailovich on 10/4/21.
//

import Foundation

public protocol FunctionalWrapper {}

extension NSObject: FunctionalWrapper {}

public extension FunctionalWrapper {
    func `do`(_ mutator: (Self) -> Void) -> Self {
        mutator(self)
        return self
    }
}
