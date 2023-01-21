//
//  PurchaseStepOneVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//
import UIKit

class PurchaseStepOneVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingWasShown.rawValue)
    }
}
