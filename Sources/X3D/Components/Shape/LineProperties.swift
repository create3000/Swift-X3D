//
//  LineProperties.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class LineProperties :
   X3DAppearanceChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LineProperties" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "lineProperties" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool  public final var applied              : Bool = true
   @SFInt32 public final var linetype             : Int32 = 1
   @SFFloat public final var linewidthScaleFactor : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LineProperties)

      addField (.inputOutput, "metadata",             $metadata)
      addField (.inputOutput, "applied",              $applied)
      addField (.inputOutput, "linetype",             $linetype)
      addField (.inputOutput, "linewidthScaleFactor", $linewidthScaleFactor)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LineProperties
   {
      return LineProperties (with: executionContext)
   }
}
