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
    var triggerButton = UIButton(type: .InfoLight)
    var numberedListTrailer = ".\u{00A0}"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        view.addSubview(triggerButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        triggerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: textView, attribute: .Width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: textView, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: textView, attribute: .CenterY, multiplier: 1, constant: 0))
        textView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 400))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: triggerButton, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: triggerButton, attribute: .Top, multiplier: 1, constant: -100))
        triggerButton.addConstraint(NSLayoutConstraint(item: triggerButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 22))
        triggerButton.addConstraint(NSLayoutConstraint(item: triggerButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 22))

        triggerButton.addTarget(self, action: "toggleNumberedList", forControlEvents: .TouchUpInside)

        textView.delegate = self
        
        view.backgroundColor = UIColor.blueColor()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Removes text from a textView at a specified index
    ///
    /// - parameter range: The range of the text to remove.
    /// - parameter toTextView: The `UITextView` to remove the text from.
    func removeTextFromRange(range: NSRange, fromTextView textView: UITextView) {
        textView.textStorage.beginEditing()
        textView.textStorage.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: ""))
        textView.textStorage.endEditing()
        textView.selectedRange.location -= range.length
    }

    /// Adds text to a textView at a specified index
    ///
    /// - parameter text: The text to add.
    /// - parameter toTextView: The `UITextView` to add the text to.
    /// - parameter atIndex: The index to insert the text at.
    func addText(text: String, toTextView textView: UITextView, atIndex index: Int) {

        let attributes = index < (textView.text as NSString).length ? textView.attributedText.attributesAtIndex(index, effectiveRange: nil) : textView.typingAttributes
        textView.textStorage.beginEditing()
        textView.textStorage.insertAttributedString(NSAttributedString(string: text, attributes: attributes), atIndex: index)
        textView.textStorage.endEditing()
        textView.selectedRange.location += (text as NSString).length
    }

    /// Toggles a numbered list on the current line if there is a zero-length selection;
    /// else removes all numbered lists in selection if they exist
    /// or adds them to each line if there are no numbered lists in selection
    func toggleNumberedList() {
        if textView.selectedRange.length == 0 {
            if selectionContainsNumberedList(textView.selectedRange) {

            } else {
                if let newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: textView.selectedRange.location) {

                } else {
                    let insertString = "1\(numberedListTrailer)"
                    addText(insertString, toTextView: textView, atIndex: 0)
                }
            }
        }
    }

    /// Checks a `NSRange` selection to see if it contains a numbered list.
    /// Returns true if selection contains at least 1 numbered list, false otherwise.
    /// 
    /// - parameter selection: An `NSRange` to check
    ///
    /// - returns: True if selection contains at least 1 numbered list, false otherwise
    func selectionContainsNumberedList(selection: NSRange) -> Bool {
        var containsNumberedList = false

        if selection.length == 0 {
            if let previousIndex = textView.text.previousIndexOfSubstring(numberedListTrailer, fromIndex: selection.location) {
                if let newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: selection.location) where (newLineIndex + 1) == previousIndex {
                    containsNumberedList = true
                } else {
                    containsNumberedList = true
                }
            } else {
                containsNumberedList = false
            }
        } else {
            let substring = (textView.text as NSString).substringWithRange(selection)
            if substring.containsString(numberedListTrailer) {
                containsNumberedList = true
            }
        }

        return containsNumberedList
    }

    /// Returns the number of the previous lines number starting from the location of the selection.  
    ///
    /// - parameter selection: The selection to check from
    ///
    /// - returns: Previous number if it exists in the previous line, `nil` otherwise
    func previousNumberOfNumberedList(selection: NSRange) -> Int? {
        return nil
    }
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(textView: UITextView) {
        view.backgroundColor = selectionContainsNumberedList(textView.selectedRange) ? UIColor.greenColor() : UIColor.blueColor()
    }
    
}
