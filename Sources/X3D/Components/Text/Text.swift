//
//  Text.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Text :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Text" }
   internal final override class var component      : String { "Text" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFString public final var string     : [String]
   @MFFloat  public final var length     : [Float]
   @SFFloat  public final var maxExtent  : Float = 0
   @SFBool   public final var solid      : Bool = false
   @SFVec3f  public final var origin     : Vector3f = .zero
   @SFVec2f  public final var textBounds : Vector2f = .zero
   @MFVec2f  public final var lineBounds : [Vector2f]
   @SFNode   public final var fontStyle  : X3DNode?
   
   // Properties
   
   private final var fontStyleNode : X3DFontStyleNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $fontStyle .addInterest ("set_fontStyle", { $0 .set_fontStyle () }, self)
      
      set_fontStyle ()
   }
   
   // Properties access
   
   public override final var bbox : Box3f
   {
      get { textGeometry! .matrix * super .bbox }
      set { super .bbox = newValue }
   }
   
   internal final override var matrix : Matrix4f { textGeometry! .matrix }

   internal final func length (index : Int) -> Float
   {
      length .indices .contains (index) ? max (0, length [index]) : 0
   }
   
   // Event handlers
   
   private final var textGeometry : X3DTextGeometry?
   
   private final func set_fontStyle ()
   {
      fontStyleNode? .$loadState .removeInterest ("requestRebuild", self)
      
      fontStyleNode = fontStyle? .innerNode as? X3DFontStyleNode ?? browser! .defaultFontStyleNode
      
      fontStyleNode? .$loadState .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
      
      textGeometry = fontStyleNode! .makeTextGeometry (textNode: self)
      
      setTransparent (textGeometry! .isTransparent)
      
      requestRebuild ()
   }
   
   // Build
   
   internal final override func build ()
   {
      isSolid     = solid
      hasTexCoord = true
      
      textGeometry! .build ()
   }
   
   // Rendering
   
   internal final override func transformLine (_ line : Line3f) -> Line3f
   {
      textGeometry! .transformLine (line)
   }
   
   internal final override func transformMatrix (_ matrix : Matrix4f) -> Matrix4f
   {
      textGeometry! .transformMatrix (matrix)
   }
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      textGeometry! .traverse (type, renderer)
   }
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      textGeometry! .render (context, renderEncoder)
      
      super .render (context, renderEncoder)
   }
}
