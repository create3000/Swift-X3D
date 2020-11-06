//
//  ColorDamper.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ColorDamper :
   X3DDamperNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ColorDamper" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFColor public final var set_value          : Color3f = .zero
   @SFColor public final var set_destination    : Color3f = .zero
   @SFColor public final var initialValue       : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var initialDestination : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var value_changed      : Color3f = .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ColorDamper)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "order",              $order)
      addField (.inputOutput,    "tau",                $tau)
      addField (.inputOutput,    "tolerance",          $tolerance)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ColorDamper
   {
      return ColorDamper (with: executionContext)
   }
}
