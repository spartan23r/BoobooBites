//
//  PurchaseStore.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI
import StoreKit
import Combine

@MainActor
final class PurchaseStore: ObservableObject {
	
	@Published private(set) var products: [Product] = []
	
	let premiumProductID = "com.spartan23r.BoobooBites.premium"
	
	init() {
		updates = Task {
			for await update in StoreKit.Transaction.updates {
				if let transaction = try? update.payloadValue {
					await fetchActiveTransactions()
					await transaction.finish()
				}
			}
		}
	}
	
	deinit {
		updates?.cancel()
	}
	
	@Published private(set) var activeTransactions: Set<StoreKit.Transaction> = []
	private var updates: Task<Void, Never>?
	
	func purchase(_ product: Product) async throws {
		let result = try await product.purchase()
		switch result {
		case .success(let verificationResult):
			if let transaction = try? verificationResult.payloadValue {
				activeTransactions.insert(transaction)
				await transaction.finish()
				
				ProAccessManager.premiumPurchased = true
				
			}
		case .userCancelled:
			break
		case .pending:
			break
		@unknown default:
			break
		}
	}
	
	func fetchActiveTransactions() async {
		var activeTransactions: [String] = []
		
		for await entitlement in StoreKit.Transaction.currentEntitlements {
			if let transaction = try? entitlement.payloadValue {
				activeTransactions.append(transaction.productID)
				
				ProAccessManager.premiumPurchased = true
				
			}
		}
		
		updateProAccess(activeTransactions: activeTransactions)
	}
	
	private func updateProAccess(activeTransactions: [String]) {
		if activeTransactions.contains(premiumProductID) { ProAccessManager.premiumPurchased = true } else { ProAccessManager.premiumPurchased = false }
	}
	
	private func printInAppPurchasesStatus() {
		print("\n\n STATUS PREMIUM ACCESS: \(ProAccessManager.premiumPurchased)")
	}
}

struct ProAccessManager {
	
	// premium access
	@AppStorage("premiumPurchased") static var premiumPurchased: Bool = false
}
