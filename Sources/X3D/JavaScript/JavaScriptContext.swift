//
//  File.swift
//  
//
//  Created by Holger Seelig on 23.11.20.
//

import JavaScriptCore

internal class JavaScript { }

extension JavaScript
{
   internal final class Context
   {
      // Properties
      
      private unowned let browser : X3DBrowser
      private let context         : JSContext
      
      // Static properties
      
      private static let queue = DispatchQueue (label: "create3000.ecmascript")
      private static let vm    = queue .sync { JSVirtualMachine ()! }

      // Construction
      
      internal init (browser : X3DBrowser, script : String)
      {
         self .browser = browser
         self .context = JSContext (virtualMachine: Context .vm)!
         
         context .exceptionHandler = { [weak self] in self? .exception ($1) }
         
         // Register objects and functions.

         register ()
         
         // Evaluate script source.
         
         context .evaluateScript (script)
      }
      
      private final func register ()
      {
         // Register objects and functions.

         JavaScript .Global .register (context, browser)
         
         context .setObject (SFVec3f .self, forKeyedSubscript: "SFVec3f" as NSString)
      }
      
      internal final func initialize ()
      {
         let initialize = context .objectForKeyedSubscript ("initialize")
         
         initialize? .call (withArguments: nil)
      }
      
      private final func exception (_ exception : JSValue?)
      {
         browser .console .error (exception! .toString ())
      }
   }
}

extension JavaScript
{
   internal final class Global
   {
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         let print: @convention(block) () -> Void =
         {
            if let args = JSContext .currentArguments () as? [JSValue]
            {
               browser .println (args .map { $0 .toString () } .joined (separator: " "))
            }
         }
         
         let null = JSValue (nullIn: context)
         
         context .setObject (null,  forKeyedSubscript: "NULL"  as NSString)
         context .setObject (false, forKeyedSubscript: "FALSE" as NSString)
         context .setObject (true,  forKeyedSubscript: "TRUE"  as NSString)
         context .setObject (print, forKeyedSubscript: "print" as NSString)
         context .setObject (print, forKeyedSubscript: "trace" as NSString)
      }
   }
}

@objc internal protocol SFVec3fExports :
   JSExport
{
   var x : Float { get set }
   var y : Float { get set }
   var z : Float { get set }
   
   init ()
   
   subscript (index : String) -> Float { get set }

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class SFVec3f :
      NSObject,
      SFVec3fExports
   {
      // Properties
      
      dynamic public var x : Float { get { object .wrappedValue .x } set { object .wrappedValue .x = newValue } }
      dynamic public var y : Float { get { object .wrappedValue .y } set { object .wrappedValue .y = newValue } }
      dynamic public var z : Float { get { object .wrappedValue .z } set { object .wrappedValue .z = newValue } }
      
      // Private properties
      
      private final var object : X3D .SFVec3f
      
      // Construction
      
      required public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 3
         {
            self .object = X3D .SFVec3f (wrappedValue: Vector3f (args [0] .toFloat (),
                                                                 args [1] .toFloat (),
                                                                 args [2] .toFloat ()))
         }
         else
         {
            self .object = X3D .SFVec3f ()
         }
      }
      
      required internal init (object : X3D .SFVec3f)
      {
         self .object = object
      }
      
      public final subscript (index : String) -> Float
      {
         get { object .wrappedValue [Int (index) ?? 0] }
         set { object .wrappedValue [Int (index) ?? 0] = newValue }
      }
      
      public final override func value (withName name: String, inPropertyWithKey key: String) -> Any?
      {
         return 987
      }
      
      public final func toString () -> String
      {
         let value = object .wrappedValue
         
         return "\(value .x) \(value .y) \(value .z)"
      }
   }
}

extension JSValue
{
   internal func toFloat () -> Float
   {
      return Float (toDouble ())
   }
}
