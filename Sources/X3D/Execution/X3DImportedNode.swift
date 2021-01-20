//
//  File.swift
//  
//
//  Created by Holger Seelig on 18.01.21.
//

public final class X3DImportedNode :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "X3DImportedNode" }
   
   // Properties
   
   public private(set) final weak var executionContext : X3DExecutionContext?
   public private(set) final weak var inlineNode       : Inline?
   public final let exportedName                       : String
   public final let importedName                       : String
   
   // Construction
   
   internal init (_ executionContext : X3DExecutionContext,
                  _ inlineNode : Inline,
                  _ exportedName : String,
                  _ importedName : String)
   {
      self .executionContext = executionContext
      self .inlineNode       = inlineNode
      self .exportedName     = exportedName
      self .importedName     = importedName
   }
   
   // Input/Output
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let inlineNode = inlineNode,
            stream .existsNode (inlineNode) else { return }
      
      stream += stream .Indent
      stream += "IMPORT"
      stream += stream .Space
      stream += stream .getName (inlineNode)
      stream += "."
      stream += exportedName

      if importedName != exportedName
      {
         stream += stream .Space
         stream += "AS"
         stream += stream .Space
         stream += importedName
      }
      
      stream += stream .Break
   }
}
