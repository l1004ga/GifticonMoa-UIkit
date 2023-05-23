//
//  ViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/17.
//

import UIKit
import CollectionViewPagingLayout

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var enableBtn: UIButton!
    
    
    @IBOutlet weak var addViewBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addGifiton(_ sender: Any) {

        let storyboard = UIStoryboard.init(name: "AddGifticon", bundle: nil)
        
        guard let addGifticonVC = storyboard.instantiateViewController(withIdentifier: "AddGifticonViewController") as? AddGifticonViewController else { return }
        
        addGifticonVC.modalPresentationStyle = .fullScreen

//        addGifticonVC.mainVC = self
        
        self.present(addGifticonVC, animated: true)
    }
    
}

