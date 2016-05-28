//
//  Scanner.swift
//  tehnici-compilare
//
//  Created by Stanciu Valentin on 11/04/16.
//  Copyright © 2016 Stanciu Valentin. All rights reserved.
//

import Foundation


//obiectul scanner va retine prin membrii sai data pozitia in codul sursa
//pana la care a ajuns cu scanarea
class Scanner {
    
    private var cursorPosition: Int = 0;
    private let input: String;
    private var status = 0;
    
    
    init(input: String) {
        self.input = input;
    }
    
    
    func shouldContinue() -> Bool {
        if (input.characters.count == cursorPosition || status == 1) {
            return false;
        }
        return true;
    }
    
    
    //thows TokenError
    // -> Token
    func getToken() -> Token {
        
        if (input.characters.count == cursorPosition) {
            return Token(type: Tokenize(), TypeValue: "DONE", characterPosition: cursorPosition);
        }
        
        let tokenizers: [Tokenize] = [
            TokenizeIdentifier(),
            TokenizeNumber(), // eg: 123 
            TokenizeLiteral(),
            TokenizerComments(),
            TokenizerSpace(),
            TokenizerOperand(),
            TokenizeDelimiter()
        ];
        
        
        //iterate over tokenizer until will find an AFD that will accept that first characters
        //until it will find the first the first character that will be a space or it will not accept it
        //cand nici un afd nu o sa accepte inseamna ca ii o problema
        //input.
        //input.substringFromIndex(cursorPosition)
        
        for token: Tokenize in tokenizers {
            var index = input.startIndex.advancedBy(cursorPosition);
            var tempCursorPosition = cursorPosition;
            var automat = true;
            
            
            while (automat && index <= input.endIndex.advancedBy(-1)) {
                
                var character = input[index];
                if (input[index] == "\n" || input[index] == "\r\n") {
                    character = Character.init(" ");
                }
                
                
                automat = token.addState(character, isFinal: tempCursorPosition == input.characters.count);
                
                if automat != true {
                    continue;
                }
                
                if token.status == TokenStatus.Blocking || token.status == TokenStatus.Success {
                    if (token.status == TokenStatus.Success) {
                        tempCursorPosition = tempCursorPosition + 1;
                    }
                    cursorPosition = tempCursorPosition;
                    return Token(type: token, TypeValue: token.validValue, characterPosition: cursorPosition);
                }
                
                if token.status == TokenStatus.Error {
                    status = 1;
                    return Token(type: token, TypeValue: token.validValue, characterPosition: cursorPosition);
                }
                
                if automat == true {
                    index = index.successor();
                    tempCursorPosition += 1;
                } else {
                    index = index.predecessor();
                    tempCursorPosition -= 1;
                }
            }
        }
        
        //de sters
        status = 1;
        return Token(type: Tokenize(), TypeValue: "lipsete productie", characterPosition: cursorPosition);
    }
}