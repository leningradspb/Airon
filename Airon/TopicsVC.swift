//
//  ViewController.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit
import SnapKit
import Firebase

class TopicsVC: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 6
    private let numberOfCollectionViewColumns: CGFloat = 2
    private let refreshControl = UIRefreshControl()
    private var topics: [TopicModel] = []
//    [TopicModel(id: "1", name: "Translate to any language", imageName: "translator", message: "Type language"), TopicModel(id: "2", name: "Grammar Correction", imageName: "grammarcorrector", message: "Type your text"), TopicModel(id: "3", name: "Movie to Emoji ", imageName: "movie", message: "Type your movie"), TopicModel(id: "4", name: "Chat with friend", imageName: "chatai", message: "What's up?")]
    private var lastDocument: DocumentSnapshot?
    private let limit = 20
    private var isNeedFetch = true
    private let iconConfig = UIImage.SymbolConfiguration(scale: .large)
//    let nc = PurchaseNC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
//        checkOnboarding()
        checkForceUpdate()
        loadData()
        purchaseCheck()
        loadAIAPISettings()
    }
    
    private func setupUI() {
        title = "AI prompts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear", withConfiguration: iconConfig), style: .plain, target: self, action: #selector(settingsTapped))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .mainBlack //UIColor(hex: "#121212")
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
        collectionView.register(TopicHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TopicHeader.identifier)
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
//        PurchaseService.shared.purchaseCompletion = { [weak self] in
//            guard let self = self else { return }
//            self.nc.dismiss(animated: true)
//        }
        
        PurchaseService.shared.checkIsPurchased(completion: { [weak self] isActivated in
            guard let self = self else { return }
            print(isActivated)
            
//            if !isActivated {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//
//                    let onboardingWasShown = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
//                    let vc = onboardingWasShown ? PurchaseStepThreeVC() : PurchaseStepOneVC()
//                    self.nc.viewControllers = [vc]
//                    self.nc.modalPresentationStyle = .fullScreen
//                    self.present(self.nc, animated: true)
//                })
//            }
        })
    }
    
    private func loadData() {
        if let lastDocument = self.lastDocument {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.topics).whereField(ReferenceKeys.isActive, isEqualTo: true).order(by: ReferenceKeys.position, descending: false).limit(to: limit).start(afterDocument: lastDocument).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                print(snapshot?.documents.count, error)
                if let error = error {
                    self.view.showMessage(text: error.localizedDescription, isError: true)
                    return
                }
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isNeedFetch = false
                    return
                }

                documents.forEach {
                    let snapshotData = $0.data()
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
                    do {
                        let model = try JSONDecoder().decode(TopicModel.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.topics.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        } else {
            FirebaseManager.shared.firestore.collection(ReferenceKeys.topics).whereField(ReferenceKeys.isActive, isEqualTo: true).order(by: ReferenceKeys.position, descending: false).limit(to: limit).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                print(snapshot?.documents.count, error)
                if let error = error {
                    self.view.showMessage(text: error.localizedDescription, isError: true)
                    return
                }
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isNeedFetch = false
                    return
                }

                documents.forEach {
                    let snapshotData = $0.data()
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
                    do {
                        let model = try JSONDecoder().decode(TopicModel.self, from: data)
                        print(model)
                        
                        DispatchQueue.main.async {
                            self.topics.append(model)
                            self.lastDocument = documents.last
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                    }
                }
            }
        }
    }
    
    private func checkForceUpdate() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appVersionDouble = Double(appVersion) else {
            return
        }
        
        FirebaseManager.shared.firestore.collection(ReferenceKeys.ForceUpdate).document(ReferenceKeys.ForceUpdate).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(ForceUpdateModel.self, from: data)
                DispatchQueue.main.async {
                    if appVersionDouble < model.supportedVersion {
                        let modal = ErrorModal(errorText: "force update required???? please update the app", isForceUpdate: true)
                        self.window.addSubview(modal)
                        
                    } else {
                        
                    }
                }
            } catch let error {
                print(error)
                
            }
        }
    }
    
    private func loadAIAPISettings() {
        FirebaseManager.shared.firestore.collection(ReferenceKeys.AIRequestSettings).document(ReferenceKeys.AIRequestSettings).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(AIRequestModel.self, from: data)
                FirebaseManager.shared.model = model.model
                FirebaseManager.shared.presence_penalty = model.presence_penalty
                FirebaseManager.shared.top_p = model.top_p
                FirebaseManager.shared.max_tokens = model.max_tokens
                FirebaseManager.shared.temperature = model.temperature
                FirebaseManager.shared.frequency_penalty = model.frequency_penalty
            } catch let error {
                print(error)
                
            }
        }
    }
    
    private func checkOnboarding() {
        let onboardingWasShown = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
        if !onboardingWasShown {
            //                            let nc = UINavigationController()
            let vc = OnboardingVC(state: .step0(index: 0))
            vc.modalPresentationStyle = .overFullScreen
            print(onboardingWasShown, "onboardingWasShown")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func refresh() {
        topics.removeAll()
        lastDocument = nil
        isNeedFetch = true
        loadData()
        refreshControl.endRefreshing()
    }
    
    @objc private func settingsTapped() {
        let vc = SettingsVC()
        self.present(vc, animated: true)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func headerTapped() {
        let chatInitModel = ChatVC.ChatInitModel(firstMessage: "Ask me anything", secondMessage: nil, prompt: "", topicName: "Ask anything")
        let vc = ChatVC(model: chatInitModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension TopicsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TopicHeader.identifier, for: indexPath) as! TopicHeader

        if header.gestureRecognizers == nil {
            setupTapRecognizer(for: header, action: #selector(headerTapped))
        }

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width - (Layout.leading * 2), height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicCell.identifier, for: indexPath) as! TopicCell
        let row = indexPath.row
        
        if row < topics.count {
            let model = topics[row]
            let topicName = model.topicName
            let imageUrlString = model.iconUrl ?? ""
            cell.update(topicName: topicName, imageUrlString: imageUrlString)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED IN collectionView TopicsVC")
        let row = indexPath.row
        
        if row < topics.count {
            let model = topics[row]
            let firstMessage = model.firstMessage
            let secondMessage = model.secondMessage
            let prompt = model.prompt
            let topicName = model.topicName
            let chatInitModel = ChatVC.ChatInitModel(firstMessage: firstMessage, secondMessage: secondMessage, prompt: prompt, topicName: topicName)
            let vc = ChatVC(model: chatInitModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard topics.count > 0, isNeedFetch else { return }
         if indexPath.row == topics.count - 1 {
             loadData()
         }
    }
}

final class TopicHeader: UICollectionReusableView {
    private let realContentView = GradientView()
    private let imageView = UIImageView(image: UIImage(named: "comment-question")?.withRenderingMode(.alwaysTemplate))
    private let nameLabel = UILabel()
//    var imageClosure: ((UIImage)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(realContentView)
        backgroundColor = .mainBlack
        realContentView.layer.cornerRadius = 8
        realContentView.startLocation = 0
        realContentView.endLocation = 0.9
        realContentView.startColor = UIColor(hex: "1A1C1E")  //.black.withAlphaComponent(0.8) //UIColor(hex: "1A1C1E")  //UIColor(hex: "212427")
        realContentView.endColor =  UIColor(hex: "121416") //UIColor(hex: "370258")

        realContentView.diagonalMode = true
        
        realContentView.backgroundColor = .mainBlack
        realContentView.layer.shadowOffset = CGSize(width: 6,
                                                    height: 6)
        realContentView.layer.shadowRadius = 8
        realContentView.layer.shadowOpacity = 0.5
        realContentView.layer.shadowColor = UIColor(hex: "292B2F").cgColor
        
        realContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        realContentView.addSubviews([imageView, nameLabel])
        imageView.tintColor = .systemBlue
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(55)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        nameLabel.text = "Ask AI anything ????"
//        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
    
    func update(topicName: String, imageUrlString: String) {
        iconImageView.kf.indicatorType = .activity
        (iconImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
        if let url = URL(string: imageUrlString) {
            iconImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
                guard let self = self else { return }
                let templateImage = self.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                self.iconImageView.image = templateImage
                self.iconImageView.tintColor = .systemBlue //UIColor(hex: "65B9F6")
            }
        }
        
        nameLabel.text = topicName
    }
    
    private func setupUI() {
        backgroundColor = .black
        contentView.backgroundColor = UIColor(hex: "121416")
        contentView.addSubview(realContentView)
        realContentView.addSubviews([iconImageView, nameLabel])
        
        realContentView.layer.shadowOffset = CGSize(width: 6,
                                                    height: 6)
        realContentView.layer.shadowRadius = 8
        realContentView.layer.shadowOpacity = 0.5
        realContentView.layer.shadowColor = UIColor(hex: "292B2F").cgColor
        
        realContentView.layer.cornerRadius = 8
        realContentView.startLocation = 0
        realContentView.endLocation = 0.9
        realContentView.startColor = UIColor(hex: "1A1C1E")  //.black.withAlphaComponent(0.8) //UIColor(hex: "1A1C1E")  //UIColor(hex: "212427")
        realContentView.endColor =  UIColor(hex: "121416") //UIColor(hex: "370258")

        realContentView.diagonalMode = true
        
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
    let topicName, firstMessage: String
    let iconUrl, secondMessage, prompt: String?
}

struct ForceUpdateModel: Codable {
    let supportedVersion: Double
}
