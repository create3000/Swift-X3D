//
//  X3DScriptNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DScriptNode :
   X3DChildNode,
   X3DUrlObject
{
   // Fields
   
   @MFString public final var url : MFString .Value
   
   // Properties
   
   public   final override var canUserDefinedFields  : Bool { true }
   internal final override var extendedEventHandling : Bool { false }
   internal final override var sourceText            : MFString? { $url }

   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initUrlObject ()

      types .append (.X3DScriptNode)
      
      addChildObjects ($loadState)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
}
