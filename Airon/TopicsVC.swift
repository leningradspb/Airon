//
//  ViewController.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit
import SnapKit

class TopicsVC: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 6
    private let numberOfCollectionViewColumns: CGFloat = 2
    private let refreshControl = UIRefreshControl()
    private let topics = [TopicModel(id: "1", name: "Translate to any language", imageName: "book", message: "Type language"), TopicModel(id: "2", name: "Grammar Correction", imageName: "pencil.and.outline", message: "Type your text"), TopicModel(id: "3", name: "Movie to Emoji ", imageName: "video", message: "Type your movie")]
//    private var usersHistory: [UserHistory] = []
//    private var userModel: UserModel?
//    private var lastDocument: DocumentSnapshot?
    private let limit = 20
    private var isNeedFetch = true
    let nc = PurchaseNC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
//        purchaseCheck()
    }
    
    private func setupUI() {
        title = "Topics"
        view.backgroundColor = UIColor(hex: "121416") //UIColor(hex: "#121212")
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.register(TopicCell.self, forCellWithReuseIdentifier: TopicCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.leading, bottom: Layout.leading, right: Layout.leading)
//        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func purchaseCheck() {
        PurchaseService.shared.purchaseCompletion = { [weak self] in
            guard let self = self else { return }
            self.nc.dismiss(animated: true)
        }
        
        PurchaseService.shared.checkIsPurchased(completion: { [weak self] isActivated in
            guard let self = self else { return }
            print(isActivated)
            
            if !isActivated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    
                    let onboardingWasShown = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
                    let vc = onboardingWasShown ? PurchaseStepThreeVC() : PurchaseStepOneVC()
                    self.nc.viewControllers = [vc]
                    self.nc.modalPresentationStyle = .fullScreen
                    self.present(self.nc, animated: true)
                })
            }
        })
    }
    
    @objc private func refresh() {
//        usersHistory.removeAll()
//        lastDocument = nil
//        isNeedFetch = true
//        loadData()
//        refreshControl.endRefreshing()
    }
    
}


extension TopicsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
//        if let urlString = userModel?.profileImageURL, let url = URL(string: urlString) {
//            header.configure(with: url, nickName: userModel?.nickName)
//            header.imageClosure = { [weak self] image in
//                guard let self = self else { return }
//                self.headerImage = image
//            }
//        }
//
//        if header.gestureRecognizers == nil {
//            setupTapRecognizer(for: header, action: #selector(headerTapped))
//        }
//
//        return header
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.bounds.width, height: 280)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicCell.identifier, for: indexPath) as! TopicCell
        let row = indexPath.row
        let model = topics[row]
        cell.update(systemName: model.imageName, title: model.name)
//        if row < usersHistory.count, let photo = usersHistory[row].photo, let url = URL(string: photo) {
//            cell.setImage(url: url)
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: 200)
//        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: view.bounds.height / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("TAPPED IN collectionView ProfileVC")
//        if let cell = collectionView.cellForItem(at: indexPath) as? FullContentViewImageCollectionViewCell {
//            if let image = cell.recommendationImageView.image {
//                let vc = FullSizeWallpaperVC(image: image)
//                self.present(vc, animated: true)
//            }
//        }
//    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard usersHistory.count > 0, isNeedFetch else { return }
//         if indexPath.row == usersHistory.count - 1 {
//             loadData()
//         }
//    }
}


class TopicCell: UICollectionViewCell {
    private let realContentView = GradientView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let cornerRadius: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(systemName: String, title: String) {
        iconImageView.image = UIImage(systemName: systemName)
        nameLabel.text = title
    }
    
    private func setupUI() {
        backgroundColor = .black
        contentView.backgroundColor = UIColor(hex: "121416")
        contentView.addSubview(realContentView)
        realContentView.addSubviews([iconImageView, nameLabel])
        
        realContentView.layer.shadowOffset = CGSize(width: 8,
                                                    height: 8)
        realContentView.layer.shadowRadius = 8
        realContentView.layer.shadowOpacity = 0.7
        realContentView.layer.shadowColor = UIColor(hex: "292B2F").cgColor
        
        realContentView.layer.cornerRadius = 8
        realContentView.startLocation = 0
        realContentView.endLocation = 0.9
        realContentView.startColor = UIColor(hex: "212427")
        realContentView.endColor = UIColor(hex: "1A1C1E") //UIColor(hex: "370258")

        //        realContentView.diagonalMode = true
        
        realContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }
        // 70C7F6
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}

struct TopicModel: Codable {
    let id: String
    let name, imageName: String
    let message: String
}
