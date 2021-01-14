//
//  TranslateAPIController.swift
//  VoiceTranslationApp
//
//  Created by Kentaro Abe on 2021/01/14.
//

import Foundation
import OAuthSwift
import AVFoundation
import Speech

class TranslateAPIController: NSObject, ObservableObject, SFSpeechRecognizerDelegate{
    let env = Env()
    var availableLanguages = [TranslationLanguage]()
    
    @Published var firstLanguage: TranslationLanguage!
    @Published var firstButtonText = "Start"
    @Published var firstText = "(please speak after press 'Start' Button)"
    
    @Published var secondLanguage: TranslationLanguage!
    @Published var secondButtonText = "Start"
    @Published var secondText = "(please speak after press 'Start' Button)"
    
    var state = VTState.none
    
    // 音声認識関係
    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer!
    private var recognizerRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    
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
    
    func startDictation(user: VTUser){
        state = .listning
        
        var locale: Locale!
        switch user{
        case .first:
            locale = Locale(identifier: firstLanguage.localeIniOS)
            firstButtonText = "End"
        case .second:
            locale = Locale(identifier: secondLanguage.localeIniOS)
            secondButtonText = "End"
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            return
        }
        
        recognizer = SFSpeechRecognizer(locale: locale)
        recognizer?.delegate = self
        recognizerRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // 発話終了を待たずにリアルタイムの結果を受け取るための設定
        recognizerRequest.shouldReportPartialResults = true
        
        self.recognitionTask = recognizer?.recognitionTask(with: recognizerRequest, resultHandler: { (recognitionResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let recognitionResult = recognitionResult else{
                return
            }
            
            switch user{
            case .first:
                self.firstText = recognitionResult.bestTranscription.formattedString
            case .second:
                self.secondText = recognitionResult.bestTranscription.formattedString
            }
            
            if !recognitionResult.isFinal{
                return
            }
            
            // この先で実際の翻訳処理が走る
            print(recognitionResult.bestTranscription.formattedString)
            
            // Audioの使用終了
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioEngine.stop()
        })
        
        guard let _ = self.recognitionTask else{
            fatalError()
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            self.recognizerRequest.append(buffer)
        }
        
        self.audioEngine.prepare()
        try? self.audioEngine.start()
    }
    
    func endDictation(){
        self.recognitionTask.finish()

        firstButtonText = "Start"
        secondButtonText = "Start"
        
        state = .none
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
