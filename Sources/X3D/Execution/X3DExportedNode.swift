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
   
   public private(set) final var exportedName   : String
   public private(set) final weak var localNode : X3DNode?

   // Construction
   
   internal init (exportedName : String, localNode : X3DNode)
   {
      self .exportedName = exportedName
      self .localNode    = localNode
   }
   
   // Input/Output
   
   internal final override func toVRMLStream (_ stream: X3DOutputStream)
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
   }
}
