//
//  ViewController.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit

class TopicsVC: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    let nc = PurchaseNC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
//        purchaseCheck()
    }
    
    private func setupUI() {
        title = "Topics"
        view.backgroundColor = UIColor(hex: "#121212")
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopicCell.self, forCellReuseIdentifier: TopicCell.identifier)
    
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    
}

extension TopicsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section < sections.count {
//            let v = UIView()
//            let header = UILabel()
//            header.text = sections[section].name
//            v.addSubview(header)
//            header.textColor = .white
//            header.font = .systemFont(ofSize: 24, weight: .semibold)
//
//            header.snp.makeConstraints {
//                $0.leading.equalToSuperview().offset(16)
//                $0.trailing.equalToSuperview()
//                $0.centerY.equalToSuperview()
//            }
//            return v
//        }
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicCell.identifier, for: indexPath) as! TopicCell
        cell.update(isOdd: indexPath.row % 2 == 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard indexPath.section < sections.count, sections[indexPath.section].isRecommendation != true else { return }
//        print("didSelectRowAt")
//        let section = sections[indexPath.section]
//        if let cells = section.cells, indexPath.row < cells.count, let name = cells[indexPath.row].cellName {
//            let vc = CategoryVC(categoryName: name)
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}



class TopicCell: UITableViewCell {
    private let realContentView = GradientView()
    private let titleLabel = BlackLabel(text: "Get translation help", fontSize: 22, fontWeight: .medium)
    private let subtitleLabel = BlackLabel(text: "translate text into language", fontSize: 18, fontWeight: .medium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(isOdd: Bool) {
        if isOdd {
            realContentView.startColor = .violetUltraLight
            realContentView.endColor = .violetLight
        } else {
            realContentView.startColor = UIColor(hex: "EDCDBB") //.violetUltraLight
            realContentView.endColor = UIColor(hex: "E3B7A0") //.violetLight
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(realContentView)
        
        realContentView.layer.cornerRadius = 8
        realContentView.startLocation = 0
        realContentView.endLocation = 0.8
        realContentView.diagonalMode = true
        
        realContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-6)
        }
        
        realContentView.addSubviews([titleLabel, subtitleLabel])
        subtitleLabel.textColor = UIColor(hex: "5A6066")
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
