//
//  main.swift
//  tehnici-compilare
//
//  Created by Stanciu Valentin on 11/04/16.
//  Copyright © 2016 Stanciu Valentin. All rights reserved.
//

import Foundation

/**
 source -> lexycalanalizer -> token ->parser
 */

let directoryTests = "/Users/stanciuvalentin/Documents/AppDevelopment/tehnici-compilare/tehnici-compilare/teste/";

if let response = readLine() {
    
    //response
    let fileManager = NSFileManager.defaultManager();
    let currentDirectory = fileManager.currentDirectoryPath;
    
    let filePathExists  = directoryTests + response;
    
    var content = response;
    var outputBufferConsole = true;
    if (fileManager.fileExistsAtPath(filePathExists)) {
        //filePathExists
        content = try String(contentsOfFile: filePathExists);
        outputBufferConsole = false;
    }
    
    let analizator = LexicalAnalizer(input: content);
    
    var result: Set<Token>;
    result = analizator.run();
    
    var output = "";
    for item in result {
        let out = item.TypeValue + "\t" + item.characterPosition.description;
        output += item.getTokenType() + "\t" + out + "\n";
    }
    
    //to be removed
    //print(output);
    
    if outputBufferConsole == true {
        print(output);
    } else {
        let outputFile = directoryTests + "output.out";
        let fileHandle = NSFileHandle.init(forWritingAtPath: outputFile);
        
        try output.writeToFile(outputFile, atomically: true, encoding: NSASCIIStringEncoding);
    }
    
}

/**
 getToken() throws  TokenError
 
 
 
 
 
 
 
 
 */