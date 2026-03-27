//
//  Paywall.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI
import StoreKit
import Combine

#Preview {
	Paywall(isPresented: .constant(false))
		.environmentObject(PurchaseStore())
}

struct Paywall: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject private var purchaseStore: PurchaseStore
	
	// view properties
	@State private var activeCard: Card? = paywallCards.first
	@State private var scrollView: UIScrollView?
	@State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
	@State private var initialAnimation: Bool = false
	@State private var titleProgress: CGFloat = 0
	
	private func restore() async -> Bool {
		return ((try? await AppStore.sync()) != nil)
	}
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			ZStack {
				/// Ambient Background View
				AmbientBackground()
					.animation(.easeInOut(duration: 1), value: activeCard)
				
				VStack {
					
					ScrollView {
						
						VStack(spacing: 24) {
							
							InfiniteScrollView(collection: paywallCards) { card in
								CarouselCardView(card)
							} uiScrollView: {
								scrollView = $0
							} onScroll: {
								updateActiveCard()
							}
							.scrollIndicators(.hidden)
							.scrollClipDisabled()
							.containerRelativeFrame(.vertical) { value, _ in
								value * 0.45
							}
							.visualEffect { [initialAnimation] content, proxy in
								content
									.offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
							}
							
							VStack(spacing: 12) {
								
								SaleBubbleView()
									.blurOpacityEffect(initialAnimation)
								
								VStack(alignment: .center, spacing: 6) {
									
									Text("Booboo Bites +")
										.font(.largeTitle.bold())
										.blurOpacityEffect(initialAnimation)
									
									Text("Ready to cook without limits?")
										.font(.callout)
										.foregroundStyle(.secondary)
										.blurOpacityEffect(initialAnimation)
										.multilineTextAlignment(.center)
									
								}
								
								VStack(alignment: .center, spacing: 6) {
									Label(PaywallMessage.recipes.paywallDescription, systemImage: PaywallMessage.recipes.paywallImage)
									Label(PaywallMessage.mealplans.paywallDescription, systemImage: PaywallMessage.mealplans.paywallImage)
									Label(PaywallMessage.ingredients.paywallDescription, systemImage: PaywallMessage.ingredients.paywallImage)
								}
								.blurOpacityEffect(initialAnimation)
								.font(.callout.bold())
								.multilineTextAlignment(.center)
								.fixedSize(horizontal: false, vertical: true)
								
							}
							.foregroundStyle(.white)
							
						}
						
					}
					.scrollIndicators(.hidden)
					.scrollBounceBehavior(.basedOnSize)
					
					if Date.isDateInSaleRange() {
						Text("On sale for a limited time!")
							.font(.caption)
							.foregroundStyle(.red)
							.foregroundStyle(.secondary)
					}
					
					ProductView(id: purchaseStore.premiumProductID) { _ in
						Image(systemName: "crown")
							.foregroundStyle(.yellow)
							.symbolVariant(.fill)
							.phaseAnimator([true, false]) { content, phase in
								content
									.scaleEffect(phase ? 1.01 : 1.0)
							} animation: { phase in
									.spring
							}
					} placeholderIcon: {
						ProgressView()
					}
					.tint(.yellow)
					.productViewStyle(.compact)
					.foregroundStyle(.white)
					.onInAppPurchaseCompletion { product, result in
						switch result {
						case .success(let result):
							switch result {
							case .success(_):
								popView()
							case .pending: print("Pending Action")
							case .userCancelled: print("User Cancelled")
							@unknown default:
								fatalError()
							}
						case .failure(let error):
							print(error.localizedDescription)
						}
					}
					.padding()
					.glassEffectStyle()
					
					VStack {
						Text("One-time purchase. No subscription.")
						Text("Pay once, keep forever")
					}
					.font(.caption)
					.foregroundStyle(.secondary)
					
				}
				.safeAreaPadding(15)
			}
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						popView()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button {
						Task {
							await restore()
						}
					} label: {
						Text("Restore")
					}
				}
				
			}
			.onReceive(timer) { _ in
				if let scrollView = scrollView {
					scrollView.contentOffset.x += 0.35
				}
			}
			.task {
				try? await Task.sleep(for: .seconds(0.35))
				
				withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
					initialAnimation = true
				}
				
				withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
					titleProgress = 1
				}
			}
			.environment(\.colorScheme, .dark)
			.interactiveDismissDisabled()
		}
	}
}

extension Paywall {
	
	private func popView() {
		timer.upstream.connect().cancel()
		isPresented.toggle()
	}
	
	private func updateActiveCard() {
		if let currentScrollOffset = scrollView?.contentOffset.x {
			let activeIndex = Int((currentScrollOffset / 220).rounded()) % paywallCards.count
			guard activeCard?.id != paywallCards[activeIndex].id else { return }
			activeCard = paywallCards[activeIndex]
		}
	}
	
	@ViewBuilder
	private func AmbientBackground() -> some View {
		GeometryReader {
			let size = $0.size
			
			ZStack {
				ForEach(paywallCards) { card in
					/// You can use downsized image for this, but for the video tutorial purpose, I'm going to use the actual Image!
					Image(card.image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.ignoresSafeArea()
						.frame(width: size.width, height: size.height)
					/// Only Showing active Card Image
						.opacity(activeCard?.id == card.id ? 1 : 0)
				}
				
				Rectangle()
					.fill(.black.opacity(0.45))
					.ignoresSafeArea()
			}
			.compositingGroup()
			.blur(radius: 90, opaque: true)
			.ignoresSafeArea()
		}
	}
	
	/// Carousel Card View
	@ViewBuilder
	private func CarouselCardView(_ card: Card) -> some View {
		GeometryReader {
			let size = $0.size
			
			Image(card.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: size.width, height: size.height)
				.clipShape(.rect(cornerRadius: 20))
				.shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
		}
		.frame(width: 220)
		.scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
			content
				.offset(y: phase == .identity ? -10 : 0)
				.rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
		}
	}
	
}

extension View {
	func blurOpacityEffect(_ show: Bool) -> some View {
		self
			.blur(radius: show ? 0 : 2)
			.opacity(show ? 1 : 0)
			.scaleEffect(show ? 1 : 0.9)
	}
}
