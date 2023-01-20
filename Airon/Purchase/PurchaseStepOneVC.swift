//
//  PurchaseStepOneVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit
import FloatingPanel

class PurchaseStepOneVC: UIViewController {
    private let imageView = UIImageView(image: UIImage(named: "airon-girl"))
    private let yearButton = VioletButton(text: "1 year")
    private let weekButton = VioletButton(text: "week")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGreen
        view.addSubviews([imageView, yearButton, weekButton])
        PurchaseService.shared.getSubscriptions()
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
        
        yearButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        weekButton.snp.makeConstraints {
            $0.top.equalTo(yearButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        yearButton.addTarget(self, action: #selector(yearTapped), for: .touchUpInside)
        weekButton.addTarget(self, action: #selector(weekTapped), for: .touchUpInside)
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

extension PurchaseStepOneVC: FloatingPanelControllerDelegate
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
    
    
    private var isFreeTrial = true {
        didSet {
            weekView.isSelected = isFreeTrial
            yearView.isSelected = !isFreeTrial
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(modalView)
        modalView.startColor = .white.withAlphaComponent(0.4)
        modalView.endColor = .white.withAlphaComponent(0.8)
        modalView.roundOnlyTopCorners(radius: 30)
        modalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
//            $0.height.equalTo(200)
            $0.bottom.equalToSuperview()
        }
        
        modalView.addSubviews([choosePlanLabel, benefitsStack, plansStack])
        
        choosePlanLabel.text = "Choose your plan"
        choosePlanLabel.textColor = .textBlack
        choosePlanLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
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
        benefitsStack.addArranged(subviews: [BlackLabel(text: "🤩 advertising-free", fontSize: 26), BlackLabel(text: "📱 unlimited access", fontSize: 26), BlackLabel(text: "✍️ copy, paste and share", fontSize: 26)])
        
        plansStack.snp.makeConstraints {
            $0.top.equalTo(benefitsStack.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-120)
        }
        
        plansStack.addArranged(subviews: [yearView, weekView])
        
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
            backgroundColor = UIColor(hex: "F2F5C8").withAlphaComponent(0.7)
            layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            layer.borderWidth = 0
            backgroundColor = UIColor(hex: "65647C").withAlphaComponent(0.8) //.violetLight.withAlphaComponent(0.7)
        }
    }
    
    @objc private func tapped() {
        tapCompletion?()
    }
}
