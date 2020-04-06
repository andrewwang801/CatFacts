//
// InAppProductPurchaseRequest.swift
// SwiftyStoreKit
//
// Copyright (c) 2015 Andrea Bizzotto (bizz84@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit

class InAppProductPurchaseRequest: NSObject, SKPaymentTransactionObserver {

    enum TransactionResult {
        case purchased(productId: String)
        case restored(productId: String)
        case nothingToRestore
        case failed(error: NSError)
    }
    
    typealias RequestCallback = (_ result: TransactionResult) -> ()
    fileprivate let callback: RequestCallback
    fileprivate var purchases : [SKPaymentTransactionState: [String]] = [:]

    var paymentQueue: SKPaymentQueue {
        get {
            return  SKPaymentQueue.default()
        }
    }
    
    let product : SKProduct?
    
    deinit {
        paymentQueue.remove(self)
    }
    // Initialiser for product purchase
    fileprivate init(product: SKProduct?, callback: @escaping RequestCallback) {

        self.product = product
        self.callback = callback
        super.init()
        paymentQueue.add(self)
    }
    // MARK: Public methods
    class func startPayment(_ product: SKProduct, callback: @escaping RequestCallback) -> InAppProductPurchaseRequest {
        let request = InAppProductPurchaseRequest(product: product, callback: callback)
        request.startPayment(product)
        return request
    }
    class func restorePurchases(_ callback: @escaping RequestCallback) -> InAppProductPurchaseRequest {
        let request = InAppProductPurchaseRequest(product: nil, callback: callback)
        request.startRestorePurchases()
        return request
    }
    
    // MARK: Private methods
    fileprivate func startPayment(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        DispatchQueue.global().async {
            self.paymentQueue.add(payment)
        }
    }
    fileprivate func startRestorePurchases() {
        DispatchQueue.global().async {
            self.paymentQueue.restoreCompletedTransactions()
        }
    }
    
    // MARK: SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                DispatchQueue.main.async(execute: {
                    self.callback(.purchased(productId: transaction.payment.productIdentifier))
                })
                paymentQueue.finishTransaction(transaction)
                break
            case .failed:
                DispatchQueue.main.async {
                    let altError = NSError(domain: SKErrorDomain, code: 0, userInfo: [ NSLocalizedDescriptionKey: "Unknown error" ])
                    self.callback(.failed(error: (transaction.error as NSError?) ?? altError))
                }
                paymentQueue.finishTransaction(transaction)
                break
            case .restored:
                DispatchQueue.main.async(execute: {
                    self.callback(.restored(productId: transaction.payment.productIdentifier))
                })
                paymentQueue.finishTransaction(transaction)
                break
            case .purchasing:
                // In progress: do nothing
                break
            case .deferred:
                break
            }
            // Keep track of payments
            if let _ = purchases[transaction.transactionState] {
                purchases[transaction.transactionState]?.append(transaction.payment.productIdentifier)
            }
            else {
                purchases[transaction.transactionState] = [ transaction.payment.productIdentifier ]
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print(transactions)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        DispatchQueue.main.async(execute: {
            self.callback(.failed(error: error as NSError))
        })
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        if let product = self.product {
            self.callback(.restored(productId: product.productIdentifier))
            return
        }
        // This method will be called after all purchases have been restored (includes the case of no purchases)
        guard let restored = purchases[.restored], restored.count > 0 else {
            
            self.callback(.nothingToRestore)
            return
        }
        //print("\(restored)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
    }
}

