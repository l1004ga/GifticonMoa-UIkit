//
//  ViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/17.
//

import UIKit
import Foundation
import CoreData
import UserNotifications
import GoogleMobileAds

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GADFullScreenContentDelegate {
    
    private var rewardedAd: GADRewardedAd?
    
    var defaults : Int = 0
    
    // coreData가 선언되어 있는 AppDelegate를 가져와서 사용할 수 있도록 해줌
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var gifticonList : [GifticonList] = [GifticonList]()
    
    var gifticonEnable : [GifticonList]?
    
    var gifticonDisable : [GifticonList]?
    
    // 기프티콘상태 버튼 변경 확인용 변수
    var usingStatus : Bool = true
    
    var gifticonCount : Int = 0
    
    let emptyView : UIView = {
        let emptyView = UIView()
        let iv = UIImageView()
        iv.image = UIImage(named:"emptyCards")
        iv.contentMode = .scaleAspectFit
        iv.frame.size.height = 300
        iv.frame.size.width = 100
        emptyView.addSubview(iv)
        let label = UILabel()
        label.text = "신규 기프티콘을 생성해주세요"
        label.textColor = UIColor.gray
        label.frame.size.width = 300
        emptyView.addSubview(label)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        iv.topAnchor.constraint(equalTo: emptyView.safeAreaLayoutGuide.topAnchor, constant: 100.0).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 20.0).isActive = true
        return emptyView
    }()
    
    @IBOutlet weak var gifticonImage: UIImageView!
    
    @IBOutlet var mainview: UIView!
    
    @IBOutlet var collectionIamgeView: UICollectionView!
    
    @IBOutlet weak var enableBtn: UIButton!
    
    @IBOutlet weak var disableBtn: UIButton!
    
    @IBOutlet weak var addViewBtn: UIButton!
    
    var gifticonStatus : Bool = true
    
    var ImageArray = [UIImage(systemName: "globe.central.south.asia.fill"), UIImage(systemName: "sunrise"), UIImage(systemName: "cloud.sleet")]

    
    func gifticonStatusParsing() {
        self.gifticonEnable = gifticonList.filter{ $0.status == true }
        self.gifticonEnable?.sort(by: { first, second in
            if first.expiration! < second.expiration! {
                return true
            }
            return false
        })
        self.gifticonDisable = gifticonList.filter{ $0.status == false }
        self.gifticonDisable?.sort(by: { first, second in
            if first.expiration! < second.expiration! {
                return true
            }
            return false
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(emptyView)
//        emptyView.addSubview(emptyImage)
////        emptyView.addSubview(emptyLabel)
        
        loadRewardedAd()
        defaults = UserDefaults.standard.integer(forKey: "gifticonCount")

        fetchGifticonData()
        gifticonStatusParsing()
        
        let collection = self.collectionIamgeView.collectionViewLayout as! UICollectionViewFlowLayout
        
        collection.itemSize = CGSize(width: 5, height: 5)
        self.collectionIamgeView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionIamgeView.dataSource = self
        self.collectionIamgeView.delegate = self
        
        self.collectionIamgeView.reloadData()
        
        // 뷰 로딩 시 기본 버튼 Title Color
        self.enableBtn.setTitle("사용가능", for: .normal)
        self.disableBtn.setTitle("사용완료", for: .normal)
        self.enableBtn.setTitleColor(.mainColor, for: .normal)
        self.disableBtn.setTitleColor(.gray, for: .normal)
        self.enableBtn.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.disableBtn.configuration?.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 0)
        
        // 기프티콘 상태변경 버튼 터치 시 이벤트 탐색
        enableBtn.addTarget(self, action: #selector(statusEnable), for: .touchUpInside)
        
        disableBtn.addTarget(self, action: #selector(statusDisable), for: .touchUpInside)
    }
    
    @IBAction func statusEnable(_ sender: Any) {
        self.usingStatus = true
        statusDesign()
        self.fetchGifticonData()
        // 불러온 데이터를 뷰에 재로딩해줌
        self.collectionIamgeView.reloadData()
    }
    
    @IBAction func statusDisable(_ sender: Any) {
        self.usingStatus = false
        statusDesign()
        self.fetchGifticonData()
        // 불러온 데이터를 뷰에 재로딩해줌
        self.collectionIamgeView.reloadData()
    }
    
    @objc func statusDesign() {
        if usingStatus {
            self.enableBtn.setTitle("사용가능", for: .normal)
            self.disableBtn.setTitle("사용완료", for: .normal)
            self.enableBtn.setTitleColor(.mainColor, for: .normal)
            self.disableBtn.setTitleColor(.gray, for: .normal)
        } else {
            self.enableBtn.setTitle("사용가능", for: .normal)
            self.disableBtn.setTitle("사용완료", for: .normal)
            self.enableBtn.setTitleColor(.gray, for: .normal)
            self.disableBtn.setTitleColor(.mainColor, for: .normal)
        }
    }
    
    // coreData로 Local저장소에 있는걸 불러옴
    func fetchGifticonData() {
        let fetchRequest : NSFetchRequest<GifticonList> = GifticonList.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        
        do {
            self.gifticonList = try context.fetch(fetchRequest)
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func addGifiton(_ sender: Any) {
        
        if self.gifticonCount >= 5 {
            
            let alert = UIAlertController(title: "기프티콘 개수 초과", message: "추가로 기프티콘을 생성을 위해 광고를 시청하시겠습니까?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {[self]_ in
                showRewardedAd(
                        viewController: self)
            })
            let no = UIAlertAction(title: "No", style: .destructive, handler: nil)
            alert.addAction(no)
            alert.addAction(yes)
            present(alert, animated: true, completion: nil)
        }

        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen
        // 아래 delegate 연결을 해놔야 AddGifticonViewControllerDelegate로 호출 가능
        addGifticonVC.delegate = self
        
        self.present(addGifticonVC, animated: true)
    }
    
    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) { [self] ad, error in
            if let error = error {
                print("Failed to load reward ad with error: \(error.localizedDescription)")
                return
            }
            
            rewardedAd = ad
            rewardedAd?.fullScreenContentDelegate = self
            print(#function, "Rewarded loaded")
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadRewardedAd()
        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen
        // 아래 delegate 연결을 해놔야 AddGifticonViewControllerDelegate로 호출 가능
        addGifticonVC.delegate = self
        
        self.present(addGifticonVC, animated: true)
    }
    
    func showRewardedAd(viewController: UIViewController) {
        print("Rewarded 수행됨")
        if rewardedAd != nil {
            rewardedAd!.present(fromRootViewController: viewController, userDidEarnRewardHandler: {
                let reward = self.rewardedAd!.adReward
                print("\(reward.amount) \(reward.type)")
            })
        } else {
            print("RewardedAd wasn't ready")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let enableGifticon = self.gifticonEnable else {
            return self.gifticonList.count
        }
        
        guard let disableGifticon = self.gifticonDisable else {
            return self.gifticonList.count
        }
        
        if self.usingStatus {
            if enableGifticon.count == 0 {
                collectionIamgeView.backgroundView = emptyView
            } else {
                collectionIamgeView.backgroundView = .init()
            }
            return enableGifticon.count
        } else {
            print(disableGifticon.count)
            
            if disableGifticon.count == 0 {
                collectionIamgeView.backgroundView = emptyView
            } else {
                collectionIamgeView.backgroundView = .init()
            }
            
            return disableGifticon.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // collectionViewCell 형식의 cell 변수 선언
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GifticonImageCollectionViewCell
        
        guard let enableGifticon = self.gifticonEnable else {
            return cell }
        
        guard let disableGifticon = self.gifticonDisable else {
            return cell
            
        }
        
        let collectionviewWidth = self.collectionIamgeView.frame.size.width
        
        // width frame 크기가 260이 아닌 282로 나옴 -> 같은 크기인 height로 대체
//        let collectionCellWidth = cell.gifticonIamge.frame.size.width
        
        let collectionCellWidth = cell.gifticonInfo.frame.width
        
        // 광고 생성을 위한 기프티콘 개수 확인
        self.gifticonCount = enableGifticon.count + disableGifticon.count
        
        if self.usingStatus {
            
            if enableGifticon.count == 1 {
                
                print("collectionviewWidth: \(collectionviewWidth) collectionCellWidth : \(collectionCellWidth)")
                self.collectionIamgeView.contentInset = UIEdgeInsets.init(top: 0, left: (collectionviewWidth - collectionCellWidth) / 2, bottom: 0, right: 0)
                
            } else {
                
                self.collectionIamgeView.contentInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
                
            }
            
            //이미지
            cell.gifticonIamge.image = UIImage(data: enableGifticon[indexPath.row].imageInfo ?? Data())
            
            //교환처
            cell.gifticonStore.text = enableGifticon[indexPath.row].store
            
            //금액
            cell.gifticonMoney.text = String(enableGifticon[indexPath.row].amount) + "원"
            
            // 유효기간
            if let expireData = enableGifticon[indexPath.row].expiration {
                
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                var dDayCount : Int = 0
                dateFormatter.dateFormat = "yyyy/MM/dd"
                dDayCount = calendar.dateComponents([.day], from: dateFormatter.date(from: dateFormatter.string(from: expireData)) ?? expireData, to: dateFormatter.date(from: dateFormatter.string(from: Date())) ?? Date()).day!
                
                switch dDayCount {
                case 0:
                    cell.gifticonDday.text = String("D-Day")
                case ..<0:
                    cell.gifticonDday.text = String("D\(dDayCount)")
                case 1...:
                    cell.gifticonDday.text = String("D+\(dDayCount)")
                default:
                    cell.gifticonDday.text = String("D-Day")
                }
                
                cell.gifticonExpire.text = dateFormatter.string(from: expireData)
            } else {
                cell.gifticonExpire.text = "입력필요"
            }
        } else {
            
            if disableGifticon.count == 1 {
                
                print("뷰 가로 : \(collectionviewWidth), 셀 가로 : \(collectionCellWidth)")
                
                self.collectionIamgeView.contentInset = UIEdgeInsets.init(top: 0, left: (collectionviewWidth - collectionCellWidth) / 2, bottom: 0, right: 0)
                
            } else {
                self.collectionIamgeView.contentInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
                
            }
            
            //이미지
            cell.gifticonIamge.image = UIImage(data: disableGifticon[indexPath.row].imageInfo ?? Data())
            
            //교환처
            cell.gifticonStore.text = disableGifticon[indexPath.row].store
            
            //금액
            cell.gifticonMoney.text = String(disableGifticon[indexPath.row].amount) + "원"
            
            // 유효기간
            if let expireData = disableGifticon[indexPath.row].expiration {
                
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                var dDayCount : Int = 0
                dateFormatter.dateFormat = "yyyy/MM/dd"
                dDayCount = calendar.dateComponents([.day], from: dateFormatter.date(from: dateFormatter.string(from: expireData)) ?? expireData, to: dateFormatter.date(from: dateFormatter.string(from: Date())) ?? Date()).day!
                
                switch dDayCount {
                case 0:
                    cell.gifticonDday.text = String("D-Day")
                case ..<0:
                    cell.gifticonDday.text = String("D\(dDayCount)")
                case 1...:
                    cell.gifticonDday.text = String("D+\(dDayCount)")
                default:
                    cell.gifticonDday.text = String("D-Day")
                }
                
                cell.gifticonExpire.text = dateFormatter.string(from: expireData)
            } else {
                cell.gifticonExpire.text = "입력필요"
            }
        }
        
        // Design for cell
        cell.layer.borderColor = UIColor.mainColor?.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 15
        cell.gifticonIamge.backgroundColor = UIColor.gifticonBackColor
        
        return cell
        
    }
    
    
    // Cell 각각 선택 시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen
        // 아래 delegate 연결을 해놔야 AddGifticonViewControllerDelegate로 호출 가능
        addGifticonVC.delegate = self
        //        addGifticonVC.selectedGifticon = gifticonList[indexPath.row]
        
        guard let enableGifticon = self.gifticonEnable else { addGifticonVC.selectedGifticon = gifticonList[indexPath.row]
            return
        }
        
        guard let disableGifticon = self.gifticonDisable else { addGifticonVC.selectedGifticon = gifticonList[indexPath.row]
            return
        }
        
        if self.usingStatus {
            addGifticonVC.selectedGifticon = enableGifticon[indexPath.row]
        } else {
            addGifticonVC.selectedGifticon = disableGifticon[indexPath.row]
        }
        
        self.present(addGifticonVC, animated: true)
    }
}

extension UIColor {
    
    class var mainColor: UIColor? { return UIColor(named: "mainColor") }
    
    class var gifticonBackColor: UIColor? { return
        UIColor(named: "gifticonBackColor")
    }
}

extension ViewController: AddGifticonViewControllerDelegate {
    func didFinishSaveData() {
        // coreData에서 데이터를 불러옴
        self.fetchGifticonData()
        self.gifticonStatusParsing()
        // 불러온 데이터를 뷰에 재로딩해줌
        self.collectionIamgeView.reloadData()
    }
    
    
}

