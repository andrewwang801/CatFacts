//
//  Then.swift
//  CatFacts
//
//  Created by Pae on 1/21/16.
//  Copyright © 2016 Pae. All rights reserved.
//

import Foundation

protocol Then {}

extension Then {
    func then(@noescape block: Self -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}