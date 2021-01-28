//
//  ColorChaser.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ColorChaser :
   X3DChaserNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ColorChaser" }
   internal final override class var component      : String { "Followers" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFColor public final var set_value          : Color3f = .zero
   @SFColor public final var set_destination    : Color3f = .zero
   @SFColor public final var initialValue       : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var initialDestination : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var value_changed      : Color3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ColorChaser)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "duration",           $duration)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ColorChaser
   {
      return ColorChaser (with: executionContext)
   }
}
