//
//  DownloadManager.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

class DownloadManager<T> : ObservableObject where T: SlideItem {
    
    typealias Progress = (Double,TimeInterval?)
    
    @Published var downloadProgress:Progress?

    
    private var itemId:String?
    private(set) var downloadedDcument:PDFDocument?
    private(set) var downdloadedItem:T?

    private var downloadTask:URLSessionDownloadTask?
    private var observation:NSKeyValueObservation?
    private var subscriptions = Set<AnyCancellable>()
   
    internal var bag = Set<AnyCancellable>()
    
    var downloadingDescription:String {
        guard let progress = downloadProgress else { return "" }
        
        let perc = Int(progress.0 * 100)
        
        let result = "\(perc)%"
        
        if let time = progress.1 {
            return "\(result) - \(time)"
        }
        return result

    }
    func isDownloading( item:T ) -> Bool {
        guard let id = itemId, let progress = downloadProgress, progress.0 < 1, id==item.id else {
            return false
        }
        return true
    }
    
    private func reset() {
        downloadProgress = nil
        
        if let task = downloadTask {
            task.cancel()
            observation = nil
            itemId = nil
            downloadedDcument = nil
            downdloadedItem = nil
        }
    }
    
    
    func download( item: T, completionHandler: @escaping (Bool) -> Void )  {
        
        guard let downloadURL = item.downloadUrl else {
            return
        }
        
        reset()
        
        do {
            
            let request = URLRequest(url:downloadURL)
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let destinationFileUrl =
                try FileManager().url(for: .cachesDirectory,
                                      in: .userDomainMask,
                                      appropriateFor: nil,
                                      create: false).appendingPathComponent("presentation.pdf")
            
            self.itemId = item.id
            
            downloadTask = session.downloadTask(with: request) { [self] (tempLocalUrl, response, error) in
                
                if let error = error  {
                    log.error("Error took place while downloading a file. Error description: \(error.localizedDescription)" )
                    return
                }
                
                guard let tempLocalUrl = tempLocalUrl else {
                    log.error("Error file dodn't dowloaded. tempLocalUrl == nil" )
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    log.error("HTTP Error: invalid response" )
                    return

                }
                
                guard response.statusCode < 400 else  {
                    log.error("HTTP Error status code \(response.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))" )
                    return
                }
                
                do {
                    
                    // try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    if let url =  try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl) {
                        
                        self.downloadedDcument = PDFDocument(url: url)
                        self.downdloadedItem = item
                        
                        DispatchQueue.main.async {
                            completionHandler( true )
                        }
                    }
                    
                } catch (let writeError) {
                    log.error("Error creating a file \(destinationFileUrl) : \(writeError.localizedDescription)")
                }
                
                
            }
            
            observation = downloadTask?.progress.observe(\.fractionCompleted ) { observationProgress, _ in
                DispatchQueue.main.async { [self] in
                    downloadProgress = ( observationProgress.fractionCompleted, observationProgress.estimatedTimeRemaining)
                }
            }
            
            downloadTask?.resume()
            
        }
        catch {
            log.error( "download error \(error.localizedDescription)")
        }
    }
}


