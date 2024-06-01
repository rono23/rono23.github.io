+++
title = "TestFlightのテスト内容の必須文字数が変更"
date = "2019-07-22"
tags = ["ios"]
aliases = ["/posts//testflight-whats-new-error/"]
+++

> Spaceship::UnexpectedResponse: [!] An attribute value has text that is too short. - Text for whatsNew is too short.

Bitrise上で少し前からエラーが発生するようになって調べてみたら、TestFlightのテスト内容の必須文字数が変更になったっぽい 🤔

> テスト内容は4文字以上でなければなりません。

`App Store Connect` > `TestFlight` > アプリ選択 > `テストの詳細` で `テスト内容` を9文字以下で保存するとエラー（5文字以上でも同じエラーメッセージ…）。

```
# Fastlane
- pilot(changelog: "9文字以下", ...)
+ pilot(changelog: "10文字以上のテキスト", ...)
```

10文字以上に変更したら 🙆🎉

---

最近、月1でBitrise or Fastlaneで躓いてる気がする… 😭
