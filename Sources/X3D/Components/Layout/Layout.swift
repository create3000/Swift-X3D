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
   
   public final override class var typeName       : String { "Layout" }
   public final override class var component      : String { "Layout" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "layout" }

   // Fields

   @MFString public final var align       : MFString .Value = ["CENTER", "CENTER"]
   @MFString public final var offsetUnits : MFString .Value = ["WORLD", "WORLD"]
   @MFFloat  public final var offset      : MFFloat .Value = [0, 0]
   @MFString public final var sizeUnits   : MFString .Value = ["WORLD", "WORLD"]
   @MFFloat  public final var size        : MFFloat .Value = [1, 1]
   @MFString public final var scaleMode   : MFString .Value = ["NONE", "NONE"]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
