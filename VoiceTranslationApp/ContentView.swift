//
//  ContentView.swift
//  VoiceTranslationApp
//
//  Created by Kentaro Abe on 2021/01/14.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var controller = TranslateAPIController()
    
    var body: some View {
        GeometryReader{ v in
            VStack{
                // 相手側翻訳用
                VStack{
                    Text(controller.secondText)
                        .padding()
                        .lineLimit(nil)
                    Button("Language: \(controller.secondLanguage.displayLanguage)"){
                        print("user1")
                    }
                    Button(controller.secondButtonText) {
                        switch controller.state{
                        case .none:
                            controller.startDictation(user: .second)
                        default:
                            controller.endDictation()
                        }
                    }
                    .padding()
                }
                .rotationEffect(.init(degrees: 180.0))
                .edgesIgnoringSafeArea(.all)
                .frame(width: v.size.width, height: (v.size.height - 10)/2, alignment: .center)
                
                // 自分側翻訳用
                VStack{
                    Text(controller.firstText)
                        .padding()
                        .lineLimit(nil)
                    Button("Language:\(controller.firstLanguage.displayLanguage)") {
                            print("user1")
                        }
                    Button(controller.firstButtonText) {
                        switch controller.state{
                        case .none:
                            controller.startDictation(user: .first)
                        default:
                            controller.endDictation()
                        }
                    }
                    .padding()
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: v.size.width, height: v.size.height/2, alignment: .center)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
