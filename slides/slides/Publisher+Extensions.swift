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

/**
 @ref https://stackoverflow.com/q/59367202
 */
public extension Publisher where Self.Failure == Never {
    func modulatedPublisher(interval: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        let timerBuffer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            

        return timerBuffer
            .zip(self, { $1 })  // should emit one input element ($1) every timer tick
            .eraseToAnyPublisher()
    }
}
