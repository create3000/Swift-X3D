//
//  Sound.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Sound :
   X3DSoundNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Sound" }
   public final override class var component      : String { "Sound" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFFloat public final var intensity  : Float = 1
   @SFBool  public final var spatialize : Bool = true
   @SFVec3f public final var location   : Vector3f = Vector3f .zero
   @SFVec3f public final var direction  : Vector3f = Vector3f (0, 0, 1)
   @SFFloat public final var minBack    : Float = 1
   @SFFloat public final var minFront   : Float = 1
   @SFFloat public final var maxBack    : Float = 10
   @SFFloat public final var maxFront   : Float = 10
   @SFFloat public final var priority   : Float = 0
   @SFNode  public final var source     : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Sound)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOutput,    "intensity",  $intensity)
      addField (.initializeOnly, "spatialize", $spatialize)
      addField (.inputOutput,    "location",   $location)
      addField (.inputOutput,    "direction",  $direction)
      addField (.inputOutput,    "minBack",    $minBack)
      addField (.inputOutput,    "minFront",   $minFront)
      addField (.inputOutput,    "maxBack",    $maxBack)
      addField (.inputOutput,    "maxFront",   $maxFront)
      addField (.inputOutput,    "priority",   $priority)
      addField (.inputOutput,    "source",     $source)

      $location .unit = .length
      $minBack  .unit = .length
      $minFront .unit = .length
      $maxBack  .unit = .length
      $maxFront .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Sound
   {
      return Sound (with: executionContext)
   }
}
