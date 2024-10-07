//
//  SubscriptionViewModel.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import Dependencies

class SubscriptionViewModel: ObservableObject{
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.authManager) var authManager
    
    @Published var isLoadingRetrieveProducts = false
    @Published var isLoadingPayment = false

    @Published var showAlert = false
    @Published var title: String = ""
    @Published var payments = [Payment]()
    @Published var selectedProductId: String = ""
    @Published var selectedPayment: Payment?
    @Published var errorMessage: String? = nil

    @Preference(\.isPremiumUser) var isPremiumUser
    @Preference(\.paymentId) var paymentId

    init(){
        initConfiguration()
        let annual = Payment(paymentId: SubscriptionItem.annual.id,
                             index: 0,
                             price: SubscriptionItem.annual.cost,
                             duration: SubscriptionItem.annual.title)
        let monthly = Payment(paymentId: SubscriptionItem.monthly.id,
                              index: 0,
                              price: SubscriptionItem.monthly.cost,
                              duration: SubscriptionItem.monthly.title)

        payments.append(annual)
        payments.append(monthly)

        selectedPayment = annual
        selectedProductId = annual.paymentId
    }

    func initConfiguration(){
        if isPremiumUser {
            checkSubscription(productId: paymentId)
        }
        retrieveProducts()
    }

    func checkSubscription(productId: String){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
            switch result {
                case .success(let receipt):
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            debugPrint("\(productId) is valid until \(expiryDate)\n\(items)\n")
                            self?.isPremiumUser = true
                            self?.updateUserRole(true)
                        case .expired(let expiryDate, let items):
                            debugPrint("\(productId) is expired since \(expiryDate)\n\(items)\n")
                            self?.errorMessage = "Subscription is expired"
                            self?.isPremiumUser = false
                            self?.updateUserRole(false)
                        case .notPurchased:
                            debugPrint("The user has never purchased \(productId)")
//                            self?.isPremiumUser = false
//                            self?.updateUserRole(false)
                    }
                case .error(let error):
                    debugPrint("Receipt verification failed: \(error)")
            }
        }
    }

    func checkRestoreSubscription(productId: String, completion: @escaping (PaymentResult) -> Void){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
        switch result {
            case .success(let receipt):
              // Verify the purchase of a Subscription
              let purchaseResult = SwiftyStoreKit.verifySubscription(
                  ofType: .autoRenewable,
                  productId: productId,
                  inReceipt: receipt)
                  
              switch purchaseResult {
                  case .purchased(let expiryDate, let items):
                      debugPrint("\(productId) is valid until \(expiryDate)\n\(items)\n")
                      self?.isPremiumUser = true
                      self?.updateUserRole(true)
                      completion(PaymentResult(success: true, error: nil))
                  case .expired(let expiryDate, let items):
                      debugPrint("\(productId) is expired since \(expiryDate)\n\(items)\n")
                      self?.errorMessage = "Subscription is expired"
                      self?.isPremiumUser = false
                      self?.updateUserRole(false)
                      completion(PaymentResult(success: false, error: "Subscription is expired"))
                  case .notPurchased:
                      debugPrint("The user has no purchase \(productId)")
                      self?.errorMessage = "Not purchased"
                      self?.isPremiumUser = false
                      self?.updateUserRole(false)
                      completion(PaymentResult(success: false, error: "Not purchased"))
              }
            case .error(let error):
                debugPrint("Receipt verification failed: \(error)")
                completion(PaymentResult(success: false, error: error.localizedDescription))
            }
        }
    }

    func retrieveProducts(){
        isLoadingRetrieveProducts = true
        SwiftyStoreKit.retrieveProductsInfo([PaymentId.annual, PaymentId.monthly]) { result in
            self.isLoadingRetrieveProducts = false
            result.retrievedProducts.forEach { skProduct in
                switch(skProduct.productIdentifier){
                    case PaymentId.annual:
                        self.payments[0].productId = skProduct.productIdentifier
                        self.payments[0].price = skProduct.price.doubleValue
                        self.payments[0].priceLocale = skProduct.localizedPrice ?? "\(skProduct.price)"
                        self.payments[0].currency = skProduct.priceLocale.currencySymbol ?? "USD"
                        self.payments[0].locale =  skProduct.priceLocale
                        break;
                    case PaymentId.monthly:
                        self.payments[1].productId = skProduct.productIdentifier
                        self.payments[1].price = skProduct.price.doubleValue
                        self.payments[1].priceLocale = skProduct.localizedPrice ?? "\(skProduct.price)"
                        self.payments[1].currency = skProduct.priceLocale.currencySymbol ?? "USD"
                        self.payments[1].locale =  skProduct.priceLocale
                        break;
                    default:
                        debugPrint("PaymentViewModel default")
                    break;
                }
            }
        }

        selectedProductId = Constants.annualProductId
        if let product = payments.filter( {$0.paymentId == selectedProductId}).first {
            selectedPayment = product
        }
    }

    func startPayment(with item: SubscriptionItem,
                      completion: @escaping (PaymentResult) -> Void){
        guard 
            let payment = payments.filter( {$0.paymentId == item.productId}).first
        else {
            self.errorMessage = "Subcription failed"
            completion(PaymentResult(success: false, error: nil))
            return
        }
        isLoadingPayment = true
        debugPrint("PaymentManager startPayment => \(payment.paymentId)")
        SwiftyStoreKit.purchaseProduct(payment.productId, quantity: 1, atomically: true) {[weak self] result in
            self?.isLoadingPayment = false
            switch result {
                case .success(let purchase):
                    debugPrint("PaymentManager success => \(purchase.productId)")
                    self?.isPremiumUser = true
                    self?.updateUserRole(true)
                    completion(PaymentResult(success: true, error: nil))
                case .error(let error):
                    self?.updateUserRole(false)
                    if let _error = PaymentErrorHandler.map(from: error){
                        self?.errorMessage = _error.localized
                        debugPrint("PaymentManager error => \(_error)")
                        completion(PaymentResult(success: false, error: _error))
                    } else {
                        self?.errorMessage = "Subcription failed"
                        completion(PaymentResult(success: false, error: nil))
                    }
                case .deferred(purchase: let purchase):
                    debugPrint("PaymentManager deferred => \(purchase.productId)")
                    completion(PaymentResult(success: false, error: nil))
            }
        }
    }

    func restorePurchases(completion: @escaping (PaymentResult) -> Void){
        debugPrint("PaymentManager restorePurchases")
        isLoadingPayment = true

        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            debugPrint("PaymentManager restorePurchases results => \(results)")
            if results.restoreFailedPurchases.count > 0 {
                self?.isLoadingPayment = false
                self?.errorMessage = "No restored purchase"
                completion(PaymentResult(success: false,error: nil))
            } else if results.restoredPurchases.count > 0 {
                if let purchase =  results.restoredPurchases.first{
                    self?.checkRestoreSubscription(productId: purchase.productId, completion: { result in
                        self?.isLoadingPayment = false
                        completion(PaymentResult(success: result.success, error: result.error))
                    })
                }
            } else {
                self?.isLoadingPayment = false
                self?.errorMessage = "No restored purchase"
                completion(PaymentResult(success: false, error: "No restored purchase"))
            }
        }
    }
    
    private func updateUserRole(_ isPaid: Bool) {
        let userId = authManager.currentUserId ?? ""
        Task { [weak self] in
            do{
                if !userId.isEmpty {
                    try await self?.dataManager.updatePaidUser(userId: userId, isPaid: isPaid)
                }
            } catch {
                debugPrint("Error updating paid user role: \(error)")
            }
        }
    }
}

struct PaymentResult{
  var success: Bool
  var error: String?
}

struct PaymentErrorHandler{
    static func map(from error: SKError) -> String? {
        var errorDescription : String? = nil
        switch error.code {
            case .unknown:
              errorDescription = "Unknown error. Please contact support"
            case .clientInvalid:
              errorDescription = "Not allowed to make the payment"
            case .paymentCancelled:
              errorDescription = "Payment cancelled"
            case .paymentInvalid:
              errorDescription = "The purchase identifier was invalid"
            case .paymentNotAllowed:
              errorDescription = "The device is not allowed to make the payment"
            case .storeProductNotAvailable:
              errorDescription = "The product is not available in the current storefront"
            case .cloudServicePermissionDenied:
              errorDescription = "Access to cloud service information is not allowed"
            case .cloudServiceNetworkConnectionFailed:
              errorDescription = "Could not connect to the network"
            case .cloudServiceRevoked:
              errorDescription = "User has revoked permission to use this cloud service"
            default:
              errorDescription = (error as NSError).localizedDescription
        }
        return errorDescription
    }
}


class PaymentId {
    static let shared = PaymentId()
    static let monthly = Constants.monthlyProductId
    static let annual = Constants.annualProductId

    private init() {}
}

extension SKProduct {
    func introductoryPrice() -> String?{
        if introductoryPrice != nil {
            let period = introductoryPrice!.subscriptionPeriod.unit
            var periodString = ""
            switch period {
                case .day:
                  periodString = String(localized: "day")
                case .month:
                  periodString = String(localized: "month")
                case .week:
                  periodString = String(localized: "week")
                case .year:
                  periodString = String(localized: "year")
                default:
                  break
            }
            let unitCount = introductoryPrice!.subscriptionPeriod.numberOfUnits
            let unitString = unitCount == 1 ? periodString : "\(unitCount) \(periodString)s"
            return "\(unitString) \(String(localized: "for FREE"))"
        }
        return nil
    }
}

struct Payment: Identifiable{
    let id = UUID()
    let paymentId: String
    var productId: String = ""
    var index: Int
    var price: Double = 0
    var duration: String
    var priceLocale: String = ""
    var locale: Locale = Locale.current
    var currency = "USD"

    init(paymentId: String, index: Int, price: Double, duration: String) {
        self.paymentId = paymentId
        self.index = index
        self.price = price
        self.duration = duration
    }
}

extension Payment{
  func weeklyPrice() -> String {
    let aprice: Double = price
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = locale
    return formatter.string(from: aprice as NSNumber)!
  }
  func monthlyPrice() -> String {
    let aprice: Double = price
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = locale
    return formatter.string(from: aprice as NSNumber)!
  }
}
