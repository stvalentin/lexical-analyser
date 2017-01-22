//
//  LexicalAnalyzer.swift
//  tehnici-compilare
//
//  Created by Stanciu Valentin on 11/04/16.
//  Copyright © 2016 Stanciu Valentin. All rights reserved.
//

import Foundation

enum ParserState {
    case Continue
    case Blocking;
    case Success;
    case Error;
}


class LexicalAnalizer {
    
    //aici vom identifica tipul de date returnat (get token)
    
    private var input: String;
    private var state: ParserState = .Success;
    
    init(input: String) {
        self.input = input;
    }
    
    
    //obiecul scanner va retine in membrii sai 
    //data pozitia in codul sursa in care a ajuns cu scanarea
    //func run() -> Set<Token> {
    func run() -> [Token] {

        let scanner = Scanner(input: self.input);
        var setTokens: [Token] = [];
        
        while scanner.shouldContinue() {
            let parsedToken =   scanner.getToken();
            
            if (parsedToken.type.tokenType == .Space || parsedToken.type.tokenType == .Comment) {
                continue;
            }
            setTokens.append(parsedToken);
            //setTokens.insert(parsedToken);
        }
        
        return setTokens;
    }
}
