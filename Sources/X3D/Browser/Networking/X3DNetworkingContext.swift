//
//  X3DNetworkingContext.swift
//  X3D
//
//  Created by Holger Seelig on 19.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal final class X3DNetworkingContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate static let providerUrl = URL (string: "https://github.com/create3000/titania/wiki")!
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
}

internal protocol X3DNetworkingContext : class
{
   var browser                     : X3DBrowser { get }
   var networkingContextProperties : X3DNetworkingContextProperties! { get }
}

extension X3DNetworkingContext
{
   internal static var providerUrl : URL { X3DNetworkingContextProperties .providerUrl }
}
