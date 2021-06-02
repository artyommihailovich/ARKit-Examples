//
//  Functional.swift
//  ARVoiceRemote
//
//  Created by Artyom Mihailovich on 5/31/21.
//

import Foundation

protocol FunctionalWrapper {}

extension NSObject: FunctionalWrapper {}

extension FunctionalWrapper {
    func `do`(_ mutator: (Self) -> Void) -> Self {
        mutator(self)
        return self
    }
}

