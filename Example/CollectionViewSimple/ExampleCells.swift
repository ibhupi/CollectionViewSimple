//
//  ExampleCells.swift
//  CollectionViewSimple
//
//  Created by Bhupendra Singh on 2017/07/15.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupOnce()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupOnce()
    }

    private func setupOnce() {
        self.contentView.layer.borderWidth = 1 / UIScreen.main.scale
        self.contentView.backgroundColor = .white
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.addSubview(self.label)
        self.label.numberOfLines = 0
        self.label.font = UIFont.systemFont(ofSize: 10)
        self.label.textColor = .gray
        self.label.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.contentView.bounds
        frame.origin.y = frame.height - 20
        frame.size.height = 20
        self.label.frame = frame
    }

    override func prepareForReuse() {
        self.label.text = nil
    }

    func configureFor(_ string: String) {
        self.label.text = string
    }
}

class RedCollectionViewCell: TitleCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .red
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GreenCollectionViewCell: TitleCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .green
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlueCollectionViewCell: TitleCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .blue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
