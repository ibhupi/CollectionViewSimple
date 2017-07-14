//
//  CollectionViewDataSourceDelegate.swift
//  Pods
//
//  Created by Bhupendra Singh on 2017/07/15.
//
//

import UIKit

public extension UICollectionView {
    convenience init(dataSourceDelegate: CollectionViewDataSourceDelegate, layout: UICollectionViewFlowLayout) {
        self.init(frame: .zero, collectionViewLayout: layout)
        self.dataSource = dataSourceDelegate
        self.delegate = dataSourceDelegate
    }
}

public typealias CollectionViewCellForIndexPathClosure = (IndexPath) -> (class: UICollectionViewCell.Type, configure: (UICollectionViewCell) -> Void)

public class CollectionViewDataSourceDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let rowsOrColumns: Int
    let cellForIndexPathClosure: CollectionViewCellForIndexPathClosure

    public var numberOfSectionsClosure = { return 1 }
    public var numberOfRowsInSectionClosure = { (_: Int) -> Int in return 0 }
    public var didSelectClosure:  ((IndexPath) -> Void)?

    private var registeredCell = [String]()

    public init(rowsOrColumns: Int,
         cellForIndexPathClosure: @escaping (IndexPath) -> (UICollectionViewCell.Type, (UICollectionViewCell) -> Void)) {
        self.rowsOrColumns = rowsOrColumns
        self.cellForIndexPathClosure = cellForIndexPathClosure
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSectionsClosure()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfRowsInSectionClosure(section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = self.cellForIndexPathClosure(indexPath)
        if !self.registeredCell.contains(value.class.reuseIdentifier) {
            collectionView.register(cellType: value.class)
        }
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: value.class)
        value.configure(cell)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.didSelectClosure?(indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var frame = UIEdgeInsetsInsetRect(collectionView.frame, collectionView.contentInset)
        let rowsOrColumns = self.rowsOrColumns
        var widthOrHeight = collectionView.frame.width / CGFloat(rowsOrColumns)

        if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            if collectionViewLayout.scrollDirection == .horizontal {
                frame.size.height -= CGFloat(rowsOrColumns - 1) * collectionViewLayout.minimumInteritemSpacing
                frame.size.width -= CGFloat(rowsOrColumns - 1) * collectionViewLayout.minimumLineSpacing
                widthOrHeight = frame.height / CGFloat(rowsOrColumns)
            } else {
                frame.size.width -= CGFloat(rowsOrColumns - 1) * collectionViewLayout.minimumInteritemSpacing
                frame.size.height -= CGFloat(rowsOrColumns - 1) * collectionViewLayout.minimumLineSpacing
                widthOrHeight = frame.width / CGFloat(rowsOrColumns)
            }
        }

        return CGSize(width: widthOrHeight, height: widthOrHeight)
    }
}
