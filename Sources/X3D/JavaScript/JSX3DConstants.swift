//
//  File.swift
//  
//
//  Created by Holger Seelig on 29.11.20.
//

import JavaScriptCore

@objc internal protocol X3DConstantsExports :
   JSExport
{ }

extension JavaScript
{
   @objc internal final class X3DConstants :
      NSObject,
      X3DConstantsExports
   {
      // Construction
      
      public static func register (_ context : JSContext)
      {
         context ["X3DConstants"] = X3DConstants ()
         
         context .evaluateScript ("""
[\(X3DBrowserEvent .allCases .map { "[\"\($0)\", \(String ($0 .rawValue))]" } .joined (separator: ","))]
.forEach (function (value)
{
   Object .defineProperty (X3DConstants, value [0], {
      value: value [1],
      enumerable: true,
      configurable: false,
   });
});

[\(X3DLoadState .allCases .map { "[\"\($0)\", \(String ($0 .rawValue))]" } .joined (separator: ","))]
.forEach (function (value)
{
   Object .defineProperty (X3DConstants, value [0], {
      value: value [1],
      enumerable: true,
      configurable: false,
   });
});

[\(X3DAccessType .allCases .map { "[\"\($0)\", \(String ($0 .rawValue))]" } .joined (separator: ","))]
.forEach (function (value)
{
   Object .defineProperty (X3DConstants, value [0], {
      value: value [1],
      enumerable: true,
      configurable: false,
   });
});

[\(X3DFieldType .allCases .map { "[\"\($0)\", \(String ($0 .rawValue))]" } .joined (separator: ","))]
.forEach (function (value)
{
   Object .defineProperty (X3DConstants, value [0], {
      value: value [1],
      enumerable: true,
      configurable: false,
   });
});

[\(X3DNodeType .allCases .map { "[\"\($0)\", \(String ($0 .rawValue))]" } .joined (separator: ","))]
.forEach (function (value)
{
   Object .defineProperty (X3DConstants, value [0], {
      value: value [1],
      enumerable: true,
      configurable: false,
   });
});

DefineProperty (this, "X3DConstants", X3DConstants);
""")
      }
      
      internal override init () { }
   }
}
