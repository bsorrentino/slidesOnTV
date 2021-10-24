//
//  SwiftUIView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 21/10/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct PDFThumbnailsView : UIViewControllerRepresentable {
        
    typealias UIViewControllerType = PDFThumbnailsViewController
    
    class Coordinator: NSObject, UITableViewDelegate {
        
    }
    
    var document : PDFDocument
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFThumbnailsView>) -> UIViewControllerType {
        
        let controller = PDFThumbnailsViewController( document: document )
        
        controller.tableView.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<PDFThumbnailsView>) {
    
    }
    
}




public class PDFThumbnailsViewController : UIViewController  {
        
    var document:PDFDocument
    
    fileprivate var tableView: UITableView! {
       didSet {
         tableView.dataSource = self
         //tableView.delegate = self
         // tableView.tableFooterView = UIView(frame: CGRect.zero)
         // tableView.backgroundColor = .black
         view.addSubview(tableView)
       }
    }
    
    internal init(document: PDFDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}


// MARK: PDFThumbnailsView (UITableViewDataSource)
extension PDFThumbnailsViewController : UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document.pageCount
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
