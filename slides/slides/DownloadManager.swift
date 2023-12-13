//
//  DownloadManager.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine
import PDFReader

class DownloadManager<T> : ObservableObject where T: SlideItem {
    private typealias DownloadCheckedContinuation = CheckedContinuation<Bool, Never>
    
    typealias Progress = (Double,TimeInterval?)
    
    @Published var downloadProgress:Progress = (0,0)

    private var downloadingItemId:String?
    private(set) var downloadedDocument:PDFDocument?
    private(set) var downdloadedItem:T?

    private var downloadTask:URLSessionDownloadTask?
    private var observation:NSKeyValueObservation?
    private var subscriptions = Set<AnyCancellable>()
   
    internal var bag = Set<AnyCancellable>()
    
    var downloadingDescription:String {
        guard downloadProgress.0 > 0 else { return "" }
        
        let perc = Int(downloadProgress.0 * 100)
        
        let result = "\(perc)%"
        
        if let time = downloadProgress.1 {
            return "\(result) - \(time)"
        }
        return result

    }
    
    func isDownloading( item:T ) -> Bool {
        
        guard let id = downloadingItemId, downloadProgress.0 < 1, id==item.id else {
            return false
        }
        return true
    }
    
    @MainActor private func reset( _ item: T )  {
    
        if let task = self.downloadTask {
            task.cancel()
            self.observation        = nil
//            self.downloadingItemId  = nil
            self.downloadedDocument = nil
            self.downdloadedItem    = nil
        }
        
        self.downloadProgress   = (0,0)
        self.downloadingItemId  = item.id
    }
    
    
    func download( item: T ) async -> Bool {
        await reset( item );
        
        return await withCheckedContinuation { (continuation ) in
            
            guard let downloadURL = item.downloadUrl else {
                continuation.resume(returning: false)
                return
            }
            
            let request = URLRequest(url:downloadURL)
            
            let session = URLSession(configuration: URLSessionConfiguration.default)

            do {
                                
                let destinationFileUrl =
                    try FileManager().url(for: .cachesDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: false).appendingPathComponent("presentation.pdf")
                
                
                
                self.downloadTask = session.downloadTask(with: request) { [self] (tempLocalUrl, response, error) in
                    
                    if let error = error  {
                        log.error("Error took place while downloading a file. Error description: \(error.localizedDescription)" )
                        continuation.resume(returning: false)
                        return
                    }
                    
                    guard let tempLocalUrl = tempLocalUrl else {
                        log.error("Error file dodn't dowloaded. tempLocalUrl == nil" )
                        continuation.resume(returning: false)
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        log.error("HTTP Error: invalid response" )
                        continuation.resume(returning: false)
                        return

                    }
                    
                    guard response.statusCode < 400 else  {
                        log.error("HTTP Error status code \(response.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))" )
                        continuation.resume(returning: false)
                        return
                    }
                    
                    do {
                        
                        // try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        if let url =  try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl) {
                            
                            self.downloadedDocument = PDFDocument(url: url)
                            self.downdloadedItem = item
                            
                            continuation.resume(returning: true)
                            return
                            
                        }
                        
                    } catch (let writeError) {
                        log.error("Error creating a file \(destinationFileUrl) : \(writeError.localizedDescription)")
                        continuation.resume(returning: false)
                        return
                    }
                    
                    
                }
                
                guard let task = downloadTask else {
                    log.error("Error creating downloadTask")
                    continuation.resume(returning: false)
                    return

                }
                
                observation = task.progress.observe(\.fractionCompleted ) { observationProgress, _ in
                    Task {
                        await MainActor.run {
                            self.downloadProgress = ( observationProgress.fractionCompleted, observationProgress.estimatedTimeRemaining)
                        }
                    }
                }
                
                task.resume()
                
            }
            catch {
                log.error( "download error \(error.localizedDescription)")
                continuation.resume(returning: false)
                return
            }

        }
        
    }

}


