//
//  SettingsVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 26.01.2023.
//

import UIKit
import SafariServices

class SettingsVC: UIViewController {
    private let headerLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let settingsContent = [SettingsModel.privacy(name: "Privacy", url: "https://docs.google.com/document/d/1IEVqpzrH7jBk-e0faJp0UnHXns2b5yJ2ljzhdm0aH0k/edit?usp=sharing"), SettingsModel.contactUs(name: "Contact us", url: "https://t.me/edkanevsky")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    

    private func setupTableView() {
        view.backgroundColor = .mainBlack
        view.addSubviews([headerLabel, tableView])
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        headerLabel.text = "Settings"
        headerLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textColor = .white
        
        tableView.backgroundColor = .mainBlack
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as! SettingsCell
        cell.update(with: settingsContent[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsModel = settingsContent[indexPath.row]
        
        switch settingsModel {
        
        case .privacy(name: let name, url: let url):
            guard let path = URL(string: url) else { return }
            
            let vc = SFSafariViewController(url: path)
            self.present(vc, animated: true)
        case .contactUs(name: let name, url: let url):
            guard let path = URL(string: url) else { return }
            let vc = SFSafariViewController(url: path)
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
}

class SettingsCell: UITableViewCell {
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with settingsModel: SettingsModel) {
        switch settingsModel {
        
        case .privacy(name: let name, url: let url):
            nameLabel.text = name
        case .contactUs(name: let name, url: let url):
            nameLabel.text = name
        }
    }
    
    private func setupUI() {
//        backgroundColor = .clear
        contentView.backgroundColor = UIColor(hex: "1A1C1E")
//        selectionStyle = .none
        contentView.addSubview(nameLabel)
        
        nameLabel.textColor = .white
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

enum SettingsModel {
    case privacy(name: String, url: String)
    case contactUs(name: String, url: String)
}
