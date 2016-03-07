//
//  NSRange+Range.swift
//  NumberedLists
//
//  Created by Rhett Rogers on 3/7/16.
//  Copyright © 2016 LyokoTech. All rights reserved.
//

import Foundation


extension NSRange {

    func convertWithString(string: NSString) -> Range<String.Index> {
        string
        print(self)
        let startString = string as String
        var startIndex = startString.startIndex

        if location > 0 {
            for _ in 1..<location {
                startIndex = startIndex.successor()
            }
        }
        var endIndex = startIndex

        if length > 0 {
            for _ in 1..<length {
                endIndex = endIndex.successor()
            }
        }
        return Range<String.Index>(start: startIndex, end: endIndex)
    }
    
}
