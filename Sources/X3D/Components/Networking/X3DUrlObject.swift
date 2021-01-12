//
//  X3DUrlObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DUrlObject :
   X3DBaseNode
{
   // Fields

   //@MFString public final var url : [String]

   var url : [String] { get }
   
   // Properties
   
   //@SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE
   
   var loadState : SFEnum <X3DLoadState> { get }
   
   // Operations
   
   func requestImmediateLoad ()
}

extension X3DUrlObject
{
   // Construction
   
   internal func initUrlObject ()
   {
      types .append (.X3DUrlObject)
   }
   
   // Load state handling
   
   internal func setLoadState (_ value : X3DLoadState)
   {
      guard value != loadState .wrappedValue else { return }
      
      loadState .wrappedValue = value
   }
   
   public var checkLoadState : X3DLoadState { loadState .wrappedValue }
}
