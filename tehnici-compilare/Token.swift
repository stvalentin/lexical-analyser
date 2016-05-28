//
//  Token.swift
//  tehnici-compilare
//
//  Created by Stanciu Valentin on 12/04/16.
//  Copyright © 2016 Stanciu Valentin. All rights reserved.
//

import Foundation

struct TokenError: ErrorType {
    var errorType: String;
    var errorLine: String;
    var errorPosition: String;
    
    func getLine() {
        
    }
    
    func getPosition() {
        
    }
    
    func getType() {
        
    }
}


enum TokenType: String {
    case Base = "Base";
    case Identifier = "Literal";
    case Keyword = "Cuvant Cheie"
    case Number = "Literal Intreg"
    case Literal = "Literal String"
    case Delimiter = "Delimitator"
    case Space = "Spatiu"
    case Comment = "Commentariu"
    case Operand = "Operand"
}


struct Token: Hashable {
    var type: Tokenize;
    var TypeValue: String;
    var characterPosition: Int;
    
    var hashValue: Int {
        return TypeValue.hashValue;
    }
    
    func getTokenType() -> String {
        return type.getTokenType();
    }
    
    func getTypeValue() -> String {
        return TypeValue;
    }
}

func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.TypeValue == rhs.TypeValue
}
