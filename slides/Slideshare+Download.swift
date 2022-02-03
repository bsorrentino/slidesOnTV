//
//  rx+download.swift
//  slides
//
//  Created by softphone on 04/07/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



//
// MARK: Download Presentation
//

func rxDownloadFromURL( presentation item:Slideshow, progression: progressionHandler? ) -> Single<(Slideshow,URL?)> {
    
    guard   let url = item[DocumentField.DownloadUrl]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
        let downloadURL = URL(string:url) else {
            return Single.error("download url not valid!")
    }
    
    return Single<(Slideshow,URL?)>.create() { (single) in
        
        var downloadTask:TCBlobDownload? 
        
        do {
            
            let documentDirectoryURL =
                try FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            downloadTask = TCBlobDownloadManager
                .sharedInstance
                .downloadFileAtURL( downloadURL,
                                    toDirectory: documentDirectoryURL,
                                    withName: "presentation.pdf",
                                    progression:progression)
                { (err, location) in
                    
                    
                    if let err = err {
                        
                        single(.error(err))
                    }
                    else {
                        single(.success((item,location)))
                    }
            }
            
        } catch let err {
            single(.error(err))
        }
        
        return Disposables.create {
            print( "CANCELLING DOWNLOAD TASK \(String(describing: downloadTask))")
            downloadTask?.cancel();
        }
    }
    
}
