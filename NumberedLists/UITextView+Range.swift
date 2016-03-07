//
//  UITextView+Range.swift
//  NumberedLists
//
//  Created by Rhett Rogers on 3/7/16.
//  Copyright © 2016 LyokoTech. All rights reserved.
//

import Foundation

extension UITextView {
    var selectedNewRange: Range<String.Index> {
        return selectedRange.convertWithString(text)
    }
}
