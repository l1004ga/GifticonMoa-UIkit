//
//  RewardedHelper.swift
//  GifticonMoad
//
//  Created by leejina on 4/23/24.
//

//import Foundation
//import GoogleMobileAds
//import UIKit
//
//class RewardedHelper: NSObject, GADFullScreenContentDelegate {
//
//    private var rewardedAd: GADRewardedAd?
////    var endSignal : Bool = false
//    
//    func loadRewardedAd() {
//        let request = GADRequest()
//        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) { [self] ad, error in
//            if let error = error {
//                print("Failed to load reward ad with error: \(error.localizedDescription)")
//                return
//            }
//            
//            rewardedAd = ad
//            rewardedAd?.fullScreenContentDelegate = self
//            print(#function, "Rewarded loaded")
//        }
//    }
//    
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("끝나는 로직 실행됨")
//        loadRewardedAd()
////        endSignal.toggle()
//    }
//    
//    func showRewardedAd(viewController: UIViewController) {
//        print("Rewarded 수행됨")
//        if rewardedAd != nil {
//            rewardedAd!.present(fromRootViewController: viewController, userDidEarnRewardHandler: {
//                let reward = self.rewardedAd!.adReward
//                print("\(reward.amount) \(reward.type)")
//            })
//        } else {
//            print("RewardedAd wasn't ready")
//        }
//    }
//}
