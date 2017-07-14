//
//  ViewController.swift
//  CollectionViewSimple
//
//  Created by Bhupendra Singh on 07/15/2017.
//  Copyright (c) 2017 Bhupendra Singh. All rights reserved.
//

import UIKit
import CollectionViewSimple

class ViewController: UIViewController {
    var collectionView: UICollectionView?
    var dataSource: CollectionViewDataSourceDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataSource = self.makeItemCollectionViewDataSourceDelegate()
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(dataSourceDelegate: dataSource, layout: layout)
        self.view.addSubview(collectionView)
        self.dataSource = dataSource
        self.collectionView = collectionView
    }

    private func makeItemCollectionViewDataSourceDelegate() -> CollectionViewDataSourceDelegate {
        let displayItems = self.makeIndexes()
        let cellForIndexPathClosure: CollectionViewCellForIndexPathClosure = { (indexPath) -> (UICollectionViewCell.Type, (UICollectionViewCell) -> Void) in
            let cellType = TitleCollectionViewCell.self
            return (cellType, { (cell: UICollectionViewCell) -> Void in
                if let cell = cell as? TitleCollectionViewCell {
                    let displayItem = displayItems[indexPath.row]
                    cell.configureFor(displayItem)
                }
            })
        }

        let dataSource = CollectionViewDataSourceDelegate(rowsOrColumns: 6,
                                                          cellForIndexPathClosure: cellForIndexPathClosure)

        dataSource.numberOfRowsInSectionClosure = { (section) in
            return displayItems.count
        }
        dataSource.didSelectClosure = { indexPath in

        }
        return dataSource
    }

    private func makeIndexes() -> [String] {
        var items = [String]()
        for index in 0...1000 {
            items.append("\(index)")
        }
        return items
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let collectionView = self.collectionView {
            collectionView.frame = self.view.bounds
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

