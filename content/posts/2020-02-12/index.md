+++
title = "Appleでサインインのトークン検証"
date = "2020-02-12"
tags = ["ios", "ruby"]
aliases = ["/posts/verify-sign-in-with-apple-token/"]
+++

#### セットアップ

```
# Gemfile
gem "jwt"

# クライアントから送られてきたパラメータ
token = "identityToken"
code = "authorizationCode"
```

#### 署名検証

```
url = "https://appleid.apple.com/auth/keys"
jwks = JSON.parse(open(url).read, symbolize_names: true)
algorithms = jwks[:keys].map { |key| key[:alg] } # or tokenのHeaderの:alg
decoded_token = JWT.decode(token, nil, true, algorithms: algorithms, jwks: jwks).first.with_indifferent_access

# 1つのJWKだけ検証したいとき
jwk = jwks[:keys].first
public_key = JWT::JWK.import(jwk).keypair.public_key # or `JWT::JWK::RSA.import(jwk).public_key`
JWT.decode(token, public_key, true, algorithm: "RS256")

# 期限は10分なので注意
JWT.decode(...) #=> JWT::ExpiredSignature: Signature has expired
```

#### authorizationCodeの検証

```
# https://openid.net/specs/openid-connect-core-1_0.html#CodeValidation
digest = Digest::SHA256.digest(code)
c_hash = Base64.urlsafe_encode64(digest[0, digest.size/2], padding: false)
decoded_token[:c_hash] == c_hash
```

#### nonceの検証

クライアントの実装は[firebase/quickstart-ios](https://github.com/firebase/quickstart-ios/blob/112bdec24e30b333a14ca72b5976afe3d765e1b1/authentication/AuthenticationExampleSwift/MainViewController.swift#L816)が参考になるかも。
iOS 13から[CryptoKit](https://developer.apple.com/documentation/cryptokit)が導入されたので、quickstart-ios的なnonceの生成は以下みたいな感じでもOKかな 🤔

```
# クライアント
import CryptoKit

let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil))!
let rawNonce = NSString(string: uuid).replacingOccurrences(of: "-", with: "")
let data = rawNonce.data(using: .utf8)!
request.nonce = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()

# サーバー
decoded_token[:nonce] == Digest::SHA256.hexdigest(rawNonce)
```

iOS 12以下をサポートしている場合、[weak link](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WeakLinking.html#//apple_ref/doc/uid/20002378-107026
)する必要があるので忘れずに。

> Targets > APP > Build Settings > Other Linker Flags に `-weak_framework CryptoKit` を追加

#### リンク

- [JSON Web Token (JWT)](https://openid-foundation-japan.github.io/draft-ietf-oauth-json-web-token-11.ja.html)
- [JSON Web Signature (JWS)](https://openid-foundation-japan.github.io/draft-ietf-jose-json-web-signature-14.ja.html#kidDef)
- [JSON Web Key (JWK)](https://openid-foundation-japan.github.io/rfc7517.ja.html#kidDef)
- [jwt/ruby-jwt](https://github.com/jwt/ruby-jwt)
- [Sign in with Apple REST API | Apple Developer Documentation](https://developer.apple.com/documentation/signinwithapplerestapi)

---

➡️ [Appleでサインインのアクセストークンとリフレッシュトークンの取得](/posts/sign-in-with-apple-tokens)に続く
