//
//  AddGifticonViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/22.
//

import UIKit

class AddGifticonViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var gifticonImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func ImagePicker(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // 이미지 편집 기능
        
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
    // 이미지 선택 종료 시 실행되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let alert = UIAlertController(title: "취소 알림", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { () in
            let checkImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.gifticonImage.image = checkImage
            
        }
    }
    
}
