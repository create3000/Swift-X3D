//
//  X3DTranslate.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public func t (_ string : String, _ arguments : CVarArg...) -> String
{
   return String (format: NSLocalizedString (string, comment: ""), arguments: arguments)
}
