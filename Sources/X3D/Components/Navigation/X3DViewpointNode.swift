//
//  X3DViewpointNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DViewpointNode :
   X3DBindableNode
{
   // Fields

   @SFString   public final var description       : String = ""
   @SFRotation public final var orientation       : Rotation4f = .identity
   @SFBool     public final var jump              : Bool = true
   @SFBool     public final var retainUserOffsets : Bool = false
   
   // Properties
   
   @SFVec3f    internal final var positionOffset         : Vector3f = .zero
   @SFRotation internal final var orientationOffset      : Rotation4f = .identity
   @SFVec3f    internal final var scaleOffset            : Vector3f = .one
   @SFRotation internal final var scaleOrientationOffset : Rotation4f = .identity
   @SFVec3f    internal final var centerOfRotationOffset : Vector3f = .zero
   @SFFloat    internal final var fieldOfViewScale       : Float = 1
   
   internal var userPosition         : Vector3f { positionOffset + getPosition () }
   internal var userOrientation      : Rotation4f { orientationOffset * getOrientation () }
   internal var userCenterOfRotation : Vector3f { centerOfRotationOffset + getCenterOfRotation () }
   internal var upVector             : Vector3f { .yAxis }
   
   // Viewpoint matrices, these matrices are only up to date in bound viewpoint.
   
   internal private(set) var cameraSpaceMatrix : Matrix4f = .identity
   internal private(set) var viewMatrix        : Matrix4f = .identity
   internal private(set) var modelMatrix       : Matrix4f = .identity

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DViewpointNode)
      
      addChildObjects ($positionOffset,
                       $orientationOffset,
                       $scaleOffset,
                       $scaleOrientationOffset,
                       $centerOfRotationOffset,
                       $fieldOfViewScale)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
   }
   
   // Property access
   
   internal var maxFarValue : Float { 100_000 }
   
   internal func getPosition () -> Vector3f { .zero }
   internal final func getOrientation () -> Rotation4f { orientation }
   internal func getCenterOfRotation () -> Vector3f { .zero }
   
   // Operations
   
   internal final override func transitionStart (with layer : X3DLayerNode, from node : X3DBindableNode)
   {
      //guard let fromViewpointNode = node as? X3DViewpointNode else { return }
   }
   
   internal final override func transitionStop ()
   {
      
   }
   
   internal final func resetUserOffsets ()
   {
      positionOffset         = .zero
      orientationOffset      = .identity
      scaleOffset            = .one
      scaleOrientationOffset = .identity
      centerOfRotationOffset = .zero
      fieldOfViewScale       = 1
   }
   
   internal final func straightenHorizon (_ orientation : Rotation4f) -> Rotation4f
   {
      let localXAxis = orientation * -Vector3f .xAxis
      let localZAxis = orientation *  Vector3f .zAxis
      let vector     = cross (localZAxis, upVector)

      // If viewer looks along the up vector.
      if abs (dot (localZAxis, upVector)) >= 1
      {
         return .identity
      }

      if abs (dot (vector, localXAxis)) >= 1
      {
         return .identity
      }

      return Rotation4f (from: localXAxis, to: vector)
   }

   // Rendering
   
   internal func makeProjectionMatrix (_ viewport : Vector4i, _ nearValue : Float, _ farValue : Float) -> Matrix4f { .identity }
   
   // Traverse camera

   internal final override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      renderer .layerNode! .viewpointList .append (node: self)

      modelMatrix = renderer .modelViewMatrix .top
   }
   
   internal final func update ()
   {
      let matrix = compose_transformation_matrix (translation: userPosition,
                                                  rotation: userOrientation,
                                                  scale: scaleOffset,
                                                  scaleOrientation: scaleOrientationOffset)
      
      cameraSpaceMatrix = modelMatrix * matrix
      viewMatrix        = ~cameraSpaceMatrix
   }
}
