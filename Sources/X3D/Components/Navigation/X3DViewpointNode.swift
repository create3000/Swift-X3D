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
   
   // Animation
   
   @SFNode private final var timeSensor                   : TimeSensor?
   @SFNode private final var easeInEaseOut                : EaseInEaseOut?
   @SFNode private final var positionInterpolator         : PositionInterpolator?
   @SFNode private final var orientationInterpolator      : OrientationInterpolator?
   @SFNode private final var scaleInterpolator            : PositionInterpolator?
   @SFNode private final var scaleOrientationInterpolator : OrientationInterpolator?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      timeSensor                   = TimeSensor              (with: executionContext!)
      easeInEaseOut                = EaseInEaseOut           (with: executionContext!)
      positionInterpolator         = PositionInterpolator    (with: executionContext!)
      orientationInterpolator      = OrientationInterpolator (with: executionContext!)
      scaleInterpolator            = PositionInterpolator    (with: executionContext!)
      scaleOrientationInterpolator = OrientationInterpolator (with: executionContext!)
      
      super .init (browser, executionContext)

      types .append (.X3DViewpointNode)
      
      addChildObjects ($positionOffset,
                       $orientationOffset,
                       $scaleOffset,
                       $scaleOrientationOffset,
                       $centerOfRotationOffset,
                       $fieldOfViewScale,
                       $timeSensor,
                       $easeInEaseOut,
                       $positionInterpolator,
                       $orientationInterpolator,
                       $scaleInterpolator,
                       $scaleOrientationInterpolator)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      // Animation
      
      easeInEaseOut!                .key = [0, 1]
      positionInterpolator!         .key = [0, 1]
      orientationInterpolator!      .key = [0, 1]
      scaleInterpolator!            .key = [0, 1]
      scaleOrientationInterpolator! .key = [0, 1]
      
      timeSensor!                   .setup ()
      easeInEaseOut!                .setup ()
      positionInterpolator?         .setup ()
      orientationInterpolator?      .setup ()
      scaleInterpolator?            .setup ()
      scaleOrientationInterpolator? .setup ()
      
      timeSensor! .$fraction_changed .addFieldInterest (to: easeInEaseOut! .$set_fraction)
      
      easeInEaseOut! .$modifiedFraction_changed .addFieldInterest (to: positionInterpolator! .$set_fraction)
      easeInEaseOut! .$modifiedFraction_changed .addFieldInterest (to: orientationInterpolator! .$set_fraction)
      easeInEaseOut! .$modifiedFraction_changed .addFieldInterest (to: scaleInterpolator! .$set_fraction)
      easeInEaseOut! .$modifiedFraction_changed .addFieldInterest (to: scaleOrientationInterpolator! .$set_fraction)
      
      positionInterpolator!         .$value_changed .addFieldInterest (to: $positionOffset)
      orientationInterpolator!      .$value_changed .addFieldInterest (to: $orientationOffset)
      scaleInterpolator!            .$value_changed .addFieldInterest (to: $scaleOffset)
      scaleOrientationInterpolator! .$value_changed .addFieldInterest (to: $scaleOrientationOffset)
   }
   
   // Property access
   
   internal var maxFarValue : Float { 100_000 }
   
   internal func getPosition () -> Vector3f { .zero }
   internal final func getOrientation () -> Rotation4f { orientation }
   internal func getCenterOfRotation () -> Vector3f { .zero }
   internal func getSpeedFactor () -> Float { 1 }

   // Operations
   
   internal var animate : Bool = false
   
   internal func setInterpolators (from viewpointNode : X3DViewpointNode) { }
   
   internal final override func transitionStart (with layer : X3DLayerNode, from node : X3DBindableNode)
   {
      guard let fromViewpointNode = node as? X3DViewpointNode else { return }

      if jump
      {
         if !retainUserOffsets
         {
            resetUserOffsets ()
         }

         let navigationInfoNode = layer .navigationInfoNode
         var transitionType     = navigationInfoNode .transitionType .first ?? "LINEAR"
         let transitionTime     = navigationInfoNode .transitionTime

         navigationInfoNode .transitionStart = true

         // VRML behaviour

         if executionContext! .getSpecificationVersion () == "2.0"
         {
            if animate
            {
               transitionType = "LINEAR"
            }
            else
            {
               transitionType = "TELEPORT"
            }
         }

         animate = false // VRML

         // End VRML behaviour

         switch transitionType
         {
            case "TELEPORT":
               layer .navigationInfoNode .transitionComplete = true
               return
            case "ANIMATE":
               easeInEaseOut! .easeInEaseOut = [Vector2f (0, 1), Vector2f (1, 0)]
            default:
               // LINEAR
               easeInEaseOut! .easeInEaseOut = [Vector2f (0, 0), Vector2f (0, 0)]
         }
         
         timeSensor! .cycleInterval = transitionTime
         timeSensor! .stopTime      = browser! .currentTime
         timeSensor! .startTime     = browser! .currentTime
         
         timeSensor! .$isActive .addInterest ("set_active", { _ in { [weak self] in self? .set_active (layer .navigationInfoNode) } }, self)

         let relative = getRelativeTransformation (fromViewpoint: fromViewpointNode)

         positionInterpolator!         .keyValue = [relative .translation,      positionOffset]
         orientationInterpolator!      .keyValue = [relative .rotation,         orientationOffset]
         scaleInterpolator!            .keyValue = [relative .scale,            scaleOffset]
         scaleOrientationInterpolator! .keyValue = [relative .scaleOrientation, scaleOrientationOffset]

         positionOffset         = relative .translation
         orientationOffset      = relative .rotation
         scaleOffset            = relative .scale
         scaleOrientationOffset = relative .scaleOrientation

         setInterpolators (from: fromViewpointNode)
      }
      else
      {
         let relative = getRelativeTransformation (fromViewpoint: fromViewpointNode)

         positionOffset         = relative .translation
         orientationOffset      = relative .rotation
         scaleOffset            = relative .scale
         scaleOrientationOffset = relative .scaleOrientation

         setInterpolators (from: fromViewpointNode)
      }
   }
   
   private final func getRelativeTransformation (fromViewpoint : X3DViewpointNode) -> (translation : Vector3f, rotation : Rotation4f, scale : Vector3f, scaleOrientation : Rotation4f)
   {
      let differenceMatrix = inverse (fromViewpoint .viewMatrix * modelMatrix)
      var relative         = decompose_transformation_matrix (differenceMatrix)

      relative .translation -= getPosition ()
      relative .rotation    *= getOrientation () .inverse
      
      return relative
   }
   
   private final func set_active (_ navigationInfoNode : NavigationInfo)
   {
      guard isBound else { return }
      
      guard !timeSensor! .isActive else { return }

      navigationInfoNode .transitionComplete = true
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

   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
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
      viewMatrix        = cameraSpaceMatrix .inverse
   }
}
