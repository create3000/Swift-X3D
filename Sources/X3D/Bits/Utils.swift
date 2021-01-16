//
//  File.swift
//  
//
//  Created by Holger Seelig on 16.01.21.
//

public func exchange <Type> (_ variable : inout Type, _ newValue : Type) -> Type
{
   let oldValue = variable
   
   variable = newValue
   
   return oldValue
}
