//
//  ShaderProgram.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ShaderProgram :
   X3DNode,
   X3DProgrammableShaderObject,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ShaderProgram" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "programs" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: false) }

   // Fields

   @SFString public final var type : String = "VERTEX"
   @MFString public final var url  : [String]
   
   // Properties
   
   public final override var canUserDefinedFields : Bool { true }
   
   internal final override func getSourceText () ->  MFString? { $url }

   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ShaderProgram)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "type",     $type)
      addField (.inputOutput,    "url",      $url)
      
      addChildObjects (loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ShaderProgram
   {
      return ShaderProgram (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
}
