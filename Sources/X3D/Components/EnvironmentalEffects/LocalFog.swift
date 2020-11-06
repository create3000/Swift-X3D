//
//  LocalFog.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class LocalFog :
   X3DChildNode,
   X3DFogObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "LocalFog" }
   public final override class var component      : String { "EnvironmentalEffects" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool   public final var enabled         : Bool = true
   @SFColor  public final var color           : Color3f = .one
   @SFString public final var fogType         : String = "LINEAR"
   @SFFloat  public final var visibilityRange : Float = 0
   
   // Properties
   
   @SFBool public final var isHidden : Bool = false

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initFogObject (visibilityRange: $visibilityRange)

      types .append (.LocalFog)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "enabled",         $enabled)
      addField (.inputOutput, "fogType",         $fogType)
      addField (.inputOutput, "color",           $color)
      addField (.inputOutput, "visibilityRange", $visibilityRange)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LocalFog
   {
      return LocalFog (with: executionContext)
   }
   
   // Traverse
   
   internal final func push (_ renderer : X3DRenderer)
   {
      guard enabled else { return }
      
      renderer .fogs .append (X3DFogContainer (fogObject: self, modelViewMatrix: renderer .modelViewMatrix .top))
   }

   internal final func pop (_ renderer : X3DRenderer)
   {
      guard enabled else { return }
      
      renderer .fogs .removeLast ()
   }
}
