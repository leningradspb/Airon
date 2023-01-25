//
//  PurchaseStepThreeVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit
import FloatingPanel
import SafariServices

class PurchaseStepThreeVC: UIViewController {
    private let imageView = UIImageView(image: UIImage(named: "airon-girl"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubviews([imageView])
        PurchaseService.shared.getSubscriptions()
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
    }
    

    @objc private func yearTapped() {
        // TODO: loader
        PurchaseService.shared.purchase(subscription: .year)
    }
    
    @objc private func weekTapped() {
        // TODO: loader
        let vc = PurchaseModal()
        let fpc = FloatingPanelController()
        
        fpc.delegate = self
        fpc.surfaceView.cornerRadius = 22
        fpc.backdropView.backgroundColor = UIColor(hex: "#001326")
        fpc.surfaceView.backgroundColor = .clear
        fpc.contentInsetAdjustmentBehavior = .never
        fpc.surfaceView.grabberHandle.barColor = UIColor.black.withAlphaComponent(0.08)
        fpc.isRemovalInteractionEnabled = true
        fpc.set(contentViewController: vc)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handlePreviewModalBackdropTap))
//        fpc.backdropView.addGestureRecognizer(tapGesture)
        
        DispatchQueue.main.async {
            fpc.addPanel(toParent: self, animated: true)
            fpc.updateLayout()
            fpc.updateLayout()
        }
//        PurchaseService.shared.purchase(subscription: .week)
    }

}

extension PurchaseStepThreeVC: FloatingPanelControllerDelegate
{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout?
    {
        return BottomSheetPresenter.PanelIntrinsicLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
//        startScanner()
//        weekTapped()
    }
}


class PurchaseModal: UIViewController {
    private let modalView = GradientView()
    private let choosePlanLabel = UILabel()
    private let benefitsStack = VerticalStackView(spacing: 12)
    private let plansStack = VerticalStackView(spacing: 12)
    private let yearView = RoundedView()
    private let weekView = RoundedView()
    private let switchView = UIView()
    private let switchTopLabel = BlackLabel(text: "FREE TRIAL ENABLED", fontSize: 20, fontWeight: .regular)
    private let freeTrialSwitch = UISwitch()
    private let lastBenefitLabel = BlackLabel(text: "💸 cancel any time", fontSize: 26)
    private let buyButton = UIButton()
    private let restorePurchase = UIButton()
    private let privacyButton = UIButton()
    
    private var isFreeTrial = true {
        didSet {
            weekView.isSelected = isFreeTrial
            yearView.isSelected = !isFreeTrial
            freeTrialSwitch.isOn = isFreeTrial
            updateSwitchView()
            lastBenefitLabel.text = isFreeTrial ? "💸 cancel any time" : "🤑 super SALE %"
            let title = isFreeTrial ? "🚀 START TRIAL" : "🚀 GET A SALE"
            buyButton.setTitle(title, for: .normal)
            buyButton.setTitle(title, for: .selected)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(modalView)
        modalView.startColor = .white.withAlphaComponent(0.6)
        modalView.endColor = .white.withAlphaComponent(0.95)
        modalView.roundOnlyTopCorners(radius: 30)
        modalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
//            $0.height.equalTo(200)
            $0.bottom.equalToSuperview()
        }
        
        modalView.addSubviews([choosePlanLabel, benefitsStack, plansStack, restorePurchase, privacyButton])
        
        choosePlanLabel.text = "Choose your plan"
        choosePlanLabel.textColor = .textBlack
        choosePlanLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        choosePlanLabel.textAlignment = .center
        choosePlanLabel.font = .systemFont(ofSize: 36, weight: .bold)
        
        benefitsStack.snp.makeConstraints {
            $0.top.equalTo(choosePlanLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        benefitsStack.addArranged(subviews: [BlackLabel(text: "🤩 advertising-free", fontSize: 26), BlackLabel(text: "📱 unlimited access", fontSize: 26), BlackLabel(text: "✍️ copy, paste and share", fontSize: 26), lastBenefitLabel])
        
        plansStack.snp.makeConstraints {
            $0.top.equalTo(benefitsStack.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        plansStack.addArranged(subviews: [switchView, yearView, weekView, buyButton])
        
        isFreeTrial = true
        
        yearView.tapCompletion = { [weak self] in
            guard let self = self else { return }
            self.isFreeTrial = false
        }
        yearView.topText = "ONE-YEAR ACCESS"
        yearView.bottomText = "29,99 $/year"
        
        weekView.tapCompletion = { [weak self] in
            guard let self = self else { return }
            self.isFreeTrial = true
        }
        weekView.topText = "3-DAY FREE TRIAL"
        weekView.bottomText = "then 4,99 $/week"
        
        
        switchView.addSubviews([switchTopLabel, freeTrialSwitch])
        switchView.snp.makeConstraints {
            $0.height.equalTo(55)
        }
        
        switchTopLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        freeTrialSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        freeTrialSwitch.isOn = true
        freeTrialSwitch.onTintColor = .grass
        freeTrialSwitch.addTarget(self, action: #selector(switchTapped), for: .touchUpInside)
        updateSwitchView()
        
        buyButton.layer.cornerRadius = 10
        
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.setTitleColor(.white, for: .selected)
        buyButton.titleLabel?.font = .systemFont(ofSize: 26, weight: .bold)
        buyButton.backgroundColor = .grass
        
        buyButton.snp.makeConstraints {
            $0.height.equalTo(70)
        }
        buyButton.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        
        restorePurchase.snp.makeConstraints {
            $0.top.equalTo(plansStack.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        restorePurchase.setTitle("Restore purchase", for: .normal)
        restorePurchase.setTitleColor(.commonGrey, for: .normal)
        restorePurchase.titleLabel?.textAlignment = .center
        restorePurchase.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        
        
        
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(plansStack.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(20)
        }
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(.commonGrey, for: .normal)
        privacyButton.titleLabel?.textAlignment = .center
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
    }
    
    private func updateSwitchView() {
        if freeTrialSwitch.isOn {
            switchView.layer.cornerRadius = 12
            switchView.layer.borderWidth = 2
            switchView.backgroundColor = UIColor(hex: "F2F5C8")
            switchView.layer.borderColor = UIColor.grass.cgColor
            switchTopLabel.text = "FREE TRIAL ENABLED"
            switchTopLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        } else {
            switchView.layer.borderWidth = 0
            switchView.backgroundColor = .violetUltraLight //UIColor(hex: "65647C").withAlphaComponent(0.8)
            switchTopLabel.text = "ENABLE FREE TRIAL"
            switchTopLabel.font = .systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @objc private func switchTapped() {
        updateSwitchView()
        isFreeTrial = freeTrialSwitch.isOn
    }
    
    @objc private func buyTapped() {
        if isFreeTrial {
            PurchaseService.shared.purchase(subscription: .week)
        } else {
            PurchaseService.shared.purchase(subscription: .year)
        }
    }
    
    @objc private func restoreTapped() {
        PurchaseService.shared.restorePurchase()
    }
    
    @objc private func privacyTapped() {
        let vc = SFSafariViewController(url: URL(string: "https://docs.google.com/document/d/1IEVqpzrH7jBk-e0faJp0UnHXns2b5yJ2ljzhdm0aH0k/edit?usp=sharing")!)
        
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

class RoundedView: UIView {
    private let topLabel = BlackLabel(text: "", fontSize: 20, fontWeight: .regular)
    private let bottomLabel = BlackLabel(text: "", fontSize: 20)
    
    var topText: String = "" {
        didSet {
            topLabel.text = topText
        }
    }
    
    var bottomText: String = "" {
        didSet {
            bottomLabel.text = bottomText
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            update()
        }
    }
    
    var tapCompletion: (()->())?
    
    init() {
        super.init(frame: .zero)
        addSubviews([topLabel, bottomLabel])
        layer.cornerRadius = 12
        layer.borderWidth = 2
        self.snp.makeConstraints {
            $0.height.equalTo(70)
        }
        
        topLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(20)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(20)
        }
        
        addTapGesture(target: self, action: #selector(tapped))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        if isSelected {
            layer.borderWidth = 2
            backgroundColor = UIColor(hex: "F2F5C8")
            layer.borderColor = UIColor.grass.cgColor
        } else {
            layer.borderWidth = 0
            backgroundColor = .violetUltraLight
        }
    }
    
    @objc private func tapped() {
        tapCompletion?()
    }
}
