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
    
    // 入力されているテキストを翻訳して、相手側のテキストにセットする
    func translate(user: VTUser){
        self.state = .translating
        
        var url: URL!
        
        switch user{
        case .first:
            url = URL(string: "\(env.translationApiUrl)/generalNT_\(firstLanguage.localeInAPI)_\(secondLanguage.localeInAPI)/")!
        case .second:
            url = URL(string: "\(env.translationApiUrl)/generalNT_\(secondLanguage.localeInAPI)_\(firstLanguage.localeInAPI)/")!
        }
        
        // 各種パラメーターのセット
        var parameter = OAuthSwift.Parameters()
        parameter["key"] = env.translationApiKey
        parameter["name"] = env.translationApiName
        parameter["type"] = "json"
        parameter["text"] = (user == .first) ? firstText : secondText
        
        let oauthClient = OAuth1Swift(consumerKey: env.translationApiKey,
                                      consumerSecret: env.translationApiSecret)
        oauthClient.client.post(url,
                               parameters: parameter) { (result) in
            switch result{
            case .success(let response):
                do{
                    let parsedResponse = try JSONDecoder().decode(MTResponse.self, from: response.data)
                    let translatedText = parsedResponse.resultSet.result.information.translationText
                    
                    // 翻訳を要求したユーザーと反対側の方に翻訳後のテキストを表示する
                    switch user{
                    case .first:
                        self.secondText = translatedText
                    case .second:
                        self.firstText = translatedText
                    }
                }catch{
                    switch user{
                    case .first:
                        self.firstText = "Failed to translate."
                    case .second:
                        self.secondText = "Failed to translate."
                    }
                    
                    return
                }
                
                break
            case .failure(let error):
                print(error.description)
            }
            
            self.state = .none
        }
    }
    
    func startDictation(user: VTUser){
        if state != .none{
            return
        }

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
            self.translate(user: user)
            
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
        
    }
    
    // 言語の切り替え
    func switchLanguage(user: VTUser){
        switch user{
        case .first:
            if let index = availableLanguages.firstIndex(of: firstLanguage){
                if index.advanced(by: 1) >= availableLanguages.count{
                    firstLanguage = availableLanguages[0]
                }else{
                    firstLanguage = availableLanguages[index.advanced(by: 1)]
                }
            }
        case .second:
            if let index = availableLanguages.firstIndex(of: secondLanguage){
                if index.advanced(by: 1) >= availableLanguages.count{
                    secondLanguage = availableLanguages[0]
                }else{
                    secondLanguage = availableLanguages[index.advanced(by: 1)]
                }
            }
        }
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

extension TranslationLanguage: Equatable{
    public static func == (lhs: TranslationLanguage, rhs: TranslationLanguage) -> Bool{
        return lhs.localeIniOS == rhs.localeIniOS
    }
}


// みんなの翻訳APIのモデル定義
struct MTResponse: Codable{
    var resultSet: MTResultSet
    
    enum CodingKeys: String, CodingKey{
        case resultSet = "resultset"
    }
}

struct MTResultSet: Codable{
    var code: Int
    var message: String
    var request: MTRequest
    var result: MTResult
}

struct MTRequest: Codable{
    var url: String
    var text: String
    var split: Int
    var data: String
}

struct MTResult: Codable{
    var text: String
    var information: MTInformation
}

struct MTInformation: Codable{
    var sourceText: String
    var translationText: String
    
    enum CodingKeys: String, CodingKey{
        case sourceText = "text-s"
        case translationText = "text-t"
    }
}
