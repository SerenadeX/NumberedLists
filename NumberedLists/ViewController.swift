//
//  ViewController.swift
//  NumberedLists
//
//  Created by Rhett Rogers on 3/7/16.
//  Copyright © 2016 LyokoTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: textView, attribute: .Width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: textView, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: textView, attribute: .CenterY, multiplier: 1, constant: 0))
        textView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 400))
        
        textView.delegate = self
        
        view.backgroundColor = UIColor.blueColor()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(textView: UITextView) {
        print(textView.selectedRange)
    }
    
}
