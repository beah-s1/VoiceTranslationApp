# VoiceTranslationApp
- NICTが提供する、「みんなの翻訳@TexTra」のAPIを用いた対話型通訳アプリです。
  - 「みんなの翻訳@TexTra」の詳細については[こちら](https://mt-auto-minhon-mlt.ucri.jgn-x.jp/)を参照してください。
- SwiftUIで作成しており、OAuthで認証を行うため、[OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)を使用しています。

![IMG_0898](https://user-images.githubusercontent.com/30878285/104659190-8c969b00-5707-11eb-89dc-85e7089ec677.PNG)


## Installation
- `ContentView.swift`などと同じ階層に、`Env.swift`を以下の内容で作成します

```Swift
struct Env{
    let translationApiUrl = "https://mt-auto-minhon-mlt.ucri.jgn-x.jp/api/mt"
    let translationApiKey = "" 
    let translationApiSecret = ""
    let translationApiName = ""   //ログインに使用するユーザー名
}
```

- APIキー・シークレットなどは、 [こちら](https://mt-auto-minhon-mlt.ucri.jgn-x.jp/content/setting/user/edit/)から自身のものを取得・使用してください

## Instructions
- iPhoneやiPadなどで起動し、端末を挟んで二人で向かい合って使用します。
- 自身の手元の方の「Start」をタップすると、聞き取りを開始し、「End」をタップすると、相手側に訳文が表示されます。
- 「Language:〜〜」をタップすると、自身の言語を切替できます。

- 言語は以下をサポートしています。
  - 日本語
  - 英語(English)
  - 韓国語(한국어)
  - 中国語(簡体)(简体字)
