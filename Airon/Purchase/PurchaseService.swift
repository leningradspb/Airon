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
        guard SKPaymentQueue.canMakePayments(), let subscriptionToPurchase = products.first(where: { $0.productIdentifier == subscription.rawValue }) else {
            let alert = UIAlertController(title: "You are can't make payments", message: "", preferredStyle: .alert)
            //TODO: ERROR CAN NOT MAKE PAYMENTS
            return
        }
        let payment = SKPayment(product: subscriptionToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchase() {
        paymentQueue.restoreCompletedTransactions()
    }
    
    func checkIsPurchased() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            print(appStoreReceiptURL)
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                print(receiptString)
            } catch {
                
            }
        }
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
            switch $0.transactionState {
            case .purchasing: break
            default: queue.finishTransaction($0)
            }
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
