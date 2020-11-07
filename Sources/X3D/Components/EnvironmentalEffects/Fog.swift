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
   internal final override class var containerField : String { "children" }
   
   // Fields
   
   @SFColor  public final var color           : Color3f = .one
   @SFString public final var fogType         : String = "LINEAR"
   @SFFloat  public final var visibilityRange : Float = 0
   
   // Properties
   
   @SFBool public final var isHidden : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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

   internal final override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      renderer .layerNode! .fogList .append (node: self)
   }
   
   // Traverse
   
   internal final func push (_ renderer : X3DRenderer)
   {
      renderer .fogs .append (X3DFogContainer (fogObject: self, modelViewMatrix: renderer .modelViewMatrix .top))
   }

   internal final func pop (_ renderer : X3DRenderer)
   {
      renderer .fogs .removeLast ()
   }
}
