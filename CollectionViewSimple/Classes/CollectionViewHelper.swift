//
//  CollectionViewHelper.swift
//  Pods
//
//  Created by Bhupendra Singh on 2017/07/15.
//
//

import UIKit

private struct AssociatedObjectKey {
    static var registeredUseables = "registeredUseables"
}

public protocol NibLoadable: class {
    static var nib: UINib { get }
}

public extension NibLoadable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

public extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Nib \(nib) not found for type \(self)")
        }
        return view
    }
}

public protocol NibOwnerLoadable: class {
    static var nib: UINib { get }
}

public extension NibOwnerLoadable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

public extension NibOwnerLoadable where Self: UIView {
    func loadNibContent() {
        let layoutAttributes: [NSLayoutAttribute] = [.top, .leading, .bottom, .trailing]
        for view in Self.nib.instantiate(withOwner: self, options: nil) {
            if let view = view as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(view)
                layoutAttributes.forEach { attribute in
                    self.addConstraint(NSLayoutConstraint(item: view,
                                                          attribute: attribute,
                                                          relatedBy: .equal,
                                                          toItem: self,
                                                          attribute: attribute,
                                                          multiplier: 1,
                                                          constant: 0.0))
                }
            }
        }
    }
}

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

public typealias NibReusable = Reusable & NibLoadable

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib? {
        let name = String(describing: self)
        var nibFound = false
        nibFound = Bundle(for: self).path(forResource: name, ofType: "xib") != nil
        if nibFound == false {
            nibFound = Bundle(for: self).path(forResource: name, ofType: "nib") != nil
        }
        guard nibFound else {
            return nil
        }
        return UINib(nibName: name, bundle: Bundle(for: self)) 
    }
}

extension UICollectionReusableView: Reusable {
    
}

public extension UICollectionView {
    
    
    /// This registeredCells is to keep track of cell is registered before dequeuing it.
    /// registerReusableCellIfNeeded uses this to register cell if not registered before any dequeue happens on same cell in dequeueReusableCell
    private var registeredUseables: Set<String> {
        get {
            if let registeredUseables = objc_getAssociatedObject(self, &AssociatedObjectKey.registeredUseables) as? Set<String> {
                return registeredUseables
            }
            let registeredUseables = Set<String>()
            self.registeredUseables = registeredUseables
            return registeredUseables
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.registeredUseables, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    /// This is will register cell if cell is not registered
    /// - Parameter _: CellType
    final func registerReusableIfNeeded<T: UICollectionReusableView>(_: T.Type) {
        guard !registeredUseables.contains(T.reuseIdentifier) else { return }
        registeredUseables.insert(T.reuseIdentifier)
        if let nib = T.nib {
            register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    final func registerReusableHeaderIfNeeded<T: UICollectionReusableView>(_: T.Type, kind: String) {
        guard !registeredUseables.contains(T.reuseIdentifier) else { return }
        registeredUseables.insert(T.reuseIdentifier)
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
        }
    }

    final func register<T: UICollectionViewCell>(cellType: T.Type)
        where T: Reusable & NibLoadable {
            self.register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    final func register<T: UICollectionViewCell>(cellType: T.Type)
        where T: Reusable {
            self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
        where T: Reusable {
            registerReusableIfNeeded(T.self)

            let bareCell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
            guard let cell = bareCell as? T else {
                fatalError(
                    "Failed to dequeue a cell for identifier \(cellType.reuseIdentifier), type \(cellType.self). "
                        + "is reuseIdentifier is set properly in XIB/Storyboard? or cell registered"
                )
            }
            return cell
    }

    final func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String)
        where T: Reusable & NibLoadable {
            self.register(
                supplementaryViewType.nib,
                forSupplementaryViewOfKind: elementKind,
                withReuseIdentifier: supplementaryViewType.reuseIdentifier
            )
    }

    final func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String)
        where T: Reusable {
            self.register(
                supplementaryViewType.self,
                forSupplementaryViewOfKind: elementKind,
                withReuseIdentifier: supplementaryViewType.reuseIdentifier
            )
    }

    final func dequeueReusableSupplementaryView<T: UICollectionReusableView>
        (ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T
        where T: Reusable {
            self.registerReusableHeaderIfNeeded(T.self, kind: elementKind)
            let reuseIdentifier = T.reuseIdentifier
            if reuseIdentifier.characters.count > 0 {
                
            }
            let view = self.dequeueReusableSupplementaryView(
                ofKind: elementKind,
                withReuseIdentifier: T.reuseIdentifier,
                for: indexPath
            )
            guard let typedView = view as? T else {
                fatalError(
                    "Failed to dequeue a supplementary view for identifier \(viewType.reuseIdentifier) "
                        + " type \(viewType.self). "
                        + "is reuseIdentifier is set in XIB/Storyboard? or suppplementary view registered? "
                )
            }
            return typedView
    }
}
