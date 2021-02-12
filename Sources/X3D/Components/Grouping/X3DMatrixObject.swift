//
//  File.swift
//  
//
//  Created by Holger Seelig on 12.02.21.
//

public protocol X3DMatrixObject :
   X3DNode
{
   var matrix : Matrix4f { get }
}
