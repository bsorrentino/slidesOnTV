//
//  Publisher+Extensions.swift
//  slides
//
//  Created by softphone on 04/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

/**
 @ref  https://www.donnywals.com/changing-a-publishers-failure-type-in-combine/
 */
extension Publisher {
    
  func toGenericError() -> AnyPublisher<Self.Output, Error> {
    return self.mapError({ (error: Self.Failure) -> Error in error} ).eraseToAnyPublisher()
  }
}
