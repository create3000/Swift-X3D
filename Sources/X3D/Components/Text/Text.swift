//
//  Text.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Text :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Text" }
   public final override class var component      : String { "Text" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFString public final var string     : MFString .Value
   @MFFloat  public final var length     : MFFloat .Value
   @SFFloat  public final var maxExtent  : Float = 0
   @SFBool   public final var solid      : Bool = false
   @SFVec3f  public final var origin     : Vector3f = Vector3f .zero
   @SFVec2f  public final var textBounds : Vector2f = Vector2f .zero
   @MFVec2f  public final var lineBounds : MFVec2f .Value
   @SFNode   public final var fontStyle  : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Text)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOutput,    "string",     $string)
      addField (.inputOutput,    "length",     $length)
      addField (.inputOutput,    "maxExtent",  $maxExtent)
      addField (.initializeOnly, "solid",      $solid)
      addField (.outputOnly,     "origin",     $origin)
      addField (.outputOnly,     "textBounds", $textBounds)
      addField (.outputOnly,     "lineBounds", $lineBounds)
      addField (.inputOutput,    "fontStyle",  $fontStyle)

      $length     .unit = .length
      $maxExtent  .unit = .length
      $origin     .unit = .length
      $textBounds .unit = .length
      $lineBounds .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Text
   {
      return Text (with: executionContext)
   }
}
