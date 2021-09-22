import UIKit
import Combine


let arr = [10, 20, 30, 40, 50]
let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()


let cancellable = timer
//                    .prefix(10)
                    .zip( arr.publisher)
                    .sink { value in
                        print(value)
                    }


//let cancellable2 = arr.publisher
//    .print()
//    .delay( for: 1.0, scheduler: RunLoop.main)
//    .sink { print($0) }

