//
//  PotentialMatesListCell.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/2/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//

import UIKit
import AlamofireImage

class PotentialMatesListCell: UITableViewCell {
    
    static let cellID = "potential-mates-list-cell"
    
    var mate: PotentialMate? {
        didSet { handleSetMate() }
    }
    
    // ideal cell height
    static var cellHeight: CGFloat { return profPicDim + 2 * profPicVertMargins }
    
    // static consts
    private static let profPicDim: CGFloat = 70
    private static let profPicVertMargins: CGFloat = 14
    private static let contentHorSpacing: CGFloat = 18
    private static var placeHolderImage: UIImage = { StarWarsConsts.emptyColor.asPixel() }()
    
    // child views
    private let profPicView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // add profile pic
        addSubview(profPicView)
        profPicView.contentMode = .scaleAspectFill
        profPicView.translatesAutoresizingMaskIntoConstraints = false
        profPicView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profPicView.widthAnchor.constraint(equalToConstant: PotentialMatesListCell.profPicDim).isActive = true
        profPicView.heightAnchor.constraint(equalToConstant: PotentialMatesListCell.profPicDim).isActive = true
        profPicView.leadingAnchor.constraint(equalTo: self.readableContentGuide.leadingAnchor).isActive = true
        profPicView.layer.cornerRadius = PotentialMatesListCell.profPicDim / 2
        profPicView.clipsToBounds = true
        
        profPicView.image = PotentialMatesListCell.placeHolderImage
        
        // add name label
        addSubview(nameLabel)
        nameLabel.textColor = StarWarsConsts.primaryTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profPicView.trailingAnchor, constant: PotentialMatesListCell.contentHorSpacing).isActive = true
        
        // set selection color
        let bgView = UIView()
        bgView.backgroundColor = StarWarsConsts.emptyColor
        self.selectedBackgroundView = bgView;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleSetMate() {
        if let mate = mate {
            nameLabel.text = mate.fullName
            if let imgURL = URL(string: mate.profilePicture) {
                
                // TODO: investigate AlamofireImage's cache settings. Chewy takes a long time to load even when it should be coming from cache
                
                profPicView.af_setImage(withURL: imgURL,
                                        placeholderImage: PotentialMatesListCell.placeHolderImage,
                                        imageTransition: .crossDissolve(0.25),
                                        runImageTransitionIfCached: false)
            } else {
                profPicView.image = PotentialMatesListCell.placeHolderImage
            }
        } else {
            profPicView.image = PotentialMatesListCell.placeHolderImage
            nameLabel.text = nil
        }
    }

}
