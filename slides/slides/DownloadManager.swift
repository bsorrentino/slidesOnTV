//
//  DownloadManager.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

class DownloadManager : ObservableObject {
    
    typealias Input = URL
    
    @Published var downloadInfo:Input?
    @Published var downloadedItem:Bool = false
    
    private(set) var downloadedUrl:URL?
    private(set) var document:PDFDocument?

    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $downloadInfo
            .sink(receiveValue: {
                if let downloadUrl = $0 {
                    self.download( fromURL: downloadUrl)
                }

            })
            .store(in: &subscriptions)
        
    }
    
    private func download( fromURL downloadURL:URL ) {
        
        do {
            
            let request = URLRequest(url:downloadURL)
            
            let session = URLSession(configuration: URLSessionConfiguration.default)

            let destinationFileUrl =
                try FileManager().url(for: .cachesDirectory,
                                      in: .userDomainMask,
                                      appropriateFor: nil,
                                      create: false).appendingPathComponent("presentation.pdf")

            let task = session.downloadTask(with: request) { [self] (tempLocalUrl, response, error) in
            
                if let error = error  {
                    log.error("Error took place while downloading a file. Error description: \(error.localizedDescription)" )
                    return
                }
                
                guard let tempLocalUrl = tempLocalUrl else {
                    log.error("Error file dodn't dowloaded. tempLocalUrl == nil" )
                    return
                }
            
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    log.trace("Successfully downloaded. Status code: \(statusCode)")
                }
                    
                do {
                    
                    // try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    if let url =  try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl) {
                        
                        self.document = PDFDocument(url: url)
                        
                        DispatchQueue.main.async {
                            log.trace( "result url: \(url)")
                            self.downloadedUrl = url
                            self.downloadedItem = true
                        }
                    }

                } catch (let writeError) {
                    log.error("Error creating a file \(destinationFileUrl) : \(writeError.localizedDescription)")
                }
                    

            }
            task.resume()
 
        }
        catch {
            log.error( "download error \(error.localizedDescription)")
        }
    }
}
