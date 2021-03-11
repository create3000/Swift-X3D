//
//  X3DFilter.swift
//  X3D
//
//  Created by Holger Seelig on 17.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public func remove_trailing_number (_ string : String) -> String
{
   let name = try! NSRegularExpression (pattern: "^(.*?)(?:_\\d+)?$")
   
   guard let matches = name .matches (in: string) else { return string }

   return matches [1]
}

internal func proto_remove_trailing_number (_ string : String) -> String
{
   let name = try! NSRegularExpression (pattern: "^(.*?)(?:\\d+)?$")
   
   guard let matches = name .matches (in: string) else { return string }

   return matches [1]
}

internal func filter_data_url (string : String) -> String?
{
   let dataURL = try! NSRegularExpression (pattern: "^(data:[\\s\\S]*?,)")
   
   guard let matches = dataURL .matches (in: string) else { return string }
   
   guard let data = string .suffix (from: string .index (string .startIndex, offsetBy: matches [1] .count)) .removingPercentEncoding? .addingPercentEncoding (withAllowedCharacters: .alphanumerics) else { return nil }
   
   return matches [1] + data
}

public func validate (id : String) -> Bool
{
   guard !id .isEmpty else { return false }
   
   let scanner = Scanner (string: id)

   scanner .charactersToBeSkipped = VRMLParser .Grammar .nothing

   guard let idFirstChars = scanner .scanCharacters (from: VRMLParser .Grammar .idFirstChar) else { return false }

   let idLastChars = scanner .scanCharacters (from: VRMLParser .Grammar .idLastChars)

   return (idFirstChars + (idLastChars ?? "")) == id
}
