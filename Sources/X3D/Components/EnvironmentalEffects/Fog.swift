//
//  Fog.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Fog :
   X3DBindableNode,
   X3DFogObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Fog" }
   internal final override class var component      : String { "EnvironmentalEffects" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }
   
   // Fields
   
   @SFColor  public final var color           : Color3f = .one
   @SFString public final var fogType         : String = "LINEAR"
   @SFFloat  public final var visibilityRange : Float = 0
   
   // Properties
   
   @SFBool public final var isHidden : Bool = false

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initFogObject (visibilityRange: $visibilityRange)

      types .append (.Fog)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOnly,   "set_bind",        $set_bind)
      addField (.inputOutput, "fogType",         $fogType)
      addField (.inputOutput, "color",           $color)
      addField (.inputOutput, "visibilityRange", $visibilityRange)
      addField (.outputOnly,  "isBound",         $isBound)
      addField (.outputOnly,  "bindTime",        $bindTime)
      
      addChildObjects ($isHidden)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Fog
   {
      return Fog (with: executionContext)
   }
   
   // Traverse camera

   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .layerNode! .fogList .append (node: self)
   }
   
   // Traverse
   
   internal final func push (_ renderer : Renderer)
   {
      renderer .fogs .append (FogContainer (fogObject: self, modelViewMatrix: renderer .modelViewMatrix .top))
   }

   internal final func pop (_ renderer : Renderer)
   {
      renderer .fogs .removeLast ()
   }
}
