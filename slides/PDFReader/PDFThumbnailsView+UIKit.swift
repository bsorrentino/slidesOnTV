//
//  SwiftUIView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 21/10/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI


public class PDFThumbnailsView : UIViewController  {
    
    fileprivate var tableView: UITableView! {
       didSet {
         tableView.delegate = self
         tableView.dataSource = self
         tableView.tableFooterView = UIView(frame: CGRect.zero)
         tableView.backgroundColor = .black
         view.addSubview(tableView)
       }
    }
}

// MARK: PDFThumbnailsView (UITableViewDelegate)
extension PDFThumbnailsView : UITableViewDelegate {
    
}

// MARK: PDFThumbnailsView (UITableViewDataSource)
extension PDFThumbnailsView : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}



struct SwiftUIView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
