+++
title = "Appleでサインインのアクセストークンとリフレッシュトークンの取得"
date = "2020-02-19"
tags = ["ios", "ruby"]
aliases = ["/posts/sign-in-with-apple-tokens/"]
+++

[Appleでサインインのトークン検証](/posts/2020-02-12/)の続き。

#### セットアップ

```
# Gemfile
gem "jwt"

# クライアントから送られてきたパラメータ
code = "authorizationCode"

# アプリのID（decoded_token[:aud]）
client_id = "com.example.app"

# https://developer.apple.com/account/#/membership
team_id = "xxx"

# https://developer.apple.com/account/resources/authkeys/list
key_id = "xxx"
key_file = File.read(Rails.root.join("AuthKey_xxx.p8"))
key = OpenSSL::PKey::EC.new(key_file)
```

#### `access_token/refresh_token` の取得

```
headers = {
  kid: key_id,
  alg: "ES256"
}
claims = {
  iss: team_id,
  sub: client_id,
  iat: Time.now.to_i,
  exp: Time.now.to_i + 1.day.to_i * 180,
  aud: "https://appleid.apple.com"
}
client_secret = JWT.encode claims, key, "ES256", headers
params = {
  client_id: client_id,
  client_secret: client_secret,
  code: code,
  grant_type: "authorization_code"
}
response = Net::HTTP.post_form(URI.parse("https://appleid.apple.com/auth/token"), params)
json = JSON.parse(response.body, symbolize_names: true)
#=> {:access_token=>"xxx", :token_type=>"Bearer", :expires_in=>3600, :refresh_token=>"xxx", :id_token=>"xxx"}
```

#### `refresh_token` を利用して `access_token` を取得

```
params = {
  client_id: client_id,
  client_secret: client_secret,
  refresh_token: json[:refresh_token],
  grant_type: "refresh_token"
}
response = Net::HTTP.post_form(URI.parse("https://appleid.apple.com/auth/token"), params)
json = JSON.parse(response.body, symbolize_names: true)
#=> {:access_token=>"xxx", :token_type=>"Bearer", :expires_in=>3600}
```

#### リンク

- [Generate and validate tokens - Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi/generate_and_validate_tokens)
- [TokenResponse - Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi/tokenresponse)
- [ErrorResponse - Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi/errorresponse)
