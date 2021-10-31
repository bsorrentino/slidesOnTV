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
    
    class Coordinator: NSObject {
        var document: PDFDocument
        
        init( document: PDFDocument ) {
            self.document = document
        }
        
    }
    
    var document : PDFDocument
    
    func makeCoordinator() -> Coordinator {
        return Coordinator( document:document )
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFThumbnailsView>) -> UIViewControllerType {
        
        let controller = PDFThumbnailsViewController.of( document: document, coordinator:context.coordinator )
        
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<PDFThumbnailsView>) {
    
    }
    
}


public class PDFThumbnailsViewController : UITableViewController  {
        
    var document:PDFDocument
    
    static func of<C>( document:PDFDocument, coordinator:C ) -> PDFThumbnailsViewController where C:UITableViewDelegate & UITableViewDataSource {
        
        let result = PDFThumbnailsViewController(document:document)
        
        //result.tableView.rowHeight =  UITableView.automaticDimension
        //result.tableView.estimatedRowHeight = UITableView.automaticDimension
        //tableView.separatorStyle = .none
        result.tableView.allowsSelection = false
        result.tableView.allowsSelectionDuringEditing = false
        result.tableView.allowsMultipleSelectionDuringEditing = false

        result.tableView.dataSource = coordinator
        result.tableView.delegate = coordinator
        
        return result

    }
    
    
    internal init(document: PDFDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

// MARK: Coordinator (UITableViewDelegate)
extension PDFThumbnailsView.Coordinator: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         100 //UITableView.automaticDimension
            }

}

// MARK: Coordinator (UITableViewDataSource)
extension PDFThumbnailsView.Coordinator: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         document.pageCount
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier:  nil)

//        var cellConfiguration = UIListContentConfiguration.cell()
//        cellConfiguration.image = UIImage(systemName: "doc.fill")
//        // cellConfiguration.image = document.pdfPageImage(at: indexPath.item + 1)
//        cellConfiguration.text = "page \(indexPath.item)"
//        cell.contentConfiguration = cellConfiguration

        //let view = UIImageView(image: document.pdfPageImage(at: indexPath.item + 1))
        let view = UIImageView(image: UIImage(systemName: "doc.fill"))
        view.contentMode = .scaleAspectFit
        view.frame.size = CGSize( width: 100, height: 100)
        cell.contentView.addSubview( view )
        
        
        
        return cell
    }
    
    
}


struct PDFThumbnailsView_Previews: PreviewProvider {
    
    static var sampleFileUrl:URL? {
        Bundle.main.url(forResource: "sample", withExtension: "pdf")
    }

    static var document:PDFDocument? {
        guard let url = sampleFileUrl else {
            return nil
        }
        
        return PDFDocument( url: url)
    }

    static var previews: some View {
        Group {
            VStack {
                //Text( sampleFileUrl?.absoluteString ?? "'sample.pdf' not found" )
                //Text( "\(document?.pageCount ?? 0)" )
                PDFThumbnailsView( document:document! )
                //Text( "\(document?.pageCount ?? 0)" )

            }

        }
    }
}
