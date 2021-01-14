# VoiceTranslationApp
- NICTが提供する、「みんなの翻訳@TexTra」のAPIを用いた対話型通訳アプリです。
  - 「みんなの翻訳@TexTra」の詳細については[こちら](https://mt-auto-minhon-mlt.ucri.jgn-x.jp/)を参照してください。
- SwiftUIで作成しており、OAuthで認証を行うため、[OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)を使用しています。
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
