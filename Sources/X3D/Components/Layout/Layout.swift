//
//  Layout.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Layout :
   X3DLayoutNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Layout" }
   internal final override class var component      : String { "Layout" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "layout" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFString public final var align       : [String] = ["CENTER", "CENTER"]
   @MFString public final var offsetUnits : [String] = ["WORLD", "WORLD"]
   @MFFloat  public final var offset      : [Float] = [0, 0]
   @MFString public final var sizeUnits   : [String] = ["WORLD", "WORLD"]
   @MFFloat  public final var size        : [Float] = [1, 1]
   @MFString public final var scaleMode   : [String] = ["NONE", "NONE"]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Layout)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "align",       $align)
      addField (.inputOutput, "offsetUnits", $offsetUnits)
      addField (.inputOutput, "offset",      $offset)
      addField (.inputOutput, "sizeUnits",   $sizeUnits)
      addField (.inputOutput, "size",        $size)
      addField (.inputOutput, "scaleMode",   $scaleMode)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Layout
   {
      return Layout (with: executionContext)
   }
}
