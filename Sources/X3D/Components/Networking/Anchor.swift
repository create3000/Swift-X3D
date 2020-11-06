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
   
   public final override class var typeName       : String { "Anchor" }
   public final override class var component      : String { "Networking" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString public final var description : String = ""
   @MFString public final var url         : MFString .Value
   @MFString public final var parameter   : MFString .Value
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
      
      addChildObjects ($loadState)
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
