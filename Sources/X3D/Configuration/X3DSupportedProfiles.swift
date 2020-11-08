//
//  X3DSupportedProfiles.swift
//  X3D
//
//  Created by Holger Seelig on 20.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DSupportedProfiles
{
   internal static let profiles : [String : X3DProfileInfo] = make ()
   
   private static func make () -> [String : X3DProfileInfo]
   {
      func add (title : String, name : String, providerUrl : String, components : [String])
      {
         profiles [name] = X3DProfileInfo (name: name,
                                           title: title,
                                           providerUrl: providerUrl,
                                           components: components .map { name in X3DSupportedComponents .components [name]! })
      }
      
      var profiles = [String : X3DProfileInfo] ()
      
      add (title: "Computer-Aided Design (CAD) interchange",
           name: "CADInterchange",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "CADGeometry",
               "Core",
               "Grouping",
               "Lighting",
               "Navigation",
               "Networking",
               "Rendering",
               "Shaders",
               "Shape",
               "Texturing",
            ])
      
      add (title: "Core",
           name: "Core",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
           ])

      add (title: "Full",
           name: "Full",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Annotation",
               "CADGeometry",
               "Core",
               "CubeMapTexturing",
               "DIS",
               "EnvironmentalEffects",
               "EnvironmentalSensor",
               "EventUtilities",
               "Followers",
               "Geometry2D",
               "Geometry3D",
               "Geospatial",
               "Grouping",
               "HAnim",
               "Interpolation",
               "KeyDeviceSensor",
               "Layering",
               "Layout",
               "Lighting",
               "Navigation",
               "Networking",
               "NURBS",
               "ParticleSystems",
               "Picking",
               "PointingDeviceSensor",
               "ProjectiveTextureMapping",
               "Rendering",
               "RigidBodyPhysics",
               "Scripting",
               "Shaders",
               "Shape",
               "Sound",
               "Text",
               "Texturing",
               "Texturing3D",
               "Time",
               "VolumeRendering",
           ])

      add (title: "Immersive",
           name: "Immersive",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
               "EnvironmentalEffects",
               "EnvironmentalSensor",
               "EventUtilities",
               "Geometry2D",
               "Geometry3D",
               "Grouping",
               "Interpolation",
               "KeyDeviceSensor",
               "Lighting",
               "Navigation",
               "Networking",
               "PointingDeviceSensor",
               "Rendering",
               "Scripting",
               "Shape",
               "Sound",
               "Text",
               "Texturing",
               "Time",
           ])

      add (title: "Interactive",
           name: "Interactive",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
               "EnvironmentalEffects",
               "EnvironmentalSensor",
               "EventUtilities",
               "Geometry3D",
               "Grouping",
               "Interpolation",
               "KeyDeviceSensor",
               "Lighting",
               "Navigation",
               "Networking",
               "PointingDeviceSensor",
               "Rendering",
               "Shape",
               "Texturing",
               "Time",
           ])

      add (title: "Interchange",
           name: "Interchange",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
               "EnvironmentalEffects",
               "Geometry3D",
               "Grouping",
               "Interpolation",
               "Lighting",
               "Navigation",
               "Networking",
               "Rendering",
               "Shape",
               "Texturing",
               "Time",
           ])

      add (title: "Medical interchange",
           name: "MedicalInterchange",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
               "EnvironmentalEffects",
               "EventUtilities",
               "Geometry2D",
               "Geometry3D",
               "Grouping",
               "Interpolation",
               "Lighting",
               "Navigation",
               "Networking",
               "Rendering",
               "Shape",
               "Text",
               "Texturing",
               "Texturing3D",
               "Time",
               "VolumeRendering",
           ])

      add (title: "MPEG-4 interactive",
           name: "MPEG-4",
           providerUrl: X3DBrowser .providerUrl .description,
           components: [
               "Core",
               "EnvironmentalEffects",
               "EnvironmentalSensor",
               "Geometry3D",
               "Grouping",
               "Interpolation",
               "Lighting",
               "Navigation",
               "Networking",
               "PointingDeviceSensor",
               "Rendering",
               "Shape",
               "Texturing",
               "Time",
           ])

      return profiles
   }
}
