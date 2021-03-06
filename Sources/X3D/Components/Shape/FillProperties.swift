//
//  FillProperties.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class FillProperties :
   X3DAppearanceChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "FillProperties" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "fillProperties" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool  public final var filled     : Bool = true
   @SFBool  public final var hatched    : Bool = true
   @SFColor public final var hatchColor : Color3f = .one
   @SFInt32 public final var hatchStyle : Int32 = 1
   
   // Properties
   
   @SFBool internal final var isTransparent : Bool = false

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.FillProperties)

      addField (.inputOutput, "metadata",   $metadata)
      addField (.inputOutput, "filled",     $filled)
      addField (.inputOutput, "hatched",    $hatched)
      addField (.inputOutput, "hatchColor", $hatchColor)
      addField (.inputOutput, "hatchStyle", $hatchStyle)
      
      addChildObjects ($isTransparent)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> FillProperties
   {
      return FillProperties (with: executionContext)
   }
}
