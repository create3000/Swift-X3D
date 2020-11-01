//
//  X3DConstants.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public enum X3DBrowserEvent :
   Hashable
{
   case Browser_Connection_Error
   case Browser_Event
   case Browser_Sensors
   case Browser_Done
   case Browser_Initialized
   case Browser_Shutdown
   case Browser_URL_Error
}

public enum X3DLoadState
{
   case NOT_STARTED_STATE
   case IN_PROGRESS_STATE
   case COMPLETE_STATE
   case FAILED_STATE
}

public enum X3DAccessType :
   UInt8,
   CustomStringConvertible
{
   case initializeOnly = 0b0001
   case inputOnly      = 0b0010
   case outputOnly     = 0b0100
   case inputOutput    = 0b0111

   private static let accessTypesX3D : [String : X3DAccessType] = [
      "initializeOnly" : .initializeOnly,
      "inputOnly"      : .inputOnly,
      "outputOnly"     : .outputOnly,
      "inputOutput"    : .inputOutput,
   ]
   
   private static let accessTypesVRML : [String : X3DAccessType] = [
      "field"        : .initializeOnly,
      "eventIn"      : .inputOnly,
      "eventOut"     : .outputOnly,
      "exposedField" : .inputOutput,
   ]
   
   init? (_ string : String)
   {
      guard let value = X3DAccessType .accessTypesX3D [string] else { return nil }
      
      self = value
   }
   
   init? (vrml : String)
   {
      guard let value = X3DAccessType .accessTypesVRML [vrml] else { return nil }
      
      self = value
   }

   public var description : String
   {
      switch self
      {
         case .initializeOnly: return "initializeOnly"
         case .inputOnly:      return "inputOnly"
         case .outputOnly:     return "outputOnly"
         case .inputOutput:    return "inputOutput"
      }
   }
}

public enum X3DFieldType
{
   case SFBool
   case SFColor
   case SFColorRGBA
   case SFDouble
   case SFFloat
   case SFImage
   case SFInt32
   case SFMatrix3d
   case SFMatrix3f
   case SFMatrix4d
   case SFMatrix4f
   case SFNode
   case SFRotation
   case SFString
   case SFTime
   case SFVec2d
   case SFVec2f
   case SFVec3d
   case SFVec3f
   case SFVec4d
   case SFVec4f

   case MFBool
   case MFColor
   case MFColorRGBA
   case MFDouble
   case MFFloat
   case MFImage
   case MFInt32
   case MFMatrix3d
   case MFMatrix3f
   case MFMatrix4d
   case MFMatrix4f
   case MFNode
   case MFRotation
   case MFString
   case MFTime
   case MFVec2d
   case MFVec2f
   case MFVec3d
   case MFVec3f
   case MFVec4d
   case MFVec4f
}

public enum X3DNodeType
{
   // Node types
   
   case Anchor
   case AnnotationLayer
   case AnnotationTarget
   case Appearance
   case Arc2D
   case ArcClose2D
   case AudioClip
   case Background
   case BallJoint
   case Billboard
   case BlendedVolumeStyle
   case BooleanFilter
   case BooleanSequencer
   case BooleanToggle
   case BooleanTrigger
   case BoundaryEnhancementVolumeStyle
   case BoundedPhysicsModel
   case Box
   case CADAssembly
   case CADFace
   case CADLayer
   case CADPart
   case CartoonVolumeStyle
   case Circle2D
   case ClipPlane
   case CollidableOffset
   case CollidableShape
   case Collision
   case CollisionCollection
   case CollisionSensor
   case CollisionSpace
   case Color
   case ColorChaser
   case ColorDamper
   case ColorInterpolator
   case ColorRGBA
   case ComposedCubeMapTexture
   case ComposedShader
   case ComposedTexture3D
   case ComposedVolumeStyle
   case Cone
   case ConeEmitter
   case Contact
   case Contour2D
   case ContourPolyline2D
   case Coordinate
   case CoordinateChaser
   case CoordinateDamper
   case CoordinateDouble
   case CoordinateInterpolator
   case CoordinateInterpolator2D
   case Cylinder
   case CylinderSensor
   case DISEntityManager
   case DISEntityTypeMapping
   case DirectionalLight
   case Disk2D
   case DoubleAxisHingeJoint
   case EaseInEaseOut
   case EdgeEnhancementVolumeStyle
   case ElevationGrid
   case EspduTransform
   case ExplosionEmitter
   case Extrusion
   case FillProperties
   case FloatVertexAttribute
   case Fog
   case FogCoordinate
   case FontStyle
   case ForcePhysicsModel
   case GeneratedCubeMapTexture
   case GeoCoordinate
   case GeoElevationGrid
   case GeoLOD
   case GeoLocation
   case GeoMetadata
   case GeoOrigin
   case GeoPositionInterpolator
   case GeoProximitySensor
   case GeoTouchSensor
   case GeoTransform
   case GeoViewpoint
   case Group
   case GroupAnnotation
   case HAnimDisplacer
   case HAnimHumanoid
   case HAnimJoint
   case HAnimMotion
   case HAnimSegment
   case HAnimSite
   case IconAnnotation
   case ImageCubeMapTexture
   case ImageTexture
   case ImageTexture3D
   case IndexedFaceSet
   case IndexedLineSet
   case IndexedQuadSet
   case IndexedTriangleFanSet
   case IndexedTriangleSet
   case IndexedTriangleStripSet
   case Inline
   case IntegerSequencer
   case IntegerTrigger
   case IsoSurfaceVolumeData
   case KeySensor
   case LOD
   case Layer
   case LayerSet
   case Layout
   case LayoutGroup
   case LayoutLayer
   case LinePickSensor
   case LineProperties
   case LineSet
   case LoadSensor
   case LocalFog
   case Material
   case Matrix3VertexAttribute
   case Matrix4VertexAttribute
   case MetadataBoolean
   case MetadataDouble
   case MetadataFloat
   case MetadataInteger
   case MetadataSet
   case MetadataString
   case MotorJoint
   case MovieTexture
   case MultiTexture
   case MultiTextureCoordinate
   case MultiTextureTransform
   case NavigationInfo
   case Normal
   case NormalInterpolator
   case NurbsCurve
   case NurbsCurve2D
   case NurbsOrientationInterpolator
   case NurbsPatchSurface
   case NurbsPositionInterpolator
   case NurbsSet
   case NurbsSurfaceInterpolator
   case NurbsSweptSurface
   case NurbsSwungSurface
   case NurbsTextureCoordinate
   case NurbsTrimmedSurface
   case OpacityMapVolumeStyle
   case OrientationChaser
   case OrientationDamper
   case OrientationInterpolator
   case OrthoViewpoint
   case PackagedShader
   case ParticleSystem
   case PickableGroup
   case PixelTexture
   case PixelTexture3D
   case PlaneSensor
   case PointEmitter
   case PointLight
   case PointPickSensor
   case PointProperties
   case PointSet
   case Polyline2D
   case PolylineEmitter
   case Polypoint2D
   case PositionChaser
   case PositionChaser2D
   case PositionDamper
   case PositionDamper2D
   case PositionInterpolator
   case PositionInterpolator2D
   case PrimitivePickSensor
   case ProgramShader
   case ProjectionVolumeStyle
   case ProximitySensor
   case QuadSet
   case ReceiverPdu
   case Rectangle2D
   case RigidBody
   case RigidBodyCollection
   case ScalarChaser
   case ScalarDamper
   case ScalarInterpolator
   case ScreenFontStyle
   case ScreenGroup
   case Script
   case SegmentedVolumeData
   case ShadedVolumeStyle
   case ShaderPart
   case ShaderProgram
   case Shape
   case SignalPdu
   case SilhouetteEnhancementVolumeStyle
   case SingleAxisHingeJoint
   case SliderJoint
   case Sound
   case Sphere
   case SphereSensor
   case SplinePositionInterpolator
   case SplinePositionInterpolator2D
   case SplineScalarInterpolator
   case SpotLight
   case SquadOrientationInterpolator
   case StaticGroup
   case StringSensor
   case SurfaceEmitter
   case Switch
   case TexCoordChaser2D
   case TexCoordDamper2D
   case Text
   case TextAnnotation
   case TextureBackground
   case TextureCoordinate
   case TextureCoordinate3D
   case TextureCoordinate4D
   case TextureCoordinateGenerator
   case TextureProjectorParallel
   case TextureProjectorPerspective
   case TextureProperties
   case TextureTransform
   case TextureTransform3D
   case TextureTransformMatrix3D
   case TimeSensor
   case TimeTrigger
   case ToneMappedVolumeStyle
   case TouchSensor
   case Transform
   case TransformSensor
   case TransmitterPdu
   case TriangleFanSet
   case TriangleSet
   case TriangleSet2D
   case TriangleStripSet
   case TwoSidedMaterial
   case URLAnnotation
   case UniversalJoint
   case Viewpoint
   case ViewpointGroup
   case Viewport
   case VisibilitySensor
   case VolumeData
   case VolumeEmitter
   case VolumePickSensor
   case WindPhysicsModel
   case WorldInfo
   
   // Abstract types

   case X3DAnnotationNode
   case X3DAppearanceChildNode
   case X3DAppearanceNode
   case X3DBackgroundNode
   case X3DBindableNode
   case X3DBoundedObject
   case X3DChaserNode
   case X3DChildNode
   case X3DColorNode
   case X3DComposableVolumeRenderStyleNode
   case X3DComposedGeometryNode
   case X3DCoordinateNode
   case X3DDamperNode
   case X3DDragSensorNode
   case X3DEnvironmentTextureNode
   case X3DEnvironmentalSensorNode
   case X3DFogObject
   case X3DFollowerNode
   case X3DFontStyleNode
   case X3DGeometricPropertyNode
   case X3DGeometryNode
   case X3DGeospatialObject
   case X3DGroupingNode
   case X3DInfoNode
   case X3DInterpolatorNode
   case X3DKeyDeviceSensorNode
   case X3DLayerNode
   case X3DLayoutNode
   case X3DLightNode
   case X3DMaterialNode
   case X3DMetadataObject
   case X3DNBodyCollidableNode
   case X3DNBodyCollisionSpaceNode
   case X3DNetworkSensorNode
   case X3DNode
   case X3DNormalNode
   case X3DNurbsControlCurveNode
   case X3DNurbsSurfaceGeometryNode
   case X3DParametricGeometryNode
   case X3DParticleEmitterNode
   case X3DParticlePhysicsModelNode
   case X3DPickSensorNode
   case X3DPickableObject
   case X3DPointingDeviceSensorNode
   case X3DProductStructureChildNode
   case X3DProgrammableShaderObject
   case X3DPrototypeInstance
   case X3DRigidJointNode
   case X3DScriptNode
   case X3DSensorNode
   case X3DSequencerNode
   case X3DShaderNode
   case X3DShapeNode
   case X3DSoundNode
   case X3DSoundSourceNode
   case X3DTexture2DNode
   case X3DTexture3DNode
   case X3DTextureCoordinateNode
   case X3DTextureNode
   case X3DTextureProjectorNode
   case X3DTextureTransformNode
   case X3DTimeDependentNode
   case X3DTouchSensorNode
   case X3DTriggerNode
   case X3DUrlObject
   case X3DVertexAttributeNode
   case X3DViewpointNode
   case X3DViewportNode
   case X3DVolumeDataNode
   case X3DVolumeRenderStyleNode

   // Core types
   
   case X3DExecutionContext
   case X3DScene
   case X3DWorld
}
