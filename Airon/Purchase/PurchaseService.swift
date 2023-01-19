//
//  PurchaseService.swift
//  Airon
//
//  Created by Eduard Kanevskii on 19.01.2023.
//

import Foundation
import StoreKit

class PurchaseService: NSObject {
    private override init() {}
    
    static let shared = PurchaseService()
    
    func getSubscriptions() {
        let subscriptionIDs: Set = [SubscriptionProduct.year.rawValue, SubscriptionProduct.week.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: subscriptionIDs)
        request.delegate = self
        request.start()
    }
}

extension PurchaseService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.count, response.invalidProductIdentifiers.count)
        response.products.forEach {
            print($0)
        }
    }
}
