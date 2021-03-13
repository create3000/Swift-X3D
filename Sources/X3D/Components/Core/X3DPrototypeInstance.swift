//
//  X3DPrototypeInstance.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DPrototypeInstance :
   X3DNode
{
   // Common properties
   
   internal final override class var typeName       : String { "X3DPrototypeInstance" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   
   public final override func getTypeName () -> String { protoNode! .getName () }

   // Properties
   
   @SFNode public var protoNode : X3DProtoDeclarationNode?
   @SFNode public var body      : X3DExecutionContext?
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext, from protoNode : X3DProtoDeclarationNode)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.X3DPrototypeInstance)

      addField (.inputOutput, "metadata", $metadata)
      
      for protoField in protoNode .getUserDefinedFields ()
      {
         addField (protoField .getAccessType (), protoField .getName (), protoField .copy ())
      }

      addChildObjects ($protoNode,
                       $body)
      
      self .protoNode = protoNode
      
      self .protoNode! .addInterest ("update", { $0 .update () }, self)

      if let externproto = protoNode as? X3DExternProtoDeclaration
      {
         DispatchQueue .main .async { externproto .requestImmediateLoad () }
      }
      
      update ()
   }
   
   internal final override func create (with executionContext : X3DExecutionContext) -> X3DPrototypeInstance
   {
      return X3DPrototypeInstance (with: executionContext, from: protoNode!)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
   }
   
   private func update ()
   {
      guard let proto = protoNode! .proto else
      {
         body = X3DExecutionContext (browser!, executionContext!)
         
         body! .setup ()

         // Inform parents about root node change.
         addEvent ()
         return
      }
      
      for protoField in proto .getUserDefinedFields ()
      {
         if let field = try? getField (name: protoField .getName ())
         {
            // Continue if something is wrong.
            guard field .getAccessType () == protoField .getAccessType () else { continue }

            // Continue if something is wrong.
            guard field .getType () == protoField .getType () else { continue }

            // Continue if field is eventIn or eventOut.
            guard field .isInitializable else { continue }

            // Is set during parse or later.
            guard !field .isSet else { continue }

            // Has IS references.
            guard field .references .count == 0 else { continue }

            // Fields are equal.
            //guard !field .equals (protoField)) else { continue }
            
            // If default value of protoField is different from field update default value for field.
            field .set (value: protoField)
         }
         else
         {
            // Definition exists in proto but does not exist in extern proto.
            addField (protoField .getAccessType (), protoField .getName (), protoField .copy ())
         }
      }
      
      for field in getFieldDefinitions ()
      {
         guard field !== $metadata else { continue }
         
         if (try? proto .getField (name: field .getName ())) == nil
         {
            removeField (field)
         }
      }
      
      // Create body.

      body = X3DExecutionContext (browser!, proto .executionContext)
      
      // Extern protos
      
      for externproto in proto .body .getExternProtoDeclarations ()
      {
         try! body! .updateExternProtoDeclaration (name: externproto .getName (), externproto: externproto)
      }
      
      // Protos
      
      for proto in proto .body .getProtoDeclarations ()
      {
         try! body! .updateProtoDeclaration (name: proto .getName (), proto: proto)
      }
      
      // Root nodes
      
      for rootNode in proto .body .rootNodes
      {
         if rootNode == nil
         {
            body! .rootNodes .append (nil)
         }
         else
         {
            body! .rootNodes .append (rootNode! .copy (with: self))
         }
      }
      
      // Imported nodes
      
      // Routes
      
      for route in proto .body .getRoutes ()
      {
         let sourceNode       = try! body! .getNamedNode (name: route .sourceNode! .getName ())
         let sourceField      = route .sourceField! .getName ()
         let destinationNode  = try! body! .getNamedNode (name: route .destinationNode! .getName ())
         let destinationField = route .destinationField! .getName ()
         
         _ = try! body! .addRoute (sourceNode: sourceNode,
                                   sourceField: sourceField,
                                   destinationNode: destinationNode,
                                   destinationField: destinationField)
      }
      
      body! .setup ()

      // Inform parents about root node change.
      addEvent ()
   }

   // Root node handling

   internal final override var innerNode : X3DNode?
   {
      guard !body! .rootNodes .isEmpty else { return nil }

      return body! .rootNodes [0]? .innerNode
   }
   
   // Field handling
   
   public final override func isDefaultValue (of name : String) throws -> Bool
   {
      let field = try getField (name: name)
      
      if field === $metadata
      {
         return metadata == nil
      }
      
      guard let other = try? protoNode? .getField (name: field .getName ()) else
      {
         return false
      }
      
      return other .equals (to: field)
   }
   
   // Input/Output

   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      guard !stream .isSharedNode (self) else
      {
         stream += stream .Indent
         stream += "<!-- NULL -->"
         return
      }
      
      stream .enterScope ()
      
      defer { stream .leaveScope () }
      
      let name = stream .getName (self)
      
      if !name .isEmpty
      {
         if stream .existsNode (self)
         {
            stream += stream .Indent
            stream += "<ProtoInstance"
            stream += stream .Space
            stream += "name='"
            stream += getTypeName () .toXMLString ()
            stream += "'"
            stream += stream .Space
            stream += "USE='"
            stream += name .toXMLString ()
            stream += "'"
            
            if let containerField = stream .containerField
            {
               if containerField .getName () != getContainerField ()
               {
                  stream += stream .Space
                  stream += "containerField='"
                  stream += containerField .getName () .toXMLString ()
                  stream += "'"
               }
            }

            stream += "/>"
            return
         }
      }
      
      stream += stream .Indent
      stream += "<ProtoInstance"
      stream += stream .Space
      stream += "name='"
      stream += getTypeName () .toXMLString ()
      stream += "'"

      if !name .isEmpty
      {
         stream .addNode (self)

         stream += stream .Space
         stream += "DEF='"
         stream += name .toXMLString ()
         stream += "'"
      }
      
      if let containerField = stream .containerField
      {
         if containerField .getName () != getContainerField ()
         {
            stream += stream .Space
            stream += "containerField='"
            stream += containerField .getName () .toXMLString ()
            stream += "'"
         }
      }

      let fields = getChangedFields ()
      
      if fields .isEmpty
      {
         stream += "/>"
      }
      else
      {
         stream += ">"
         stream += stream .TidyBreak
         stream += stream .IncIndent ()
         
         var references = [X3DField] ()
         
         for field in fields
         {
            if !stream .metadata && field === $metadata
            {
               continue
            }
            
            // If the field is a inputOutput and we have as reference only inputOnly or outputOnly we must output the value
            // for this field.

            var mustOutputValue = false

            if field .getAccessType () == .inputOutput && !field .references .allObjects .isEmpty
            {
               var initializableReference = false

               for reference in field .references .allObjects
               {
                  initializableReference = initializableReference || reference .isInitializable
               }

               mustOutputValue = !initializableReference && !(try! isDefaultValue (of: field .getName ()))
            }

            if field .references .allObjects .isEmpty || mustOutputValue
            {
               if mustOutputValue
               {
                  references .append (field)
               }
               
               switch field .getType ()
               {
                  case .MFNode: do
                  {
                     let array = field as! X3DArrayField
                     
                     stream += stream .Indent
                     stream += "<fieldValue"
                     stream += stream .Space
                     stream += "name='"
                     stream += field .getName () .toXMLString ()
                     stream += "'"

                     if array .count == 0
                     {
                        stream += "/>"
                        stream += stream .TidyBreak
                     }
                     else
                     {
                        stream .containerFields .append (field)

                        stream += ">"
                        stream += stream .TidyBreak
                        stream += stream .IncIndent ()
                        stream += stream .toXMLStream (field)
                        stream += stream .TidyBreak
                        stream += stream .DecIndent ()
                        stream += stream .Indent
                        stream += "</fieldValue>"
                        stream += stream .TidyBreak

                        stream .containerFields .removeLast ()
                     }
                  }
                  case .SFNode: do
                  {
                     let node = field as! SFNode

                     if node .wrappedValue != nil
                     {
                        stream .containerFields .append (field)

                        stream += stream .Indent
                        stream += "<fieldValue"
                        stream += stream .Space
                        stream += "name='"
                        stream += field .getName () .toXMLString ()
                        stream += "'"
                        stream += ">"
                        stream += stream .TidyBreak
                        stream += stream .IncIndent ()
                        stream += stream .toXMLStream (field)
                        stream += stream .TidyBreak
                        stream += stream .DecIndent ()
                        stream += stream .Indent
                        stream += "</fieldValue>"
                        stream += stream .TidyBreak

                        stream .containerFields .removeLast ()
                        
                        break
                     }
                     
                     fallthrough
                  }
                  default: do
                  {
                     stream += stream .Indent
                     stream += "<fieldValue"
                     stream += stream .Space
                     stream += "name='"
                     stream += field .getName () .toXMLString ()
                     stream += "'"
                     stream += stream .Space
                     stream += "value='"
                     stream += stream .toXMLStream (field)
                     stream += "'"
                     stream += "/>"
                     stream += stream .TidyBreak
                  }
               }
            }
            else
            {
               references .append (field)
            }
         }
                  
         if !references .isEmpty && stream .inProto
         {
            stream += stream .Indent
            stream += "<IS>"
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            for field in references
            {
               for reference in field .references .allObjects
               {
                  stream += stream .Indent
                  stream += "<connect"
                  stream += stream .Space
                  stream += "nodeField='"
                  stream += field .getName () .toXMLString ()
                  stream += "'"
                  stream += stream .Space
                  stream += "protoField='"
                  stream += reference .getName () .toXMLString ()
                  stream += "'"
                  stream += "/>"
                  stream += stream .TidyBreak
               }
            }

            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "</IS>"
            stream += stream .TidyBreak
         }

         stream += stream .DecIndent ()
         stream += stream .Indent
         stream += "</ProtoInstance>"
      }
   }

   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      guard !stream .isSharedNode (self) else
      {
         stream += "NULL"
         return
      }
      
      stream .enterScope ()
      
      defer { stream .leaveScope () }
      
      let name = stream .getName (self)

      // USE name

      if !name .isEmpty
      {
         if stream .existsNode (self)
         {
            stream += "{"
            stream += stream .TidySpace
            stream += "\""
            stream += "ProtoInstance"
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
            stream += "@name"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "\""
            stream += getTypeName () .toJSONString ()
            stream += "\""
            stream += ","
            stream += stream .TidyBreak

            stream += stream .Indent
            stream += "\""
            stream += "@USE"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "\""
            stream += name .toJSONString ()
            stream += "\""
            stream += stream .TidyBreak
            
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "}"
            stream += stream .TidyBreak
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "}"

            return
         }
      }

      stream .lastProperties .append (false)

      // Type name

      stream += "{"
      stream += stream .TidySpace
      stream += "\""
      stream += "ProtoInstance"
      stream += "\""
      stream += ":"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      // DEF name

      if !name .isEmpty
      {
         stream .addNode (self)

         stream += stream .Indent
         stream += "\""
         stream += "@DEF"
         stream += "\""
         stream += ":"
         stream += stream .TidySpace
         stream += "\""
         stream += name .toJSONString ()
         stream += "\""

         stream .lastProperty = true
      }
      
      // Type name

      if stream .lastProperty
      {
         stream += ","
         stream += stream .TidyBreak
      }

      stream += stream .Indent
      stream += "\""
      stream += "@name"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += getTypeName () .toJSONString ()
      stream += "\""

      stream .lastProperty = true

      // Fields

      var fields = getChangedFields ()
      
      if !stream .metadata
      {
         fields = fields .filter { $0 !== $metadata }
      }

      // Predefined fields

      if !fields .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         var outputFields = [X3DField] ()
         var references   = [X3DField] ()

         for field in fields
         {
            // If the field is a inputOutput and we have as reference only inputOnly or outputOnly we must output the value
            // for this field.

            var mustOutputValue = false

            if field .getAccessType () == .inputOutput && !field .references .allObjects .isEmpty
            {
               var initializableReference = false

               for reference in field .references .allObjects
               {
                  initializableReference = initializableReference || reference .isInitializable
               }

               mustOutputValue = !initializableReference && !(try! isDefaultValue (of: field .getName ()))
            }

            // If we have no execution context we are not in a proto and must not generate IS references the same is true
            // if the node is a shared node as the node does not belong to the execution context.

            if field .references .allObjects .isEmpty || mustOutputValue
            {
               if mustOutputValue
               {
                  references .append (field)
               }

               outputFields .append (field)
            }
            else
            {
               references .append (field)
            }
         }

         stream += stream .Indent
         stream += "\""
         stream += "fieldValue"
         stream += "\""
         stream += ":"
         stream += stream .TidySpace
         stream += "["
         stream += stream .TidyBreak
         stream += stream .IncIndent ()

         for i in 0 ..< outputFields .count
         {
            let field = outputFields [i]
            
            if field .isInitializable
            {
               switch field .getType ()
               {
                  case .MFNode: do
                  {
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
                     stream += field .getName () .toJSONString ()
                     stream += "\""
                     stream += ","
                     stream += stream .TidyBreak
                     stream += stream .Indent
                     stream += "\""
                     stream += "-children"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "}"
                  }
                  case .SFNode: do
                  {
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
                     stream += field .getName () .toJSONString ()
                     stream += "\""
                     stream += ","
                     stream += stream .TidyBreak
                     stream += stream .Indent
                     stream += "\""
                     stream += "-children"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += "["
                     stream += stream .TidyBreak
                     stream += stream .IncIndent ()
                     stream += stream .Indent
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "]"
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "}"
                  }
                  default: do
                  {
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
                     stream += field .getName () .toJSONString ()
                     stream += "\""
                     stream += ","
                     stream += stream .TidyBreak
                     stream += stream .Indent
                     stream += "\""
                     stream += "@value"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "}"
                  }
               }
 
               if i != outputFields .count - 1
               {
                  stream += ","
                  stream += stream .TidyBreak
               }
            }
         }
         
         stream += stream .TidyBreak
         stream += stream .DecIndent ()
         stream += stream .Indent
         stream += "]"

         stream .lastProperty = true

         // IS references

         if !references .isEmpty && stream .inProto
         {
            if stream .lastProperty
            {
               stream += ","
               stream += stream .TidyBreak
            }

            stream += stream .Indent
            stream += "\""
            stream += "IS"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "{"
            stream += stream .TidyBreak
            stream += stream .IncIndent ()
            stream += stream .Indent
            stream += "\""
            stream += "connect"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            for field in references
            {
               let r = field .references .allObjects
               
               for i in 0 ..< r .count
               {
                  let reference = r [i]
                  
                  stream += stream .Indent
                  stream += "{"
                  stream += stream .TidyBreak
                  stream += stream .IncIndent ()

                  stream += stream .Indent
                  stream += "\""
                  stream += "@nodeField"
                  stream += "\""
                  stream += ":"
                  stream += stream .TidySpace
                  stream += "\""
                  stream += field .getName () .toJSONString ()
                  stream += "\""
                  stream += ","
                  stream += stream .TidyBreak

                  stream += stream .Indent
                  stream += "\""
                  stream += "@protoField"
                  stream += "\""
                  stream += ":"
                  stream += stream .TidySpace
                  stream += "\""
                  stream += reference .getName () .toJSONString ()
                  stream += "\""
                  stream += stream .TidyBreak

                  stream += stream .DecIndent ()
                  stream += stream .Indent
                  stream += "}"

                  if !(field === references .last && i == r .count - 1)
                  {
                     stream += ","
                  }

                  stream += stream .TidyBreak
               }
            }
            
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"
            stream += stream .TidyBreak
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "}"
         }

         stream .lastProperty = true
      }

      // End

      if stream .lastProperty
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
      
      stream .lastProperties .removeLast ()
   }
}
