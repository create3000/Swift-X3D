//
//  File.swift
//  
//
//  Created by Holger Seelig on 18.01.21.
//

public final class X3DExportedNode :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "X3DExportedNode" }
   
   // Properties
   
   public private(set) final weak var scene     : X3DScene?
   public final let exportedName                : String
   public private(set) final weak var localNode : X3DNode?

   // Construction
   
   internal init (_ scene : X3DScene,
                  _ exportedName : String,
                  _ localNode : X3DNode)
   {
      self .scene        = scene
      self .exportedName = exportedName
      self .localNode    = localNode
      
      super .init ()
      
      localNode .deleted .addInterest ("deleted", X3DExportedNode .set_node, self)
   }
   
   private final func set_node ()
   {
      scene? .removeExportedNode (exportedName: exportedName)
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      guard let localName = stream .getLocalName (localNode) else { return }
      
      stream += stream .Indent
      stream += "<EXPORT"
      stream += stream .Space
      stream += "localDEF='"
      stream += localName .toXMLString ()
      stream += "'"

      if exportedName != localName
      {
         stream += stream .Space
         stream += "AS='"
         stream += exportedName .toXMLString ()
         stream += "'"
      }

      stream += "/>"
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      guard let localName = stream .getLocalName (localNode) else { return }
      
      stream += "{"
      stream += stream .TidySpace
      stream += "\""
      stream += "EXPORT"
      stream += "\""
      stream += ":"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      stream += stream .Indent
      stream += "\""
      stream += "@localDEF"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += localName .toJSONString ()
      stream += "\""

      if exportedName != localName
      {
         stream += ","
         stream += stream .TidyBreak
         stream += stream .Indent
         stream += "\""
         stream += "@AS"
         stream += "\""
         stream += ":"
         stream += stream .TidySpace
         stream += "\""
         stream += exportedName .toJSONString ()
         stream += "\""
         stream += stream .TidyBreak
      }
      else
      {
         stream += stream .TidyBreak
      }

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
   }
 
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let localName = stream .getLocalName (localNode) else { return }
      
      stream += stream .Indent
      stream += "EXPORT"
      stream += stream .Space
      stream += localName

      if exportedName != localName
      {
         stream += stream .Space
         stream += "AS"
         stream += stream .Space
         stream += exportedName
      }
      
      stream += stream .Break
  }
}
