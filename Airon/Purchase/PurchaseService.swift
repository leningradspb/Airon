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
                APIService.validateReceipt(urlBase64: receiptString) { result, error in
                    print(result, error)
                    
                    if let expires_date_ms = result?.latest_receipt_info?.first?.expires_date_ms, let ms = Int64(expires_date_ms) {
                        let currentTime = Date().currentTimeMillis()
                        print(currentTime, expires_date_ms)
                        if currentTime < ms {
                            print("ACTIVE")
                        } else {
                            print("EXPIRED")
                        }
                    }
                }
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


extension APIService {
    static func validateReceipt(urlBase64: String, completion: @escaping (_ result: AppStoreReceiptResult?, _ error: Error?) -> Void) {
        let parameters = "{\"exclude-old-transactions\": true, \"receipt-data\": \"\(urlBase64)\", \"password\": \"05948aef2fee407bbe21a3853927dd86\"}"
        
#if DEBUG
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
        let urlString = "https://buy.itunes.apple.com/verifyReceipt"
#endif
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("url \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("---------------------------------")
            print("Server response:")
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("DATA NOT FOUND!!! 🤯")
                completion(nil, error)
                return
            }
            print(String(data: data, encoding: .utf8) as Any)
//            print("JSON String: \(String(data: data, encoding: .utf8))")
            do {
                let history = try JSONDecoder().decode(AppStoreReceiptResult.self, from: data)
                print(history as Any)
                completion(history, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}


struct AppStoreReceiptResult: Decodable {
    let latest_receipt_info: [LatestReceiptInfo]?
}

struct LatestReceiptInfo: Decodable {
    let is_trial_period: String
    let expires_date: String
    let expires_date_ms: String
}


