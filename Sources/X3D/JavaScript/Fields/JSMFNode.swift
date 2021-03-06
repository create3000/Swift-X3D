//
//  JSMFNode.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFNodeExports :
   JSExport
{
   typealias SFNode     = JavaScript .SFNode
   typealias MFNode     = JavaScript .MFNode
   typealias X3DBrowser = JavaScript .X3DBrowser
   
   init ()
   
   func equals (_ array : MFNode?) -> Any?
   func assign (_ array : MFNode?)

   func get1Value (_ index : Int) -> JSValue?
   func set1Value (_ index : Int, _ value : SFNode?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFNode :
      X3DArrayField,
      MFNodeExports
   {
      typealias Internal = X3D .MFNode <X3D .X3DNode>

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFNode"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, false, \"MFNode\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFNode .self) as? SFNode)? .field .wrappedValue
            })
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
      }

      private init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFNode"]! .construct (withArguments: [MFNode (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFNode?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFNode?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> JSValue?
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: nil)
         }
         
         let node = field .wrappedValue [index]
         
         guard node != nil else
         {
            return nil
         }
         
         let field = SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: node))!
         
         return field
      }
      
      public final func set1Value (_ index : Int, _ value : SFNode?)
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: nil)
         }

         field .wrappedValue [index] = value? .field .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         set { field .wrappedValue .resize (newValue, fillWith: nil) }
      }
   }
}
