//
//  Tokenize.swift
//  tehnici-compilare
//
//  Created by Stanciu Valentin on 11/04/16.
//  Copyright © 2016 Stanciu Valentin. All rights reserved.
//

import Foundation


/**
 definim tipurile de token folosind expresii regulate si sa recunostem tokenii
 folosind automate finite deterministe
 */

//pentru identificarea tokenilor folosim un AFD


//tre sa identificam cei mai luni tokeni care se pot forma de la pozitia curenta incolo

//
//un afd se poate reprezenta printr-o diagrama de tip graf orientat (slide 17)
 //-> varfuri reprezinta stari
 //-> arcele reprexinta tranzactii


//todo
//citire arbore binar prin adancime

//base tokenize class

/**
 *

 TODO: cuvinte cheie
 mai mult, pentru recunoasterea tokenilor-cuvinte cheie se poate folosi
 starea finala asociata tipului de token "identificator" si o cautare
 in tabelul cu cuvinte cheie al analizorului - deci daca automatul se
 blocheaza in starea finala asociata tipului de token "identificator",
 atunci va cauta sirul consumat in tabelul cu cuvinte cheie si: daca-l
 gaseste, va genera tokenul cu tipul "cuvant cheie" si valoarea data
 de sirul consumat, iar daca nu-l gaseste, va genera tokenul cu tipul
 "identificator" si valoarea data de acelasi sir consumat;
 
 
 TODO: scriere in fisier
 - programul supus analize lexicale va fi scris intr-un fisier de intrare,
 iar tokenii rezultati intr-un fisier de iesire;
 in programul principal se vor face initializari (de exemplu citirea
 numelor celor doua fisiere), apoi intr-un ciclu, la fiecare iteratie, se
 va apela o data gettoken apoi tokenul rezultat se va scrie in fisierul
 destinatie; atentie ca prelucrarea tokenului rezultat (scrierea lui in
 fisierul destinatie) se face in programul principal, nu intr-o metoda a
 analizorului lexical - acesta in principiu nu face decat gettoken pentru
 a furniza un nou token;
 in fisierul destinatie tokenii se vor scrie fiecare pe un rand, indicand
 in clar tipul si valoarea (deci prin stringuri, nu prin numere de
 ordine); de exemplu pentru programul Pascal "var x : integer; begin end."
 am putea obtine:
 cuvant cheie   - var
 identificator  - x
 ...
 in acest scop se vor scrie functii/metode prin care sa putem obtine
 stringurile din tabelele analizorului corespunzatoare pozitiilor stocate
 in tokenii returnati de gettoken;
 
 
 - in cazul intalnirii unei erori lexicale in fisierul analizat, gettoken
 va returna un token de eroare, al carui membru-tip va indica tipul erorii
 si al carui membru-valoare va indica pozitia in fisier unde se afla
 caracterul ce a generat eroarea;
 in programul principal, la receptionarea unui astfel de token se va scrie
 in fisierul destinatie un mesaj adecvat de eroare si pozitia respectiva,
 dupa care analiza se va opri.
 *
 */

enum TokenStatus: Int {
    case Continue = 0;
    case Blocking
    case Success
    case Error
}


class Tokenize: AnyObject {
    var validChars: [Character] = [];
    var validValue: String = "";
    var status: TokenStatus = .Continue;
    var tokenType: TokenType = .Base;
    
    /**
     * Check if character is digit [0-9]
     * @return bool
     */
    func isDigit(character: Character) -> Bool {
        if let caracterAsciiValue = String(character).unicodeScalars.first?.value {
            if (caracterAsciiValue >= 48 && caracterAsciiValue <= 57) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }
    
    
    func isSpace(character: Character) -> Bool {
        let emptyChar = Character.init(" ");
        
        if character == emptyChar {
            return true;
        }
        
        return false;
    }
    
    
    func addState(character: Character, isFinal: Bool) -> Bool {
        if validChars.contains(character) {
            validValue.append(character);
            if isFinal == true {
                self.status = .Success;
            } else {
                self.status = .Continue;
            }
            return true;
        }
        return false;
    }
    
    func getTokenType() -> String {
        return tokenType.rawValue;
    }
}


//identifier tokenize
/*
 todo:
 1) identify the longest token
 2) valid token will not start with a number
 3) identify keywoard
 */
class TokenizeIdentifier: Tokenize {
    
    let keywordsIdentifiers: [String] = ["auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "int", "long", "register", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"];
    
    override init() {
        super.init();
        //adding A..Z
        for c in 65...90 {
            validChars.append(Character(UnicodeScalar(c)));
        }
        //adding a..Z
        for c in 97...122 {
            validChars.append(Character(UnicodeScalar(c)));
        }
        //adding 0..9
        for c in 48...57 {
            validChars.append(Character(UnicodeScalar(c)));
        }
        
        validChars.append(Character.init("_"));
        
        tokenType = TokenType.Identifier;
    }
    
    override func addState(character: Character, isFinal: Bool = false) -> Bool {
        if validValue.characters.count == 0 && !validChars.contains(character) {
            //self.status = .Continue;
            return false;
        }
        
        if validValue.characters.count == 0 && isDigit(character) {
            return false;
        }
        
        
        if (super.addState(character, isFinal: isFinal)) {
            return true;
        }
        
        if self.status == .Continue {
            self.status = .Blocking;
            return true;
        }
        
        return false;
    }

    
/**
 * get token type
 */
    override func getTokenType() -> String {
        if keywordsIdentifiers.contains(validValue) {
            tokenType = .Keyword;
        }
        
        return super.getTokenType();
    }
    
}


/*
 todo: need a better implementation
 check what type of tokenize we have here
 possible to make 3 class
 
 float
 exponential
 hexa / octa
 */
class TokenizeNumber: Tokenize {
    override init() {
        super.init();
        validChars = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "e", "x"];
        tokenType = TokenType.Number;
    }
    
    override func addState(character: Character, isFinal: Bool) -> Bool {
        if (super.addState(character, isFinal: isFinal)) {
            if isFinal {
                self.status = .Success;
            }
            
            var dotCounter = 0;
            var expCounter = 0;
            
            
            for char in validValue.characters {
                if char == "." {
                    dotCounter = dotCounter + 1;
                }
                if char == "e" {
                    expCounter = expCounter + 1;
                }
            }
            
            if (dotCounter > 1 || expCounter > 1) {
                self.status = .Continue;
                return false;
            }
            
            if isFinal && (character == "e" || character == "x") {
                self.status = .Continue;
                return false;
            }
            
            return true;
        }
        
        if validValue.characters.count > 0 && self.status == .Continue {
            self.status = .Blocking;
            return true;
        }
        
        return false;
    }
}


//
/**
 *test words "pascal it\"s here" + beer  
 'it\'s not me' + "honey"
 */
class TokenizeLiteral: Tokenize {
    
    let escapedCharacter: String = "\\";
    var startCharacter: String = "";
    
    
    override init() {
        super.init();
        validChars = ["\"", "'"];
        tokenType = TokenType.Literal;
    }
    
    
    override func addState(character: Character, isFinal: Bool) -> Bool {
        if (super.addState(character, isFinal: isFinal)) {
            
            if startCharacter.isEmpty {
                startCharacter = String(character);
            }
            
            let escapedSentence = "\(escapedCharacter)\(startCharacter)";
            
            if (validValue.characters.count > 1
                && validValue.substringFromIndex(validValue.endIndex.advancedBy(-2)) != escapedSentence
                && validValue.substringFromIndex(validValue.endIndex.advancedBy(-1)) == startCharacter) {
                self.status = .Blocking;
                return true;
            }
            
            //the last character was strip so we continue to find the final character
            self.status = .Continue;
            return true;
        } else {
            validValue.append(character)
        }
        
        
        if (validValue.characters.count == 1 && !validChars.contains(character)) {
            self.status = .Continue;
            return false;
        }
        
        
        if isFinal == true && self.status == .Continue {
            self.status = .Error;
            return false;
        } else {
            return true;
        }
    }
}

//
class TokenizeDelimiter: Tokenize {
    override init() {
        super.init();
        validChars = [";", ","];
        tokenType = TokenType.Delimiter;
    }
    
    override func addState(character: Character, isFinal: Bool = false) -> Bool {
        if (super.addState(character, isFinal: isFinal)) {
            self.status = .Success;
            return true;
        }
        
        if self.status == .Continue {
            self.status = .Blocking;
        } else {
            self.status = .Error;
        }
        
        return false;
    }
}


class TokenizerSpace: Tokenize {
    override init() {
        super.init();
        validChars = [" "];
        tokenType = TokenType.Space;
    }
    
    override func addState(character: Character, isFinal: Bool = false) -> Bool {
        if (super.addState(character, isFinal: isFinal)) {
            self.status = .Success;
            return true;
        }

        if self.status == .Continue {
            self.status = .Success;
        }

        return false;
    }
}



class TokenizerComments: Tokenize {
    override init() {
        super.init();
        validChars = ["/", "*"];
        tokenType = TokenType.Comment;
    }
    
    override func addState(character: Character, isFinal: Bool = false) -> Bool {
        if (super.addState(character, isFinal: isFinal)) {
            //check that the start is ok
            if ((validValue.characters.count == 2) && (validValue != "/*")) {
                self.status = .Continue;
                return false;
            }
            
            if (validValue.characters.count > 2) && (validValue.substringFromIndex(validValue.endIndex.advancedBy(-2)) == "*/") {
                self.status = .Blocking;
                return true;
            }
            
            return true;
        } else {
            validValue.append(character)
        }
        
        if (validValue.characters.count == 2 && validValue != "/*") {
            self.status = .Continue;
            return false;
        }
        
        if isFinal == true && self.status == .Continue {
            self.status = .Continue;
            return false;
        } else {
            return true;
        }
    }
}

/*abc*/
//
class TokenizerOperand: Tokenize {
    override init() {
        super.init();
        validChars = ["+", "-", "/", "*", "=", "(", ")", "{", "}", "<", ">", "[", "]"];
        tokenType = .Operand;
    }

    override func addState(character: Character, isFinal: Bool = false) -> Bool {
        
        if (super.addState(character, isFinal: isFinal)) {
            self.status = .Success;
            return true;
        }
        
        self.status = .Continue;
        return false;
    }
}





