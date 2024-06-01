+++
title = "RailsでCloud Visionのテキスト認識と顔検出"
date = "2021-04-01"
tags = ["rails"]
aliases = ["/posts/cloud-vision-on-rails/"]
+++

[Quickstarts](https://cloud.google.com/vision/docs/quickstarts)を参考にセットアップ後、サービスアカウントの秘密鍵ファイルを適当に設置（`config/xxx.json`）。

```
# Gemfile
gem 'google-cloud-vision'

# config/initializers/cloud_vision.rb
credentials = JSON.parse File.read(Rails.root.join('config', 'xxx.json'))
Google::Cloud::Vision.configure do |config|
  config.credentials = credentials
end
```

viewに `file_field :image` みたいの書いてファイルをアップロードしてみる。

```
# controller
image = File.binread(params[:image].tempfile)

requests = [{
  image: { content: image },
  # image: { source: { image_uri: 'https://example.com/image.png' } },
  image_context: { language_hints: %w(ja) },
  features: [
    { type: :FACE_DETECTION },
    { type: :TEXT_DETECTION }
  ]
}]

result = Google::Cloud::Vision.image_annotator.batch_annotate_images(requests: requests)
```

簡単！`File.binread` を知らなくて、ちょっとはまったけど…
[デモ](https://cloud.google.com/vision/docs/drag-and-drop)でどんな感じか試せるし、レスポンスのJSONも見れて便利だけど、日本語のテキスト検出を試したい場合はローカルで `language_hints` で `ja` を指定して試してみるのおすすめです。精度がちょっと上がりました。

## 参考

- [Try it! | Cloud Vision API](https://cloud.google.com/vision/docs/drag-and-drop)
- [Features list | Cloud Vision API](https://cloud.google.com/vision/docs/features-list)
- [Feature | Cloud Vision API](https://cloud.google.com/vision/docs/reference/rest/v1/Feature#type)
- [Module: Google::Cloud::Vision::V1](https://googleapis.dev/ruby/google-cloud-vision-v1/latest/Google/Cloud/Vision/V1.html)

---

[Amazon Rekognition](https://aws.amazon.com/jp/rekognition/)は日本語のテキスト検出がまだサポートされてなかったので今回見送ったけど、サポートされたら試してみたい。
