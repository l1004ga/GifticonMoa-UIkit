//
//  AddGifticonViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/22.
//

import UIKit

class AddGifticonViewController: UIViewController {
    
    
    @IBOutlet var addImageBtn: UIButton!
    
    @IBOutlet weak var gifticonImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func ImagePicker(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary

        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
}

extension AddGifticonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 이미지 선택 종료 시 실행되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let alert = UIAlertController(title: "취소 알림", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [self] () in
            var checkImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            print("받은 사진 가로, 세로 : [\(checkImage!.size.width), \(checkImage!.size.height)]")
            
            print("기본프레임 : [\(self.gifticonImage.frame.size.width), \(self.gifticonImage.frame.size.height)]")
            
            let resizeImage = self.resizeImage(image: checkImage!, width: self.gifticonImage.frame.size.width)
            
            
            self.gifticonImage.image = resizeImage
            
        }
    }
    
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
        let scale = width / image.size.width // 0.293
        let height = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

//guard let pickImagewidth = checkImage?.size.width else { return }

//guard let pickImageheight = checkImage?.size.height else { return }

//let ratio = pickImageheight / pickImagewidth
//            let scaleHeight = pickImageheight * ratio
//
//            self.gifticonImage.frame.size.width = pickImagewidth
//
//            self.gifticonImage.frame.size.height = scaleHeight
//
//            self.gifticonImage.contentMode = .scaleAspectFit
