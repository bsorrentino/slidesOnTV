import UIKit

// Browse your icloud container to find the file you want
let mainUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
print( "mainUrl: \(String(describing: mainUrl)" )
if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") ) {
    print("icloudFolderURL: \(icloudFolderURL)")
    if let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
        print("urls: \(urls)")
        // Here select the file url you are interested in
        if let myURL = urls.first {
            // We have the url we want to download into myURL variable
            print("myURL: \(myURL)")
        }
    }

}


