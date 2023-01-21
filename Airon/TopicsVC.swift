//
//  ViewController.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit

class TopicsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#121212")
        
        PurchaseService.shared.checkIsPurchased(completion: { isActivated in
            print(isActivated)
        })
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//            let nc = PurchaseNC()
//            let firstStepVC = PurchaseStepOneVC()
//            nc.viewControllers = [firstStepVC]
//            nc.modalPresentationStyle = .fullScreen
//            self.present(nc, animated: true)
//        })
    }


}

