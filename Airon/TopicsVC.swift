//
//  ViewController.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit

class TopicsVC: UIViewController {
    let nc = PurchaseNC()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grass ///UIColor(hex: "#121212")
        /*
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
         */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            let onboardingWasShown = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
            let vc = onboardingWasShown ? PurchaseStepThreeVC() : PurchaseStepOneVC()
            self.nc.viewControllers = [vc]
            self.nc.modalPresentationStyle = .fullScreen
            self.present(self.nc, animated: true)
        })
    }
}

