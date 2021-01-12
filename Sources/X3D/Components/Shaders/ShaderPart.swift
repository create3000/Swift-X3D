//
//  ShaderPart.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ShaderPart :
   X3DNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ShaderPart" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "parts" }

   // Fields

   @SFString public final var type : String = "VERTEX"
   @MFString public final var url  : [String]
   
   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)
   
   // Properties
   
   internal final override func getSourceText () ->  MFString? { $url }

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()

      types .append (.ShaderPart)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "type",     $type)
      addField (.inputOutput,    "url",      $url)
      
      addChildObjects (loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ShaderPart
   {
      return ShaderPart (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
}
