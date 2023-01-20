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
    private let modalView = GradientView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGreen
        view.addSubviews([imageView, modalView, yearButton, weekButton])
        PurchaseService.shared.getSubscriptions()
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
        
        modalView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        modalView.startColor = .white.withAlphaComponent(0.2)
        modalView.endColor = .white.withAlphaComponent(0.8)
        modalView.roundOnlyTopCorners(radius: 30)
        
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
        let vc = PurchaseStepTwoVC()
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
        weekTapped()
    }
}
