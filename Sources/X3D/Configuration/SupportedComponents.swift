//
//  SupportedComponents.swift
//  X3D
//
//  Created by Holger Seelig on 20.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class SupportedComponents
{
   internal static let components : [String : ComponentInfo] = make ()
   internal static let aliases    : [String : String] = makeAliases ()
   
   private static func make () -> [String : ComponentInfo]
   {
      func add (title : String, name : String, level : Int32, providerUrl : String)
      {
         components [name] = ComponentInfo (title: title, name: name, level: level, providerUrl: providerUrl)
      }
      
      var components = [String : ComponentInfo] ()
      
//      add (title:      "Annotation",
//           name:       "Annotation",
//           level:       2,
//           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Computer-Aided Design (CAD) model geometry",
           name:       "CADGeometry",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Core",
           name:       "Core",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Cube map environmental texturing",
           name:       "CubeMapTexturing",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Distributed interactive simulation (DIS)",
           name:       "DIS",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Environmental effects",
           name:       "EnvironmentalEffects",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Environmental sensor",
           name:       "EnvironmentalSensor",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Event utilities",
           name:       "EventUtilities",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Followers",
           name:       "Followers",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Geometry2D",
           name:       "Geometry2D",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Geometry3D",
           name:       "Geometry3D",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Geospatial",
           name:       "Geospatial",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Grouping",
           name:       "Grouping",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Humanoid animation (H-Anim)",
           name:       "HAnim",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Interpolation",
           name:       "Interpolation",
           level:       5,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Key device sensor",
           name:       "KeyDeviceSensor",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Layering",
           name:       "Layering",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Layout",
           name:       "Layout",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Lighting",
           name:       "Lighting",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Navigation",
           name:       "Navigation",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Networking",
           name:       "Networking",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Non-uniform Rational B-Spline (NURBS)",
           name:       "NURBS",
           level:       4,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Particle systems",
           name:       "ParticleSystems",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Picking sensor",
           name:       "Picking",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Pointing device sensor",
           name:       "PointingDeviceSensor",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Projective Texture Mapping",
           name:       "ProjectiveTextureMapping",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Rendering",
           name:       "Rendering",
           level:       5,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Rigid body physics",
           name:       "RigidBodyPhysics",
           level:       5,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Scripting",
           name:       "Scripting",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Programmable shaders",
           name:       "Shaders",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Shape",
           name:       "Shape",
           level:       5,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Sound",
           name:       "Sound",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Text",
           name:       "Text",
           level:       1,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Texturing",
           name:       "Texturing",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Texturing3D",
           name:       "Texturing3D",
           level:       3,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Time",
           name:       "Time",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)

      add (title:      "Volume rendering",
           name:       "VolumeRendering",
           level:       2,
           providerUrl: X3DBrowser .providerUrl .description)
   
      return components
   }

   private static func makeAliases () -> [String : String]
   {
      var aliases = [String : String] ()
      
      aliases ["H-Anim"] = "HAnim"

      return aliases
   }
}
