//
//  OnboardingVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 27.01.2023.
//

import UIKit

class OnboardingVC: UIViewController {
    private let imageView = UIImageView()
    
    private let state: State
    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
//        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
        view.backgroundColor = .mainBlack
        view.addSubviews([imageView])
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview().offset(-60)
        }
        var imageName = "onboarding"
        switch state {
        case .step0(index: let index):
            imageName += "\(index)"
        case .step1(index: let index):
            imageName += "\(index)"
        case .step2(index: let index):
            imageName += "\(index)"
        }
        imageView.image = UIImage(named: imageName)
    }
    
    enum State {
        case step0(index: Int), step1(index: Int), step2(index: Int)
    }
}

