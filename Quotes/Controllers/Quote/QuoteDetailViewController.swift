//
//  QuoteDetailViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 17/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import Photos
import CoreData

class QuoteDetailViewController: UIViewController {
    
    // MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    lazy var updateAppContextService = UpdateAppContextService()
    lazy var moveCollectionService = MoveCollectionService()
    
    let size = 30
    
    lazy var heartImage = UIIconExtension.init(size: size).heart()
    lazy var unheartImage = UIIconExtension.init(size: size).unheart()
    
    var source: String? {
        didSet {
            
        }
    }
    
    var quote: Quote? {
        didSet {
            updateUI()
        }
    }
    
    var color: UIColor = .white {
        didSet {
        }
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var favouriteButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var downloadButton: UIBarButtonItem!
    @IBOutlet var moveButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteLabel.text = quote?.quote
        authorLabel.text = quote?.author
        backgroundView.backgroundColor = color
        
//        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
    // MARK: - IBAction
    @IBAction func downloadClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case PHAuthorizationStatus.authorized:
            downloadPhotos()
            
        case PHAuthorizationStatus.denied:
            
            let alertController = UIAlertController(title: "Please Allow Access to your Photo Library",
                                                    message: "This allows Quotes to save photos to your photo library.",
                                                    preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization { (response) in
                if response == PHAuthorizationStatus.authorized {
                    self.downloadPhotos()
                }
            }
            
        case PHAuthorizationStatus.restricted:
            break
        default:
            break
        }
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        let image = generateImage()
        
        let text = "Quotes: Place to collect quote\n\nhttps://apps.apple.com/app/id1476059661\n\n#Quotes"
        
        let activityViewController = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func favouriteClicked(_ sender: Any) {
        guard quote != nil else { return }
        
        selectionHaptic.selectionChanged()
        
        var isPin = true
        if quote?.isPin == true {
            isPin = false
            
            favouriteButton.image = unheartImage
            
        } else {
            isPin = true
            
            favouriteButton.image = heartImage
            
        }
        
        quote!.setValue(isPin, forKey: "isPin")
        quote!.setValue(Date(), forKey: "updatedOn")
        
        saveContext()
        
        endManage()
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        guard quote != nil else { return }
        
        selectionHaptic.selectionChanged()
        
        let moveCollectionVC = moveCollectionService.show(quotes: [quote!])
        moveCollectionVC.delegate = self
        
        self.present(moveCollectionVC, animated: true)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        guard quote != nil else { return }
        
        selectionHaptic.selectionChanged()
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteQuote()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.mainBlue()
        
        present(alert, animated: true)
    }
    
    
    // MARK: - Objc Functions
    @objc func savedPhotosAlbumCompleted(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)  {
        if error != nil {
            self.downloadButton.tintColor = .red
            
            DispatchQueue.main.async {
                self.downloadButton.tintColor = .white
            }
        } else {
            let deadline = DispatchTime.now() + .milliseconds(200)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                
                DispatchQueue.main.asyncAfter(deadline: deadline + .milliseconds(500)) {
                    self.downloadButton.tintColor = .white
                }
            }
        }
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        endManage()
    }
    
    // MARK: - Functions
    func setupGesture() {
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        backgroundView.addGestureRecognizer(tapped)
    }
    
    func updateUI() {
        if quoteLabel != nil {
            quoteLabel.text = quote?.quote
        }
        
        if authorLabel != nil {
            authorLabel.text = quote?.author
        }
        
        let downloadImage = UIIconExtension.init(size: size).download()
        let editImage = UIIconExtension.init(size: 27).edit()
        let folderImage = UIIconExtension.init(size: size).folder()
        let trashImage = UIIconExtension.init(size: size).delete()
        let shareImage = UIIconExtension.init(size: 30).share()
        
        deleteButton.image = trashImage
        moveButton.image = folderImage
        downloadButton.image = downloadImage
        editButton.image = editImage
        shareButton.image = shareImage
        
        if quote!.isPin == true {
            favouriteButton.image = heartImage
        } else {
            favouriteButton.image = unheartImage
        }
    }
    
    func downloadPhotos() {
        downloadButton.tintColor = UIColor.mainYellow()
        
        let image = generateImage()
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedPhotosAlbumCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func generateImage() -> UIImage {
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        backgroundView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
    
    func deleteQuote() {
        context.delete(quote!)
        
        saveContext()
        
        if source == "QuoteViewController" {
            performSegue(withIdentifier: "BackToQuoteView", sender: self)
        } else if source == "CollectionQuoteViewController" {
            performSegue(withIdentifier: "BackToCollectionQuoteView", sender: self)
        }
    }
    
    func endManage() {
        //        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func saveContext() {
        do {
            try context.save()
            updateAppContext()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func updateAppContext() {
        updateAppContextService.updateAppContext()
    }
    
    
    // MARK: - Unwind Segue
    @IBAction func backToQuoteDetailView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        
        switch segue.identifier {
        case "goToEditQuoteView":
            selectionHaptic.selectionChanged()
            
            print("Let's go to edit quote view")
            let destination = segue.destination as! EditQuoteViewController
            destination.quote = quote?.quote ?? ""
            destination.author = quote?.author ?? ""
            destination.objectId = quote?.objectID
            
        default:
            print("unknown segue identifier")
        }
    }
}


// MAKR: - MoveCollectionViewControllerDelegate
extension QuoteDetailViewController: MoveCollectionViewControllerDelegate {
    func handleDismissal(endEditMode: Bool, reload: Bool) {
        if endEditMode {
            self.endManage()
        }
    }
}
