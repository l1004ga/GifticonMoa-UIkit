//
//  AddGifticonViewController.swift
//  GifticonMoad
//
//  Created by dev on 2023/05/22.
//

import UIKit
import CoreData
import UserNotifications

protocol AddGifticonViewControllerDelegate: AnyObject {
    func didFinishSaveData()
}

class AddGifticonViewController: UIViewController {
    
    weak var delegate : AddGifticonViewControllerDelegate?
    
    @IBOutlet var addImageBtn: UIButton!
    
    @IBOutlet weak var gifticonAddMainView: UIView!
    
    // 기프티콘 정보 작성 관련 변수
    
    @IBOutlet weak var gifticonTitle: UILabel!
    
    @IBOutlet weak var gifticonImage: UIImageView!
    
    @IBOutlet weak var gifticonMoney: UITextField!
    
    @IBOutlet weak var gifticonStore: UITextField!
    
    @IBOutlet weak var gifticonExpire: UIDatePicker!
    
    @IBOutlet weak var gifticonEtc: UITextField!
    
    @IBOutlet weak var gifticonStatus: UIButton!
    
    var usingStatus : Bool = true
    
    // 기프티콘 정보 작성 관련 변수
    
    // 데이터 저장 및 뷰 이동 관련 변수
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // 데이터 저장 및 뷰 이동 관련 변수
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 선택한 기프티콘 있을 시 사용되는 변수
    var selectedGifticon : GifticonList?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        
        //        self.gifticonStatus.backgroundColor = .blue
        self.gifticonStatus.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        self.gifticonStatus.setTitle("사용가능", for: .normal)
        self.gifticonStatus.layer.cornerRadius = 8
        
        print("현재 상태(true) : \(self.usingStatus)")
        
        gifticonStatus.addTarget(self, action: #selector(StatusChange), for: .touchUpInside)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 선택한 기프티콘이 있을 때
        if let hasData = selectedGifticon {
            
            self.gifticonTitle.text = "기프티콘 수정"
            var loadedImage = UIImage(data: hasData.imageInfo ?? Data())
            let ImageViewWidth = self.gifticonImage.frame.size.width
            let scale = ImageViewWidth / loadedImage!.size.width // 0.293
            let height = loadedImage!.size.height * scale
            UIGraphicsBeginImageContextWithOptions(CGSize(width: ImageViewWidth, height: height), false, 0.0)
            loadedImage!.draw(in: CGRect(x: 0, y: 0, width: ImageViewWidth, height: height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.gifticonImage.image = newImage
            
            
            self.gifticonExpire.date = hasData.expiration ?? Date()
            self.gifticonStore.text = hasData.store
            self.gifticonMoney.text = String(hasData.amount)
            self.gifticonEtc.text = hasData.etc
            self.usingStatus = hasData.status
            
            statusDesign()
            
            // 삭제 버튼 보이게
            self.deleteBtn.isHidden = false
        } else {
            self.deleteBtn.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrame.size.height,
            right: 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    
    @IBAction func StatusChange(_ sender: Any) {
        usingStatus.toggle()
        //        gifticonStatus.backgroundColor = usingStatus ? .red : .blue
        
        statusDesign()
    }
    
    @objc func statusDesign() {
        if usingStatus {
            self.gifticonStatus.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
            self.gifticonStatus.setTitle("사용가능", for: .normal)
            print("현재 상태(true) : \(self.usingStatus)")
        } else {
            self.gifticonStatus.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            self.gifticonStatus.setTitle("사용완료", for: .normal)
            print("현재 상태(false) : \(self.usingStatus)")
        }
    }
    
    @IBAction func deleteAddingView(_ sender: Any) {
        
        deleteGifticon()
        self.dismiss(animated: true)
    }
    
    
    @IBAction func backAddingView(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func saveAddingView(_ sender: Any) {
        if selectedGifticon != nil {
            updateGifticon()
        } else {
            saveGifticon()
        }
        
        // mainView를 다시 그려주기 위해 호출
        delegate?.didFinishSaveData()
        
        self.dismiss(animated: true)
    }
    
    func saveGifticon() {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "GifticonList", in: self.appDelegate.persistentContainer.viewContext) else { return }
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: self.appDelegate.persistentContainer.viewContext) as? GifticonList else { return }
        
        // 1.기프티콘 이미지
        // TODO: 이미지가 없을 때 저장 불가 혹은 기본 이미지 저장
        
        if let imageString = gifticonImage.image?.pngData() {
            object.imageInfo = imageString
        }
        
        // 2.교환처
        object.store = gifticonStore.text
        
        // 3. 금액
        // TODO: 금액 String to Int 변환 안됨
        if let moneyString = gifticonMoney.text {
            if let moneyValue = Int64(moneyString) {
                object.amount = moneyValue
            } else {
                object.amount = 0
            }
        }
        // 4. 기타
        object.etc = gifticonEtc.text
        
        // 5. 유효기간
        object.expiration = gifticonExpire.date
        
        // 6. 저장 날짜
        object.date = Date()
        
        // 7. UUID
        object.uuid = UUID()
        
        // 8. 사용가능 상태
        // 처음 등록 시에는 '사용 가능' 상태로 저장됨
        object.status = usingStatus
        
        self.makeRequestNoti(id: object.uuid!, store: object.store! , expiration: object.expiration!)
        
        appDelegate.saveContext()
        
    }
    
    func updateGifticon() {
        
        let context = self.appDelegate.persistentContainer.viewContext
        
        guard let hasData = selectedGifticon else { return }
        
        let fetchRequest: NSFetchRequest<GifticonList> = GifticonList.fetchRequest()
        
        guard let hasUUID = hasData.uuid else { return }
        
        // fetchRequest의 조건을 달 수 있는 포맷
        // uuid는 CVarArg타입이다
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do {
            let loadedData = try context.fetch(fetchRequest)
            loadedData.first?.imageInfo = gifticonImage.image?.pngData()
            loadedData.first?.store = gifticonStore.text
            if let moneyString = gifticonMoney.text {
                if let moneyValue = Int64(moneyString) {
                    loadedData.first?.amount = moneyValue
                } else {
                    loadedData.first?.amount = 0
                }
            }
            loadedData.first?.etc = gifticonEtc.text
            loadedData.first?.expiration = gifticonExpire.date
            loadedData.first?.date = Date()
            loadedData.first?.uuid = hasUUID
            loadedData.first?.status = usingStatus
            
            
        } catch {
            print(error)
        }
        
        appDelegate.saveContext()
    }
    
    func deleteGifticon() {
        
        let context = self.appDelegate.persistentContainer.viewContext
        
        guard let hasData = selectedGifticon else { return }
        
        let fetchRequest: NSFetchRequest<GifticonList> = GifticonList.fetchRequest()
        
        guard let hasUUID = hasData.uuid else { return }
        
        // fetchRequest의 조건을 달 수 있는 포맷
        // uuid는 CVarArg타입이다
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do {
            let loadedData = try context.fetch(fetchRequest)
            
            if let hasData = loadedData.first {
                context.delete(hasData)
                appDelegate.saveContext()
            }
        } catch {
            print(error)
        }
        
        delegate?.didFinishSaveData()
        self.dismiss(animated: true)
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
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [self] () in
            let checkImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            let resizeImage = self.resizeImage(image: checkImage!, width: self.gifticonImage.frame.size.width)
            
            self.gifticonImage.image = resizeImage
            
        }
    }
    
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage? {
        let scale = width / image.size.width // 0.293
        let height = image.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @objc private func makeRequestNoti(id : UUID, store : String, expiration : Date) {
        
        
        let minusSevenDayExpiration = Calendar.current.date(byAdding: .day, value: -7, to: expiration)
        let minusThreeDayExpiration = Calendar.current.date(byAdding: .day, value: -3, to: expiration)
        
        let content = UNMutableNotificationContent()
        content.title = "기프티콘 유효기간이 끝나가요!"
        content.body = "\(store)에서 사용가능한 기프티콘의 유효기간이"
        content.sound = .default
        content.badge = 1
        
        // D-Day 알림
        let dDayDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: expiration)
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: dDayDateComponents, repeats: false)
        let request1 = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger1)
        UNUserNotificationCenter.current()
            .add(request1) { error in
                guard let error = error else { return }
                print(error.localizedDescription)
            }
        print("실행 완료 디데이 저장됨")
        // 7일 전 알림
        let minusSevenDayDateComponets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: minusSevenDayExpiration!)
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: minusSevenDayDateComponets, repeats: false)
        let request2 = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger2)
        UNUserNotificationCenter.current()
            .add(request2) { error in
                guard let error = error else { return }
                print(error.localizedDescription)
            }
        print("실행 완료 7일 전 저장됨")
        let minusThreeDayDateComponets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: minusThreeDayExpiration!)
        let trigger3 = UNCalendarNotificationTrigger(dateMatching: minusThreeDayDateComponets, repeats: false)
        let request3 = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger3)
        UNUserNotificationCenter.current().add(request3) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
        print("실행 완료 3일 전 저장됨")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
