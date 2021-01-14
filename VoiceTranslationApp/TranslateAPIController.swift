//
//  TranslateAPIController.swift
//  VoiceTranslationApp
//
//  Created by Kentaro Abe on 2021/01/14.
//

import Foundation
import OAuthSwift

class TranslateAPIController: NSObject, ObservableObject{
    let env = Env()
    var availableLanguages = [TranslationLanguage]()
    
    @Published var firstLanguage: TranslationLanguage!
    @Published var firstButtonText = "Start"
    @Published var firstText = "(please speak after press 'Start' Button)"
    
    @Published var secondLanguage: TranslationLanguage!
    @Published var secondButtonText = "Start"
    @Published var secondText = "(please speak after press 'Start' Button)"
    
    override init(){
        
        // JSON Fileが入っていなかったり、不正な形式の場合はFatalError
        guard let languageJsonFilePath = Bundle.main.path(forResource: "TranslationLanguage", ofType: "json") else{
            fatalError("YOU HAVE TO INCLUDE TranslationLanguage.json")
        }
        
        let languageJsonFileString = try! String(contentsOfFile: languageJsonFilePath)
        
        do{
            self.availableLanguages = try JSONDecoder().decode([TranslationLanguage].self, from: languageJsonFileString.data(using: .utf8)!)
        }catch{
            fatalError("INVALID JSON FILE")
        }
        
        self.firstLanguage = availableLanguages[0]
        self.secondLanguage = availableLanguages[1]
    }
    
}

enum VTState{
    case listning
    case translating
    case none
}

enum VTUser{
    case first
    case second
}

struct TranslationLanguage: Codable{
    var displayLanguage: String
    var localeIniOS: String
    var localeInAPI: String
}
