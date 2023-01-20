//
//  PurchaseStepTwoVC.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import UIKit

class PurchaseStepTwoVC: UIViewController {
    private let l = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
        view.addSubview(l)
        l.text = "125125"
        l.font = .systemFont(ofSize: 80)
        
        l.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
