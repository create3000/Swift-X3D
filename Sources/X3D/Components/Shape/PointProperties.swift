//
//  PointProperties.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PointProperties :
   X3DAppearanceChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PointProperties" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 5 }
   internal final override class var containerField : String { "pointProperties" }

   // Fields

   @SFFloat  public final var pointSizeScaleFactor : Float = 1
   @SFFloat  public final var pointSizeMinValue    : Float = 1
   @SFFloat  public final var pointSizeMaxValue    : Float = 1
   @MFFloat  public final var pointSizeAttenuation : [Float] = [1, 0, 0]
   @SFString public final var colorMode            : String = "TEXTURE_AND_POINT_COLOR"

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PointProperties)

      addField (.inputOutput, "metadata",             $metadata)
      addField (.inputOutput, "pointSizeScaleFactor", $pointSizeScaleFactor)
      addField (.inputOutput, "pointSizeMinValue",    $pointSizeMinValue)
      addField (.inputOutput, "pointSizeMaxValue",    $pointSizeMaxValue)
      addField (.inputOutput, "pointSizeAttenuation", $pointSizeAttenuation)
      addField (.inputOutput, "colorMode",            $colorMode)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PointProperties
   {
      return PointProperties (with: executionContext)
   }
}
