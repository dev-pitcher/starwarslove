//
//  PotentialMateDetailsController
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/2/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//
//  PotentialMateDetailsController shows details for a single PotentialMate.

import UIKit

class PotentialMateDetailsController: UIViewController {
    
    private let mate: PotentialMate
    
    let scroll = UIScrollView()
    let profPicView = UIImageView()
    let closeBtn = UIButton()
    let winkyLab = UILabel()
    
    // scroll contents
    let contentView = UIView()
    let nameLabel = UILabel()
    let detailsLabel = UILabel()
    let winkyButton = UIButton()
    
    private let winkyFeedback = UINotificationFeedbackGenerator()
    
    private var profPicAspect: CGFloat = 1
    
    private static var placeHolderImage: UIImage = { StarWarsConsts.emptyColor.asPixel() }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    init(with mate: PotentialMate) {
        self.mate = mate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        // add scroll
        self.view.addSubview(scroll)
        scroll.alwaysBounceVertical = true
        scroll.delaysContentTouches = false
        scroll.delegate = self
        
        // add profile pic
        self.view.addSubview(profPicView)
        profPicView.contentMode = .scaleAspectFill
        profPicView.clipsToBounds = true
        if let imgURL = URL(string: mate.profilePicture) {
            profPicView.af_setImage(withURL: imgURL,
                                    placeholderImage: PotentialMateDetailsController.placeHolderImage,
                                    imageTransition: .crossDissolve(0.25),
                                    runImageTransitionIfCached: false)
        }
        
        // add winky label
        profPicView.addSubview(winkyLab)
        winkyLab.text = "😉"
        winkyLab.font = UIFont.systemFont(ofSize: 90)
        winkyLab.sizeToFit()
        winkyLab.alpha = 0 // hidden until user taps winky button
        
        // add close button
        let closeBtnDim: CGFloat = 44
        self.view.addSubview(closeBtn)
        closeBtn.setImage(UIImage(imageLiteralResourceName: "baseline_cancel_black_36pt"), for: [])
        closeBtn.tintColor = UIColor.white.withAlphaComponent(0.8)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 2).isActive = true
        closeBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
        closeBtn.widthAnchor.constraint(equalToConstant: closeBtnDim).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: closeBtnDim).isActive = true
        
        closeBtn.addTarget(self, action: #selector(onCloseBtn), for: .touchUpInside)
        
        // add content view
        scroll.addSubview(contentView)
        contentView.backgroundColor = .white
        
        // add name label
        contentView.addSubview(nameLabel)
        nameLabel.text = mate.fullName
        nameLabel.textColor = StarWarsConsts.primaryTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        nameLabel.sizeToFit()
        
        // add details label
        contentView.addSubview(detailsLabel)
        detailsLabel.text = self.detailsText
        detailsLabel.textColor = StarWarsConsts.secondaryTextColor
        detailsLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        detailsLabel.numberOfLines = 0
        
        // add winky button
        contentView.addSubview(winkyButton)
        winkyButton.setTitle("Send a wink", for: [])
        winkyButton.setTitleColor(.white, for: [])
        winkyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        winkyButton.setBackgroundImage(UIColor.black.asPixel(), for: .normal)
        winkyButton.setBackgroundImage(UIColor.black.withAlphaComponent(0.5).asPixel(), for: .highlighted)
        winkyButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        winkyButton.sizeToFit()
        winkyButton.layer.cornerRadius = winkyButton.bounds.size.height / 2
        winkyButton.clipsToBounds = true
        
        winkyButton.addTarget(self, action: #selector(onWinkyBtn), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let profPic = profPicView.image {
            
            // store profile pic aspect ratio
            profPicAspect = profPic.size.width / profPic.size.height
            
            // intitiaze scroll content offset so such that the profile pic starts with 1:1 aspect ratio
            self.view.layoutIfNeeded()
            let w = self.view.bounds.width
            let profPicDefaultHeight = w
            let profPicFullHeight = round(w / profPicAspect)
            scroll.contentOffset = CGPoint(x: 0, y: max(profPicFullHeight - profPicDefaultHeight, 0))
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let profPicDefaultHeight = w
        let profPicFullHeight = round(w / profPicAspect)
        
        scroll.frame = self.view.bounds
        updateProfPicSize()
        
        // layout content
        
        let contentW = w
        let contentY = profPicFullHeight
        
        nameLabel.center = CGPoint(x: contentW / 2, y: nameLabel.bounds.midY + 50)
        
        let detailsSideMargins: CGFloat = 60
        let detailsWidth = contentW - 2 * detailsSideMargins
        detailsLabel.frame = CGRect(x: detailsSideMargins, y: nameLabel.frame.maxY + 40, width: detailsWidth, height: 1000)
        detailsLabel.sizeToFit()
        
        winkyButton.center = CGPoint(x: contentW / 2, y: detailsLabel.frame.maxY + winkyButton.bounds.midY + 30)
        
        let contentH = winkyButton.frame.maxY + 20
        contentView.frame = CGRect(x: 0, y: contentY, width: contentW, height: contentH)
        
        scroll.contentSize = CGSize(width: w, height: max(contentView.frame.maxY, h + (profPicFullHeight - profPicDefaultHeight)))
    }
    
    private func updateProfPicSize() {
        
        let w = self.view.bounds.width
        let profPicFullHeight = round(w / profPicAspect)
        let minProfPicHeight: CGFloat = 120
        
        // resize prof pic image view height as the user scrolls
        profPicView.frame = CGRect(x: 0, y: 0, width: w, height: max(minProfPicHeight, profPicFullHeight - scroll.contentOffset.y))
        winkyLab.center = CGPoint(x: profPicView.bounds.midX, y: profPicView.bounds.midY)
    }

    private var detailsText: String {
        let name = mate.firstName ?? mate.lastName ?? "He/She"
        var text = "\(name) is a \(mate.age) year old \(mate.zodiac ?? "person"). "
        
        if mate.forceSensitive {
            switch mate.affilitionVal {
            case .firstOrder, .sith:
                text += "\(name) enjoys choking people out with the force. "
            default:
                text += "\(name) enjoys levatating rocks with the force. "
            }
        } else {
            text += "\(name) can't use the force but is great with a laser gun. "
        }
        
        switch mate.affilitionVal {
        case .jedi:
            text += "On weekends you'll find \(name) having light saber duels with Jedi buddies."
        case .resistance:
            text += "\(name) stays busy scheming up plans for the Resistance and doesn't get out much."
        case .firstOrder:
            text += "\(name) is a proud member of the First Order but that doesn't mean he's a \"bad guy\"."
        case .sith:
            text += "\(name) could be the Sith you've been looking for."
        case .none:
            text += "That's all we have to say about \(name)"
        }
        
        return text
    }
    
    @objc private func onWinkyBtn() {
        
        // show winky icon
        
        winkyFeedback.notificationOccurred(.success)
        winkyLab.alpha = 1
        
        let winkyFade = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1) {
            self.winkyLab.alpha = 0
        }
        winkyFade.startAnimation(afterDelay: 0.6)
    }
    
    @objc private func onCloseBtn() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension PotentialMateDetailsController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateProfPicSize()
    }
    
}
