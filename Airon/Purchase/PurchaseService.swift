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
    
    var products: [SKProduct] = []
    private let paymentQueue = SKPaymentQueue.default()
    
    func getSubscriptions() {
        let subscriptionIDs: Set = [SubscriptionProduct.year.rawValue, SubscriptionProduct.week.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: subscriptionIDs)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(subscription: SubscriptionProduct) {
        guard let subscriptionToPurchase = products.first(where: { $0.productIdentifier == subscription.rawValue }) else { return }
        let payment = SKPayment(product: subscriptionToPurchase)
        paymentQueue.add(payment)
    }
}

extension PurchaseService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.count, response.invalidProductIdentifiers.count)
        self.products = response.products
//        response.products.forEach {
//            products.append($0)
//            print($0)
//        }
    }
}

extension PurchaseService: SKPaymentTransactionObserver {
    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
        transactions.forEach {
            print($0.transactionState.status(), $0.payment.productIdentifier)
        }
    }
}

extension SKPaymentTransactionState {
    func status () -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}
