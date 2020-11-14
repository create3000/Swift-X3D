//
//  X3DNurbsSurfaceGeometryNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DNurbsSurfaceGeometryNode :
   X3DParametricGeometryNode
{
   // Fields

   @SFBool   public final var solid         : Bool = true
   @SFInt32  public final var uTessellation : Int32 = 0
   @SFInt32  public final var vTessellation : Int32 = 0
   @SFBool   public final var uClosed       : Bool = false
   @SFBool   public final var vClosed       : Bool = false
   @SFInt32  public final var uOrder        : Int32 = 3
   @SFInt32  public final var vOrder        : Int32 = 3
   @SFInt32  public final var uDimension    : Int32 = 0
   @SFInt32  public final var vDimension    : Int32 = 0
   @MFDouble public final var uKnot         : [Double]
   @MFDouble public final var vKnot         : [Double]
   @MFDouble public final var weight        : [Double]
   @SFNode   public final var texCoord      : X3DNode?
   @SFNode   public final var controlPoint  : X3DNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNurbsSurfaceGeometryNode)
   }
}
