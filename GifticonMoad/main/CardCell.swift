//
//  CardCell.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/17.
//

import UIKit
import CollectionViewPagingLayout

class CardCell: UICollectionViewCell {

    @IBOutlet weak var gifticonImage: UIImageView!
    @IBOutlet weak var dDay: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}

