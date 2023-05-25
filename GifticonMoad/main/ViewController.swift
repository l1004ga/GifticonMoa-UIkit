//
//  ViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/17.
//

import UIKit
import Foundation

class ViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet var collectionIamgeView: UICollectionView!
    
    @IBOutlet weak var enableBtn: UIButton!
    
    
    @IBOutlet weak var addViewBtn: UIButton!
    
    
    var ImageArray = [UIImage(systemName: "globe.central.south.asia.fill"), UIImage(systemName: "sunrise"), UIImage(systemName: "cloud.sleet")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collection = collectionIamgeView.collectionViewLayout as! UICollectionViewFlowLayout
        
        collection.itemSize = CGSize(width: 5, height: 5)
        collectionIamgeView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionIamgeView.dataSource = self
        
        
        
    }
    
    @IBAction func addGifiton(_ sender: Any) {

        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen

//        addGifticonVC.mainVC = self
        
        self.present(addGifticonVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GifticonImageCollectionViewCell
        let course = ImageArray[indexPath.item]
        cell.gifticonIamge.image = UIImage(systemName: "face.smiling")
        return cell
        
    }
    
}

