+++
title = "PKCEのcode_challenge生成"
date = "2021-01-15"
tags = ["ios", "ruby"]
aliases = ["/posts/pkec-code-challenge/"]
+++

> code_verifier=dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
> code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
https://tools.ietf.org/html/rfc7636

Swift

```
import CryptoKit

let codeVerifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
let data = Data(codeVerifier.utf8)
let hash = SHA256.hash(data: data)
let codeChallenge = Data(hash).base64EncodedString()
    .replacingOccurrences(of: "=", with: "")
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
```

Ruby

```
require 'base64'
require 'digest'

code_verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
code_challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false)
```

---

最初、[ハッシュ値を文字列](https://www.hackingwithswift.com/example-code/cryptokit/how-to-calculate-the-sha-hash-of-a-string-or-data-instance)で扱って少しハマったけど `CommonCrypto` を使わずにできてよかった 🎉
