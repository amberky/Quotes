//
//  ActionSheetViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class ActionSheetViewController: UIViewController {

    var cell = QuoteTableViewCell()
    
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        print("tapped")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        print("copy")
        guard let quote = cell.quoteLabel.text
            else { return }
        
        let copy = UIPasteboard.general
        copy.string = quote
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editClicked(_ sender: Any) {
        print("edit")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        print("move")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        print("share")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        print("cancel")
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
