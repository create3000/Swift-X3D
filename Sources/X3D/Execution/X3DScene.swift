//
//  X3DScene.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class X3DScene :
   X3DExecutionContext
{
   // Common properties
   
   internal final override class var typeName : String { "X3DScene" }
   
   // Properties
   
   public final override var scene : X3DScene? { self }

   // Construction
   
   internal init (with browser : X3DBrowser)
   {
      super .init (browser, nil)
      
      executionContext = self
      
      types .append (.X3DScene)
      
      addChildObjects ($isLive,
                       $profile_changed,
                       $components_changed,
                       $units_changed,
                       $metadata_changed,
                       $exportedNodes_changed)

      $rootNodes .setAccessType (.inputOutput)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
   }
   
   public internal(set) final override weak var executionContext : X3DExecutionContext?
   {
      willSet
      {
         executionContext? .scene? .$isLive .removeInterest ("set_live", X3DScene .set_live, self)
      }
      
      didSet
      {
         guard executionContext! .scene !== self else { return }
         
         executionContext! .scene! .$isLive .addInterest ("set_live", X3DScene .set_live, self)
         
         set_live ()
      }
   }
   
   // Scene properties
   
   private final var encoding             : String = "SCRIPTED"
   private final var specificationVersion : String = "3.3"
   private final var characterEncoding    : String = "utf8"
   private final var comment              : String = ""
   private final var worldURL             : URL    = URLComponents () .url!
   
   public final override func getEncoding () -> String { encoding }
   
   internal final override func setEncoding (_ value : String) { encoding = value }

   public final override func getSpecificationVersion () -> String { specificationVersion }
   
   internal final override func setSpecificationVersion (_ value : String) { specificationVersion = value }

   public final override func getCharacterEncoding () -> String { characterEncoding }

   internal final override func setCharacterEncoding (_ value : String) { characterEncoding = value }

   public final override func getComment () -> String { comment }

   internal final override func setComment (_ value : String) { comment = value }

   public final override func getWorldURL () -> URL { worldURL }

   internal final override func setWorldURL (_ value : URL) { worldURL = value }

   // Profile handling
   
   private final var profile : ProfileInfo = SupportedProfiles .profiles ["Full"]!
   
   public final override func getProfile () -> ProfileInfo { profile }
   
   internal final override func setProfile (_ value : ProfileInfo)
   {
      profile = value

      profile_changed = SFTime .now
   }
   
   @SFTime public final var profile_changed = 0

   // Components handling
   
   private final var components : [ComponentInfo] = [ ]

   public final override func getComponents () -> [ComponentInfo]
   {
      return components .sorted { $0 .name < $1 .name }
   }
   
   internal final override func setComponents (_ value : [ComponentInfo])
   {
      components = value
      
      components_changed = SFTime .now
   }
   
   internal final override func addComponent (_ component : ComponentInfo)
   {
      components .append (component)
      
      components_changed = SFTime .now
   }
   
   @SFTime public final var components_changed = 0

   // Unit handling
   
   private final let ANGLE  = 0
   private final let FORCE  = 1
   private final let LENGTH = 2
   private final let MASS   = 3

   private final var units : [UnitInfo] = [
      UnitInfo (category: .angle,  name: "radian",   conversionFactor: 1),
      UnitInfo (category: .force,  name: "newton",   conversionFactor: 1),
      UnitInfo (category: .length, name: "metre",    conversionFactor: 1),
      UnitInfo (category: .mass,   name: "kilogram", conversionFactor: 1),
   ]
   
   public final override func getUnits () -> [UnitInfo] { units }

   public final override func updateUnit (_ category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      switch category
      {
         case .angle:  units [ANGLE]  = UnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .force:  units [FORCE]  = UnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .length: units [LENGTH] = UnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .mass:   units [MASS]   = UnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         default: break
      }
      
      units_changed = SFTime .now
   }

   public final override func fromUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      switch category
      {
         // Unitless
         
         case .unitless: return value
         
         // Base units

         case .angle:  return value * units [ANGLE]  .conversionFactor
         case .force:  return value * units [FORCE]  .conversionFactor
         case .length: return value * units [LENGTH] .conversionFactor
         case .mass:   return value * units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value * units [LENGTH] .conversionFactor
         case .angular_rate: return value * units [ANGLE] .conversionFactor
         case .area:         return value * pow (units [LENGTH] .conversionFactor, 2)
         case .speed:        return value * units [LENGTH] .conversionFactor
         case .volume:       return value * pow (units [LENGTH] .conversionFactor, 3)
      }
   }
   
   public final override func fromUnit (_ category : X3DUnitCategory, value : Float) -> Float
   {
      return Float (fromUnit (category, value: Double (value)))
   }

   public final override func toUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      switch category
      {
         // Unitless
         
         case .unitless: return value
         
         // Base units

         case .angle:  return value / units [ANGLE]  .conversionFactor
         case .force:  return value / units [FORCE]  .conversionFactor
         case .length: return value / units [LENGTH] .conversionFactor
         case .mass:   return value / units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value / units [LENGTH] .conversionFactor
         case .angular_rate: return value / units [ANGLE] .conversionFactor
         case .area:         return value / pow (units [LENGTH] .conversionFactor, 2)
         case .speed:        return value / units [LENGTH] .conversionFactor
         case .volume:       return value / pow (units [LENGTH] .conversionFactor, 3)
      }
   }
   
   public final override func toUnit (_ category : X3DUnitCategory, value : Float) -> Float
   {
      return Float (toUnit (category, value: Double (value)))
   }
   
   @SFTime public final var units_changed = 0

   // Metadata handling
   
   private final var metadata : [String : [String]] = [:]
   
   public final func getMetaData (key : String) -> [String]?
   {
      return metadata [key]
   }
   
   public final func addMetaData (key : String, value : String)
   {
      metadata [key, default: [ ]] .append (value)
      
      metadata_changed = SFTime .now
   }
   
   public final func setMetaData (key : String, value : String)
   {
      metadata [key] = [value]
      
      metadata_changed = SFTime .now
   }
   
   public final func removeMetaData (key : String)
   {
      metadata .removeValue (forKey: key)
      
      metadata_changed = SFTime .now
   }
   
   public final func getMetaDatas () -> [(key : String, value : String)]
   {
      var result = [(key : String, value : String)] ()
      
      for (key, values) in metadata
      {
         for value in values .sorted ()
         {
            result .append ((key, value))
         }
      }
      
      result .sort { $0 .key < $1 .key }
      
      return result
   }

   @SFTime public final var metadata_changed = 0

   // Exported node handling
   
   private final var exportedNodes = [String : X3DExportedNode] ()

   public final func getExportedNode (exportedName : String) throws -> X3DNode
   {
      guard let exportedNode = exportedNodes [exportedName] else
      {
         throw X3DError .INVALID_NAME (t("Exported node '%@' not found.", exportedName))
      }
      
      return exportedNode .localNode!
   }

   public final func addExportedNode (exportedName : String, node : X3DNode) throws
   {
      guard exportedNodes [exportedName] == nil else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add exported node: exported name '%@' already in use.", exportedName))
      }

      try updateExportedNode (exportedName: exportedName, node: node)
   }
   
   public final func updateExportedNode (exportedName : String, node : X3DNode) throws
   {
      guard !exportedName .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't update exported node: node exported name is empty."))
      }

      exportedNodes [exportedName] = X3DExportedNode (self, exportedName, node)
      
      exportedNodes_changed = SFTime .now
   }
   
   public final func removeExportedNode (exportedName : String)
   {
      exportedNodes .removeValue (forKey: exportedName)
      
      exportedNodes_changed = SFTime .now
   }
   
   public final func getExportedNodes () -> [X3DExportedNode]
   {
      exportedNodes .map { _, exportedNode in exportedNode } .sorted { $0 .exportedName < $1 .exportedName }
   }
   
   @SFTime public final var exportedNodes_changed = 0

   // Update control
   
   @SFBool internal private(set) var isLive : Bool = false
   private final var live : Bool = false
   
   internal final func beginUpdate ()
   {
      live = true
      
      set_live ()
   }
   
   internal final func endUpdate ()
   {
      live = false
      
      set_live ()
   }
   
   private func set_live ()
   {
      let isLive = live || (executionContext !== self && executionContext! .scene! .isLive)
      
      if isLive != self .isLive
      {
         self .isLive = isLive
      }
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      var specificationVersion = getSpecificationVersion ()

      if specificationVersion == "2.0"
      {
         specificationVersion = "3.3"
      }
      
      // XML

      stream += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      stream += "\n"
      
      // DOCTYPE
      
      stream += "<!DOCTYPE X3D PUBLIC \"ISO//Web3D//DTD X3D "
      stream += specificationVersion
      stream += "//EN\" \"http://www.web3d.org/specifications/x3d-"
      stream += specificationVersion
      stream += ".dtd\">"
      stream += "\n"

      // <X3D>
      
      stream += "<X3D"
      stream += stream .Space
      stream += "profile='"
      stream += profile .name
      stream += "'"
      stream += stream .Space
      stream += "version='"
      stream += specificationVersion
      stream += "'"
      stream += stream .Space
      stream += "xmlns:xsd='http://www.w3.org/2001/XMLSchema-instance'"
      stream += stream .Space
      stream += "xsd:noNamespaceSchemaLocation='http://www.web3d.org/specifications/x3d-"
      stream += specificationVersion
      stream += ".xsd'>"
      stream += stream .TidyBreak

      // <head>
      
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "<head>"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      
      // Output components.
      
      for component in getComponents ()
      {
         stream += stream .toXMLStream (component)
         stream += stream .TidyBreak
      }
      
      // Output units.

      for unit in units
      {
         guard unit .conversionFactor != 1 else { continue }
         
         stream += stream .toXMLStream (unit)
         stream += stream .TidyBreak
      }
      
      // Output metadata.

      for (key, value) in getMetaDatas ()
      {
         stream += stream .Indent
         stream += "<meta"
         stream += stream .Space
         stream += "name='"
         stream += key .toXMLString ()
         stream += "'"
         stream += stream .Space
         stream += "content='"
         stream += value .toXMLString ()
         stream += "'"
         stream += "/>"
         stream += stream .TidyBreak
      }
 
      // </head>

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "</head>"
      stream += stream .TidyBreak
      
      // <Scene>
      
      stream += stream .Indent
      stream += "<Scene>"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      
      // Enter stream.

      stream .push (self)
      stream .enterScope ()
      stream .setExportedNodes (exportedNodes)
      
      // Output execution context.
      
      super .toXMLStream (stream)
      
      // Output exported nodes.
      
      for exportedNode in getExportedNodes ()
      {
         stream += stream .toXMLStream (exportedNode)
         stream += stream .TidyBreak
      }

      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)

      // </Scene>
         
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "</Scene>"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      
      // </X3D>
      
      stream += "</X3D>"
      stream += stream .TidyBreak
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      var specificationVersion = getSpecificationVersion ()

      if specificationVersion == "2.0"
      {
         specificationVersion = "3.3"
      }
      
      // X3D

      stream += "{"
      stream += stream .TidySpace
      stream += "\""
      stream += "X3D"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .IncIndent ()

      // Encoding

      stream += stream .Indent
      stream += "\""
      stream += "encoding"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += "UTF-8"
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      // Profile

      stream += stream .Indent
      stream += "\""
      stream += "@profile"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += profile .name
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      // Version

      stream += stream .Indent
      stream += "\""
      stream += "@version"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += specificationVersion
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      // XSD noNamespaceSchemaLocation

      stream += stream .Indent
      stream += "\""
      stream += "@xsd:noNamespaceSchemaLocation"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += "http://www.web3d.org/specifications/x3d-3.3.xsd"
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      // JSON schema

      stream += stream .Indent
      stream += "\""
      stream += "JSON schema"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += "http://www.web3d.org/specifications/x3d-3.3-JSONSchema.json"
      stream += "\""
      stream += ","
      stream += stream .TidyBreak
      
      // Head
      
      let components = getComponents ()
      let units      = getUnits () .filter { $0 .conversionFactor != 1 }
      let metadata   = getMetaDatas ()
      
      if !components .isEmpty,
         !units      .isEmpty,
         !metadata   .isEmpty
      {
         stream .lastProperties .append (false)

         stream += stream .Indent
         stream += "\""
         stream += "head"
         stream += "\""
         stream += ":"
         stream += stream .TidySpace
         stream += "{"
         stream += stream .TidyBreak
         stream += stream .IncIndent ()

         // Meta data

         if !metadata .isEmpty
         {
            if stream .lastProperty
            {
               stream += ","
               stream += stream .TidyBreak
            }

            // Meta data begin

            stream += stream .Indent
            stream += "\""
            stream += "meta"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            // Meta data

            for i in 0 ..< metadata .count
            {
               let (key, value) = metadata [i]
               
               stream += stream .Indent
               stream += "{"
               stream += stream .TidyBreak
               stream += stream .IncIndent ()

               stream += stream .Indent
               stream += "\""
               stream += "@name"
               stream += "\""
               stream += ":"
               stream += stream .TidySpace
               stream += "\""
               stream += key .toJSONString ()
               stream += "\""
               stream += ","
               stream += stream .TidyBreak

               stream += stream .Indent
               stream += "\""
               stream += "@content"
               stream += "\""
               stream += ":"
               stream += stream .TidySpace
               stream += "\""
               stream += value .toJSONString ()
               stream += "\""
               stream += stream .TidyBreak

               stream += stream .DecIndent ()
               stream += stream .Indent
               stream += "}"

               if i != metadata .count - 1
               {
                  stream += ","
               }

               stream += stream .TidyBreak
            }

            // Meta data end

            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"

            stream .lastProperty = true
         }
         
         // Components

         if !components .isEmpty
         {
            if stream .lastProperty
            {
               stream += ","
               stream += stream .TidyBreak
            }

            // Components begin

            stream += stream .Indent
            stream += "\""
            stream += "component"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            // Components

            for i in 0 ..< components .count
            {
               stream += stream .Indent
               stream += stream .toJSONStream (components [i])

               if i != components .count - 1
               {
                  stream += ","
               }

               stream += stream .TidyBreak
            }

            // Components end

            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"

            stream .lastProperty = true
         }

         // Units

         if !units .isEmpty
         {
            if stream .lastProperty
            {
               stream += ","
               stream += stream .TidyBreak
            }

            // Units begin

            stream += stream .Indent
            stream += "\""
            stream += "unit"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            // Units

            for i in 0 ..< units .count
            {
               stream += stream .Indent
               stream += stream .toJSONStream (units [i])

               if i != units .count - 1
               {
                  stream += ","
               }

               stream += stream .TidyBreak
            }

            // Unit end

            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"

            stream .lastProperty = true
         }

         // Head end

         stream += stream .TidyBreak
         stream += stream .DecIndent ()
         stream += stream .Indent
         stream += "}"
         stream += ","
         stream += stream .TidyBreak
         
         stream .lastProperties .removeLast ()
      }
      
      // Scene

      stream += stream .Indent
      stream += "\""
      stream += "Scene"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "\""
      stream += "-children"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "["
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      // Enter stream.

      stream .push (self)
      stream .enterScope ()
      stream .setExportedNodes (exportedNodes)

      // Enter X3DExecutionContext
      
      stream .lastProperties .append (false)
      
      super .toJSONStream (stream)
      
      // Exported nodes
      
      let exportedNodes = getExportedNodes () .map { stream .toJSONStream ($0, streaming: false) } .filter { !$0 .isEmpty }
      
      if !exportedNodes .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< exportedNodes .count
         {
            stream += stream .Indent
            stream += exportedNodes [i]

            if i != exportedNodes .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }
      
      stream .lastProperties .removeLast ()

      // Scene end

      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "]"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"

      // X3D end

      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak

      // Leave stream.
   
      stream .leaveScope ()
      stream .pop (self)
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let browser = browser else { return }
      
      // Output header.
      
      var specificationVersion = getSpecificationVersion ()

      if specificationVersion == "2.0"
      {
         specificationVersion = "3.3"
      }

      stream += "#X3D V"
      stream += specificationVersion
      stream += " "
      stream += "utf8"
      stream += " "
      stream += browser .getName ()
      stream += " "
      stream += "V"
      stream += browser .getVersion ()
      stream += "\n"
      stream += "\n"
      
      // Output profile.

      stream += stream .toVRMLStream (profile)
      stream += stream .Break
      stream += stream .TidyBreak
      
      // Output components.
      
      let components = getComponents ()
      
      if !components .isEmpty
      {
         for component in components
         {
            stream += stream .toVRMLStream (component)
            stream += stream .Break
         }
         
         stream += stream .TidyBreak
      }
      
      // Output units.
      
      let units = getUnits () .filter { $0 .conversionFactor != 1 }
      
      if !units .isEmpty
      {
         for unit in units
         {
            stream += stream .toVRMLStream (unit)
            stream += stream .Break
         }
         
         stream += stream .TidyBreak
      }
      
      // Output meta data.
      
      let metadata = getMetaDatas ()
      
      if !metadata .isEmpty
      {
         for (key, value) in metadata
         {
            stream += "META"
            stream += stream .Space
            stream += SFString (wrappedValue: key) .toVRMLString (with: self)
            stream += stream .Space
            stream += SFString (wrappedValue: value) .toVRMLString (with: self)
            stream += stream .Break
         }
         
         stream += stream .TidyBreak
      }

      // Enter stream.

      stream .push (self)
      stream .enterScope ()
      stream .setExportedNodes (exportedNodes)

      // Enter X3DExecutionContext
      
      super .toVRMLStream (stream)

      // Output exported nodes.
      
      let exportedNodes = getExportedNodes ()
      
      if !exportedNodes .isEmpty
      {
         stream += stream .Break
         
         for exportedNode in exportedNodes
         {
            stream += stream .toVRMLStream (exportedNode)
         }
      }
      
      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)
   }

   // Destruction
   
   deinit
   {
      #if DEBUG
      //debugPrint (#file, #function)
      #endif
   }
}
