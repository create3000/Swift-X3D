//
//  UnitInfo.swift
//  X3D
//
//  Created by Holger Seelig on 21.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class UnitInfo :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "UnitInfo" }
   
   // Properties
   
   public final let category         : X3DUnitCategory
   public final let name             : String
   public final let conversionFactor : Double
   
   // Construction
   
   internal init (category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      self .category         = category
      self .name             = name
      self .conversionFactor = conversionFactor
      
      super .init ()
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += stream .Indent
      stream += "<unit"
      stream += stream .Space
      stream += "category='"
      stream += category .description
      stream += "'"
      stream += stream .Space
      stream += "name='"
      stream += name .escapeXML
      stream += "'"
      stream += stream .Space
      stream += "conversionFactor='"
      stream += String (format: stream .doubleFormat, conversionFactor)
      stream += "'"
      stream += "/>"
   }

   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      stream += stream .Indent
      stream += "\""
      stream += "@category"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += category .description
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "@name"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += name .escapeJSON
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "@conversionFactor"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += String (format: stream .doubleFormat, conversionFactor)
      stream += stream .TidyBreak

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += "UNIT"
      stream += stream .Space
      stream += category .description
      stream += stream .Space
      stream += name
      stream += stream .Space
      stream += String (format: stream .doubleFormat, conversionFactor)
   }
}
