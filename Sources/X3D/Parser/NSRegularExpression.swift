//
//  NSRegularExpression.swift
//  X3D
//
//  Created by Holger Seelig on 16.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal extension NSRegularExpression
{
   func matches (in string : String, all : Bool = false) -> [String]?
   {
      let m = matches (in: string, options: [ ], range: NSRange (location: 0, length: string .utf16 .count))
      var r = [String] ()
      
      guard !m .isEmpty else { return nil }
      
      for m in m
      {
         for index in 0 ..< m .numberOfRanges
         {
            if let range = Range (m .range (at: index), in: string)
            {
               r .append (String (string [range]))
            }
            else
            {
               r .append ("")
            }
         }
         
         if !all { break }
      }
      
      return r
   }
}
