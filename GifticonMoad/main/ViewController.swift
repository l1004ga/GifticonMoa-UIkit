//
//  ViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/17.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // coreData가 선언되어 있는 AppDelegate를 가져와서 사용할 수 있도록 해줌
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var gifticonList : [GifticonList] = [GifticonList]()
    
    @IBOutlet var collectionIamgeView: UICollectionView!
    
    @IBOutlet weak var enableBtn: UIButton!
    
    
    @IBOutlet weak var addViewBtn: UIButton!
    
    
    var ImageArray = [UIImage(systemName: "globe.central.south.asia.fill"), UIImage(systemName: "sunrise"), UIImage(systemName: "cloud.sleet")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collection = self.collectionIamgeView.collectionViewLayout as! UICollectionViewFlowLayout
        
        collection.itemSize = CGSize(width: 5, height: 5)
        self.collectionIamgeView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionIamgeView.dataSource = self
        self.collectionIamgeView.delegate = self
        
        fetchGifticonData()
        self.collectionIamgeView.reloadData()
        
        
        
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

        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen
        // 아래 delegate 연결을 해놔야 AddGifticonViewControllerDelegate로 호출 가능
        addGifticonVC.delegate = self
        
        self.present(addGifticonVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gifticonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GifticonImageCollectionViewCell
//        let course = ImageArray[indexPath.item]
        cell.gifticonIamge.image = UIImage(data: gifticonList[indexPath.row].imageInfo ?? Data())
        //Dday
//        cell.gifticonDday.text = gifticonList[indexPath.row].date
        
        //교환처
        cell.gifticonStore.text = gifticonList[indexPath.row].store
        
        //금액
        cell.gifticonMoney.text = String(gifticonList[indexPath.row].amount) + "원"
        
        // 유효기간
        if let expireData = gifticonList[indexPath.row].expiration {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            cell.gifticonExpire.text = dateFormatter.string(from: expireData)
        } else {
            cell.gifticonExpire.text = "입력필요"
        }
        
        
        // Design for cell
        cell.layer.borderColor = UIColor.mainColor?.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 15
        cell.gifticonIamge.backgroundColor = UIColor.gifticonBackColor
//        cell.gifticonIamge.contentMode = .scaleAspectFill
        // Design for cell
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("로그 잘 찍히는가?")
        
        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen
        // 아래 delegate 연결을 해놔야 AddGifticonViewControllerDelegate로 호출 가능
        addGifticonVC.delegate = self
        addGifticonVC.selectedGifticon = gifticonList[indexPath.row]
        
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
        // 불러온 데이터를 뷰에 재로딩해줌
        self.collectionIamgeView.reloadData()
    }
    
    
}
