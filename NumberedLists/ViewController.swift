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
    var previousSelection = NSRange()
    
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

    /// Replaces text in a range with text in parameter
    ///
    /// - parameter range: The range at which to replace the string.
    /// - parameter withText: The text that will be inserted.
    /// - parameter inTextView: The textView in which changes will occur.
    func replaceTextInRange(range: NSRange, withText replacementText: String, inTextView textView: UITextView) {
        let substringLength = (textView.text as NSString).substringWithRange(range).length
        let lengthDifference = substringLength - replacementText.length
        let previousRange = textView.selectedRange
        let attributes = textView.attributedText.attributesAtIndex(range.location, effectiveRange: nil)
        
        textView.textStorage.beginEditing()
        textView.textStorage.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: replacementText, attributes: attributes))
        textView.textStorage.endEditing()
        
        let offset = lengthDifference - (previousRange.location - textView.selectedRange.location)
        textView.selectedRange.location -= offset
        
        textViewDidChangeSelection(textView)
    }
    
    /// Removes text from a textView at a specified index
    ///
    /// - parameter range: The range of the text to remove.
    /// - parameter toTextView: The `UITextView` to remove the text from.
    func removeTextFromRange(range: NSRange, fromTextView textView: UITextView) {
        let substringLength = (textView.text as NSString).substringWithRange(range).length
        let previousRange = textView.selectedRange
        textView.textStorage.beginEditing()
        textView.textStorage.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: ""))
        textView.textStorage.endEditing()

        let offset = substringLength - (previousRange.location - textView.selectedRange.location)

        textView.selectedRange.location -= offset

        textViewDidChangeSelection(textView)
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
        textView.selectedRange.location += text.length
        textViewDidChangeSelection(textView)
    }

    /// Toggles a numbered list on the current line if there is a zero-length selection;
    /// else removes all numbered lists in selection if they exist
    /// or adds them to each line if there are no numbered lists in selection
    func toggleNumberedList() {
        if textView.selectedRange.length == 0 {
            if selectionContainsNumberedList(textView.selectedRange) {
                if let newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: textView.selectedRange.location) {
                    guard let previousNumber = previousNumberOfNumberedList(textView.selectedRange) else { return }

                    var range = NSRange(location: newLineIndex+1, length: "\(previousNumber)\(numberedListTrailer)".length)
                    removeTextFromRange(range, fromTextView: textView)
                } else {
                    removeTextFromRange(NSRange(location: 0, length: numberedListTrailer.length+1), fromTextView: textView)
                }
            } else {
                if let newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: textView.selectedRange.location) {
                    let newNumber = (previousNumberOfNumberedList(textView.selectedRange) ?? 0) + 1
                    let insertString = "\(newNumber)\(numberedListTrailer)"
                    addText(insertString, toTextView: textView, atIndex: newLineIndex + 1)
                } else {
                    let insertString = "1\(numberedListTrailer)"
                    addText(insertString, toTextView: textView, atIndex: 0)
                }
            }
        } else {

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
                if let newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: selection.location) {
                    if let comparisonIndex = textView.text.nextIndexOfSubstring(numberedListTrailer, fromIndex: newLineIndex) where previousIndex == comparisonIndex {
                        containsNumberedList = true
                    }
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

    /// Returns the number of the previous number starting from the location of the selection.
    ///
    /// - parameter selection: The selection to check from
    ///
    /// - returns: Previous number if it exists in the current line, `nil` otherwise
    func previousNumberOfNumberedList(selection: NSRange) -> Int? {
        guard let previousIndex = textView.text.previousIndexOfSubstring(numberedListTrailer, fromIndex: selection.location) else { return nil }
        guard var newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: previousIndex) else { return 1 }
        newLineIndex += 1

        return Int((textView.text as NSString).substringWithRange(NSRange(location: newLineIndex, length: previousIndex - newLineIndex)))
    }

    /// Appends a number to the text view if we are currently in a list.  Also deletes existing number if there is no text on the line.  This function should be called when the user inserts a new line (presses return)
    ///
    /// - parameter range: The location to insert the number
    ///
    /// - returns: `true` if a number was added, `false` otherwise
    func addedListsIfActiveInRange(range: NSRange) -> Bool {
        guard selectionContainsNumberedList(range) else { return false }

        let previousNumber = previousNumberOfNumberedList(range) ?? 0
        let previousNumberString = "\(previousNumber)\(numberedListTrailer)"
        let previousRange = NSRange(location: range.location - previousNumberString.length, length: previousNumberString.length)
        var newNumber = previousNumber + 1
        let newNumberString = "\n\(newNumber)\(numberedListTrailer)"

        if textView.attributedText.attributedSubstringFromRange(previousRange).string == previousNumberString {
            removeTextFromRange(previousRange, fromTextView: textView)
        } else {
            addText(newNumberString, toTextView: textView, atIndex: range.location)

            // TODO: Complete iterating through the string incrementing the numbers
            var index = range.location + newNumberString.length

            while true {
                let stringToReplace = "\(newNumber)\(numberedListTrailer)"
                print("Before index: \(index); searchString: \(stringToReplace)")
                index = textView.text.nextIndexOfSubstring(stringToReplace, fromIndex: index) ?? -1
                print("After index: \(index)")
                guard index >= 0 else { break }
                
                newNumber += 1
                
                replaceTextInRange(NSRange(location: index, length: stringToReplace.length), withText: "\(newNumber)\(numberedListTrailer)", inTextView: textView)
                index += 1
            }
        }

        return true
    }

    /// Removes a number from a numbered list.  This function should be called when the user is backspacing on a number of a numbered list
    ///
    /// - parameter range: The range from which to remove the number
    ///
    /// - returns: true if a number was removed, false otherwise
    func removedListsIfActiveInRange(range: NSRange) -> Bool {
        guard textView.selectedRange.location > 2 else { return false }

        var removed = false
        let previousNumber = previousNumberOfNumberedList(textView.selectedRange) ?? 0
        let previousNumberString = "\(previousNumber)\(numberedListTrailer)"
        let previousRange = NSRange(location: range.location - previousNumberString.length + 1, length: previousNumberString.length)

        let subString = (textView.text as NSString).substringWithRange(previousRange)

        if subString == previousNumberString {
            removeTextFromRange(previousRange, fromTextView: textView)
            removed = true
        }
        return removed
    }
    
    /// Moves the selection out of a number.  Call this when a selection changes
    private func moveSelectionIfInRangeOfList() {
        guard textView.text.length > 1 && textView.selectedRange.location < textView.text.length,
            let number = previousNumberOfNumberedList(NSRange(location: textView.selectedRange.location + 1, length: textView.selectedRange.length))
            else {
                return
        }
        
        
        var range = NSRange(location: textView.selectedRange.location, length: textView.selectedRange.length)
        var newLineIndex = textView.text.previousIndexOfSubstring("\n", fromIndex: range.location) ?? 0
        
        newLineIndex += newLineIndex == 0 ? 0 : 1
        
        print("checking", newLineIndex, range.location)
        if newLineIndex == range.location {
            let nextNewLine = textView.text.nextIndexOfSubstring("\n", fromIndex: newLineIndex) ?? -1
            let nextNumberTrailerIndex = textView.text.nextIndexOfSubstring(numberedListTrailer, fromIndex: newLineIndex) ?? -1
            
            if nextNumberTrailerIndex < nextNewLine {
                range.location = nextNumberTrailerIndex + numberedListTrailer.length
            }
        }
        
        
        print("Before", range, newLineIndex)
        range.length = range.length + (range.location - newLineIndex) + 1
        range.location = newLineIndex
        print("after", range)
        
        let testString = (textView.text as NSString).substringWithRange(range)
        let goingBackward = previousSelection.location > range.location
        

        print("Starting Loop", "'\(testString)'", "'\(number)\(numberedListTrailer)'", goingBackward, previousSelection, range)
        if testString == "\(number)\(numberedListTrailer)" {
            if goingBackward {
                range.location -= 1
            }
            
            range.location = range.location < 3 ? 3 : range.location
            range.length = 0
            print("test", range, textView.selectedRange)
            textView.selectedRange = range
//            break
        }
        
        
//        while loops < range.length {
//            print(range, loops)
//            
//            
//            if range.location > 0 {
//                range.location -= 1
//            } else {
//                break
//            }
//            testString = (textView.text as NSString).substringWithRange(range)
//            loops += 1
//        }
        
    }

}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(textView: UITextView) {
        moveSelectionIfInRangeOfList()
        view.backgroundColor = selectionContainsNumberedList(textView.selectedRange) ? UIColor.greenColor() : UIColor.blueColor()
        previousSelection = textView.selectedRange
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var changed = false

        switch text {
        case "\n":
            changed = addedListsIfActiveInRange(range)
        case "":
            changed = removedListsIfActiveInRange(range)
        default:
            break
        }

        return !changed
    }
}
