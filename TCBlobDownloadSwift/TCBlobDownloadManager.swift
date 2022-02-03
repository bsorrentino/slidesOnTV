//
//  TCBlobDownloadManager.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public let kTCBlobDownloadSessionIdentifier = "tcblobdownloadmanager_downloads"

public let kTCBlobDownloadErrorDomain = "com.tcblobdownloadswift.error"
public let kTCBlobDownloadErrorDescriptionKey = "TCBlobDownloadErrorDescriptionKey"
public let kTCBlobDownloadErrorHTTPStatusKey = "TCBlobDownloadErrorHTTPStatusKey"
public let kTCBlobDownloadErrorFailingURLKey = "TCBlobDownloadFailingURLKey"

public enum TCBlobDownloadError: Int {
    case tcBlobDownloadHTTPError = 1
}

open class TCBlobDownloadManager {
    /**
        A shared instance of `TCBlobDownloadManager`.
    */
    public static let sharedInstance = TCBlobDownloadManager()

    /// Instance of the underlying class implementing `NSURLSessionDownloadDelegate`.
    fileprivate let delegate: DownloadDelegate

    /// If `true`, downloads will start immediatly after being created. `true` by default.
    open var startImmediatly = true

    /// The underlying `NSURLSession`.
    public let session: URLSession

    /**
        Custom `NSURLSessionConfiguration` init.

        :param: config The configuration used to manage the underlying session.
    */
    public init(config: URLSessionConfiguration) {
        self.delegate = DownloadDelegate()
        self.session = URLSession(configuration: config, delegate: self.delegate, delegateQueue: nil)
        self.session.sessionDescription = "TCBlobDownloadManger session"
    }

    /**
        Default `NSURLSessionConfiguration` init.
    */
    public convenience init() {
        let config = URLSessionConfiguration.default
        //config.HTTPMaximumConnectionsPerHost = 1
        self.init(config: config)
    }

    /**
        Base method to start a download, called by other download methods.
    
        :param: download Download to start.
    */
    fileprivate func downloadWithDownload(_ download: TCBlobDownload) -> TCBlobDownload {
        self.delegate.downloads[download.downloadTask.taskIdentifier] = download

        if self.startImmediatly {
            download.downloadTask.resume()
        }

        return download
    }

    /**
        Start downloading the file at the given URL.
    
        :param: url NSURL of the file to download.
        :param: directory Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        :param: name Name to give to the file once the download is completed.
        :param: delegate An eventual delegate for this download.

        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileAtURL(_ url: URL, toDirectory directory: URL?, withName name: String?, andDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(with: url)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, delegate: delegate)

        return self.downloadWithDownload(download)
    }

    /**
        Start downloading the file at the given URL.

        :param: url NSURL of the file to download.
        :param: directory Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        :param: name Name to give to the file once the download is completed.
        :param: progression A closure executed periodically when a chunk of data is received.
        :param: completion A closure executed when the download has been completed.

        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileAtURL(_ url: URL, toDirectory directory: URL?, withName name: String?, progression: progressionHandler?, completion: completionHandler?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(with: url)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, progression: progression, completion: completion)

        return self.downloadWithDownload(download)
    }

    /**
        Resume a download with previously acquired resume data.
    
        :see: `TCBlobDownload -cancelWithResumeData:` to produce this data.

        :param: resumeData Data blob produced by a previous download cancellation.
        :param: directory Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        :param: name Name to give to the file once the download is completed.
        :param: delegate An eventual delegate for this download.
    
        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileWithResumeData(_ resumeData: Data, toDirectory directory: URL?, withName name: String?, andDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(withResumeData: resumeData)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, delegate: delegate)

        return self.downloadWithDownload(download)
    }

    /**
        Gets the downloads in a given state currently being processed by the instance of `TCBlobDownloadManager`.
    
        :param: state The state by which to filter the current downloads.
        
        :return: An `Array` of all current downloads with the given state.
    */
    open func currentDownloadsFilteredByState(_ state: URLSessionTask.State?) -> [TCBlobDownload] {
        var downloads = [TCBlobDownload]()

        // TODO: make functional as soon as Dictionary supports reduce/filter.
        for download in self.delegate.downloads.values {
            if state == nil || download.downloadTask.state == state {
                downloads.append(download)
            }
        }

        return downloads
    }
}


class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    var downloads: [Int: TCBlobDownload] = [:]
    //let acceptableStatusCodes: CountableRange<Int> = 200...299
    let acceptableStatusCodes = 200...299

    func validateResponse(_ response: HTTPURLResponse) -> Bool {        
        return acceptableStatusCodes.contains(response.statusCode)
    }

    // MARK: NSURLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Resume at offset: \(fileOffset) total expected: \(expectedTotalBytes)")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let download = self.downloads[downloadTask.taskIdentifier]!
        let progress = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? -1 : Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        download.progress = progress

        DispatchQueue.main.async {
            download.delegate?.download(download, didProgress: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            download.progression?(progress, totalBytesWritten, totalBytesExpectedToWrite)
            return
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let download = self.downloads[downloadTask.taskIdentifier]!
        var resultingURL: NSURL?

        let fm = FileManager.default
        
        do {
            
            try fm.replaceItem(at:                  download.destinationURL as URL,
                               withItemAt:          location,
                               backupItemName:      nil,
                               options:             FileManager.ItemReplacementOptions.usingNewMetadataOnly,
                               resultingItemURL:    &resultingURL)
            
            download.resultingURL = resultingURL as URL?
            
        } catch let fileError as NSError {
            
            download.error = fileError
        
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError sessionError: Error?) {
        let download = self.downloads[task.taskIdentifier]!
        var error: NSError? = sessionError as NSError?? ?? download.error
        // Handle possible HTTP errors
        if let response = task.response as? HTTPURLResponse {
            // NSURLErrorDomain errors are not supposed to be reported by this delegate
            // according to https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
            // so let's ignore them as they sometimes appear there for now. (But WTF?)
            if !validateResponse(response) && (error == nil || error!.domain == NSURLErrorDomain) {
                error = NSError(domain: kTCBlobDownloadErrorDomain,
                    code: TCBlobDownloadError.tcBlobDownloadHTTPError.rawValue,
                    userInfo: [kTCBlobDownloadErrorDescriptionKey: "Erroneous HTTP status code: \(response.statusCode)",
                               kTCBlobDownloadErrorFailingURLKey: task.originalRequest!.url!,
                               kTCBlobDownloadErrorHTTPStatusKey: response.statusCode])
            }
        }

        // Remove the reference to the download
        self.downloads.removeValue(forKey: task.taskIdentifier)

        DispatchQueue.main.async {
            download.delegate?.download(download, didFinishWithError: error, atLocation: download.resultingURL)
            download.completion?(error, download.resultingURL)
            return
        }
    }
}
