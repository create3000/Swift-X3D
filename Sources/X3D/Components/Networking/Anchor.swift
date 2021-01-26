//
//  Anchor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Anchor :
   X3DGroupingNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Anchor" }
   internal final override class var component      : String { "Networking" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFString public final var description : String = ""
   @MFString public final var url         : [String]
   @MFString public final var parameter   : [String]
   
   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()

      types .append (.Anchor)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "description",    $description)
      addField (.inputOutput,    "url",            $url)
      addField (.inputOutput,    "parameter",      $parameter)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
      
      addChildObjects (loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Anchor
   {
      return Anchor (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
}
