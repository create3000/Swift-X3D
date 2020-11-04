//
//  NurbsSurfaceInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsSurfaceInterpolator :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "NurbsSurfaceInterpolator" }
   public final override class var component      : String { "NURBS" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec2f  public final var set_fraction     : Vector2f = Vector2f .zero
   @SFInt32  public final var uOrder           : Int32 = 3
   @SFInt32  public final var vOrder           : Int32 = 3
   @SFInt32  public final var uDimension       : Int32 = 0
   @SFInt32  public final var vDimension       : Int32 = 0
   @MFDouble public final var uKnot            : MFDouble .Value
   @MFDouble public final var vKnot            : MFDouble .Value
   @MFDouble public final var weight           : MFDouble .Value
   @SFNode   public final var controlPoint     : X3DNode?
   @SFVec3f  public final var normal_changed   : Vector3f = Vector3f .zero
   @SFVec3f  public final var position_changed : Vector3f = Vector3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsSurfaceInterpolator)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOnly,      "set_fraction",     $set_fraction)
      addField (.initializeOnly, "uOrder",           $uOrder)
      addField (.initializeOnly, "vOrder",           $vOrder)
      addField (.initializeOnly, "uDimension",       $uDimension)
      addField (.initializeOnly, "vDimension",       $vDimension)
      addField (.initializeOnly, "uKnot",            $uKnot)
      addField (.initializeOnly, "vKnot",            $vKnot)
      addField (.inputOutput,    "weight",           $weight)
      addField (.inputOutput,    "controlPoint",     $controlPoint)
      addField (.outputOnly,     "normal_changed",   $normal_changed)
      addField (.outputOnly,     "position_changed", $position_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsSurfaceInterpolator
   {
      return NurbsSurfaceInterpolator (with: executionContext)
   }
}