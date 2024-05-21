//
// SwiftyStoreKit.swift
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
import Foundation
import StoreKit


open class SwiftyStoreKit {

    // MARK: Private declarations
    fileprivate class InAppPurchaseStore {
        var products: [String: SKProduct] = [:]
        func addProduct(_ product: SKProduct) {
            products[product.productIdentifier] = product
        }
    }
    fileprivate var store: InAppPurchaseStore = InAppPurchaseStore()

    // As we can have multiple inflight queries and purchases, we store them in a dictionary by product id
    fileprivate var inflightQueries: [String: InAppProductQueryRequest] = [:]
    fileprivate var inflightPurchases: [String: InAppProductPurchaseRequest] = [:]
    fileprivate var restoreRequest: InAppProductPurchaseRequest?

    // MARK: Enums
    public enum PurchaseResultType {
        case success(productId: String)
        case error(error: Error)
    }
    public enum RetrieveResultType {
        case success(product: SKProduct)
        case error(error: Error)
    }
    public enum RestoreResultType {
        case success(productId: String)
        case error(error: Error)
        case nothingToRestore
    }

    // MARK: Singleton
    fileprivate static let sharedInstance = SwiftyStoreKit()
    
    open class var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // MARK: Public methods
    open class func retrieveProductInfo(_ productId: String, completion: @escaping (_ result: RetrieveResultType) -> ()) {
        guard let product = sharedInstance.store.products[productId] else {
            
            sharedInstance.requestProduct(productId) { (inner: () throws -> SKProduct) -> () in
                do {
                    let product = try inner()
                    completion(.success(product: product))
                }
                catch let error {
                    completion(.error(error: error))
                }
            }
            return
        }
        completion(.success(product: product))
    }
    
    open class func purchaseProduct(_ productId: String, completion: @escaping (_ result: PurchaseResultType) -> ()) {
        
        if let product = sharedInstance.store.products[productId] {
            sharedInstance.purchase(product: product, completion: completion)
        }
        else {
            retrieveProductInfo(productId) { (result) -> () in
                if case .success(let product) = result {
                    sharedInstance.purchase(product: product, completion: completion)
                }
                else if case .error(let error) = result {
                    completion(.error(error: error))
                }
            }
        }
    }
    
    open class func restorePurchases(_ completion: @escaping (_ result: RestoreResultType) -> ()) {

        sharedInstance.restoreRequest = InAppProductPurchaseRequest.restorePurchases() { result in
        
            sharedInstance.restoreRequest = nil
            let returnValue = sharedInstance.processRestoreResult(result)
            completion(returnValue)
        }
    }

    // MARK: private methods
    fileprivate func purchase(product: SKProduct, completion: @escaping (_ result: PurchaseResultType) -> ()) {
    
        inflightPurchases[product.productIdentifier] = InAppProductPurchaseRequest.startPayment(product) { result in

            self.inflightPurchases[product.productIdentifier] = nil
            let returnValue = self.processPurchaseResult(result)
            completion(returnValue)
        }
    }

    fileprivate func processPurchaseResult(_ result: InAppProductPurchaseRequest.TransactionResult) -> PurchaseResultType {
        switch result {
        case .purchased(let productId):
            // TODO: Need a way to match with current product?
            return .success(productId: productId)
        case .failed(let error):
            return .error(error: error)
        case .restored(_):
            fatalError("case Restored is not allowed for purchase flow")
        case .nothingToRestore:
            fatalError("case NothingToRestore is not allowed for purchase flow")
        }
    }
    
    fileprivate func processRestoreResult(_ result: InAppProductPurchaseRequest.TransactionResult) -> RestoreResultType {
        switch result {
        case .purchased(_):
            fatalError("case Purchased is not allowed for restore flow")
        case .failed(let error):
            return .error(error: error)
        case .restored(let productId):
            return .success(productId: productId)
        case .nothingToRestore:
            return .nothingToRestore
        }
    }
    
    // http://appventure.me/2015/06/19/swift-try-catch-asynchronous-closures/
    fileprivate func requestProduct(_ productId: String, completion: @escaping (_ result: (() throws -> SKProduct)) -> ()) -> () {
        
        inflightQueries[productId] = InAppProductQueryRequest.startQuery([productId]) { result in
        
            self.inflightQueries[productId] = nil
            if case .success(let products) = result {
                
                // Add to Store
                for product in products {
                    //print("Received product with ID: \(product.productIdentifier)")
                    self.store.addProduct(product)
                }
                guard let product = self.store.products[productId] else {
                    completion({ throw ResponseError.noProducts })
                    return
                }
                completion({ return product })
            }
            else if case .error(let error) = result {
                
                completion({ throw error })
            }
        }
    }
}
