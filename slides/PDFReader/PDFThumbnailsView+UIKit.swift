//
//  SwiftUIView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 21/10/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct PDFThumbnailsViewUIKit : UIViewControllerRepresentable , Equatable {
    
    static func == (lhs: PDFThumbnailsViewUIKit, rhs: PDFThumbnailsViewUIKit) -> Bool {
        
        // print( "Equatable \(lhs.pageSelected) - \(rhs.pageSelected)")
        return lhs.pageSelected == rhs.pageSelected
    }
        
    typealias UIViewControllerType = PDFThumbnailsViewController
    
    //
    // Coordinator
    //
    class Coordinator: NSObject {
        var view: PDFThumbnailsViewUIKit
        
        var cellHeight:CGFloat {
            view.parentSize.height * 0.25
        }
        
        init( _ view: PDFThumbnailsViewUIKit ) {
            self.view = view
        }
        
    }
    
    //
    // Custom Cell
    //
    // inspired by https://medium.com/@Archetapp/sizing-uitableview-cells-to-fit-images-swift-in-xcode-13228d139c1a
    //
    class Cell : UITableViewCell {
    
        var mainImageView : UIImageView  = {
            var imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            return imageView
        }()

        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            self.contentView.addSubview(mainImageView)
            self.selectionStyle = .default
            
            mainImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            mainImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            mainImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
//            self.layer.borderWidth = 1
//            self.layer.borderColor = UIColor.red.cgColor

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    var document:PDFDocument
    @Binding var pageSelected: Int
    var parentSize:CGSize

    func makeCoordinator() -> Coordinator {
        return Coordinator( self )
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFThumbnailsViewUIKit>) -> UIViewControllerType {
        // print("makeUIViewController")
        
        let controller = PDFThumbnailsViewController(document:document)

        controller.tableView.register( PDFThumbnailsViewUIKit.Cell.self, forCellReuseIdentifier: "cell")
        //controller.tableView.rowHeight =  UITableView.automaticDimension
        //controller.tableView.estimatedRowHeight = UITableView.automaticDimension
        //controller.tableView.separatorStyle = .singleLine
        controller.tableView.allowsSelection = true
        controller.tableView.allowsSelectionDuringEditing = false
        controller.tableView.allowsMultipleSelectionDuringEditing = false

        controller.tableView.remembersLastFocusedIndexPath = true
        controller.tableView.dataSource = context.coordinator
        controller.tableView.delegate = context.coordinator
        
//        controller.tableView.layer.borderWidth = 1
//        controller.tableView.layer.borderColor = UIColor.red.cgColor

        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<PDFThumbnailsViewUIKit>) {
        // print("updateUIViewController")
    }
    
}

public class PDFThumbnailsViewController : UITableViewController  {
        
    var document:PDFDocument
    
    internal init(document: PDFDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}

// MARK: Coordinator (UITableViewDelegate)
extension PDFThumbnailsViewUIKit.Coordinator: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        self.cellHeight  //UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //this runs anytime we move up or down the table view
        
        guard  let next = context.nextFocusedIndexPath else {
            print ("not browsing the table")
            return
        }
     
        //use that number to populate something else probably according to the category.
        print ( "next \(next.item)" )
        
        self.view.pageSelected = next.item + 1
     
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print( "didSelectRowAt: \(indexPath.item)")
//    }
//
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        //this runs on press
//        print ( "Did Highlight Row At: \(indexPath.item)" )
//    }
     
//    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
//        print( "canFocusRowAt \(indexPath.item)" )
//        return true
//    }
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        print( "indexPathForPreferredFocusedView" )
        return IndexPath( item: view.pageSelected - 1, section: 0)
    }

//    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
//        print( "shouldUpdateFocusIn \(String(describing: context.nextFocusedItem))" )
//        return true
//    }
}

// MARK: Coordinator (UITableViewDataSource)
extension PDFThumbnailsViewUIKit.Coordinator: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.view.document.pageCount
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PDFThumbnailsViewUIKit.Cell else {
            return UITableViewCell()
        }

        cell.mainImageView.image = self.view.document.pdfPageImage(at: indexPath.item + 1)
                
        return cell
    }
    
    
}


struct PDFThumbnailsViewUIKit_Previews: PreviewProvider {
    
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
        GeometryReader { geom in
        VStack {
                //Text( sampleFileUrl?.absoluteString ?? "'sample.pdf' not found" )
                //Text( "\(document?.pageCount ?? 0)" )
                HStack {
                    Spacer()
                    PDFThumbnailsViewUIKit( document:document!, pageSelected:.constant(1), parentSize: geom.size )
                        .frame( width: geom.size.width * 0.2, height: geom.size.height - 1)
                    Spacer()
                }
                //Text( "\(document?.pageCount ?? 0)" )

            }
        }
    }
}
