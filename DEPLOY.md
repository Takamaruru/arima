# 公開手順（Cloudflare Pages）

このサイトはビルド不要の静的サイトです。GitHub に push すると Cloudflare Pages が自動で公開します。

---

## 1. GitHub に push

```sh
git push origin main
```

## 2. Cloudflare Pages と連携（初回のみ）

1. [dash.cloudflare.com](https://dash.cloudflare.com) にログイン
2. 左メニュー **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
3. GitHub を認証し、リポジトリ `Takamaruru/arima` を選択
4. ビルド設定は **すべて空欄のまま**にします（静的サイトのため）

   | 項目 | 値 |
   | --- | --- |
   | Framework preset | None |
   | Build command | （空欄） |
   | Build output directory | `/` |

5. **Save and Deploy** → 1〜2分で `https://<プロジェクト名>.pages.dev` が発行されます

以降は `git push` するだけで自動的に更新されます。

## 3. 独自ドメインを設定

### 3-1. ドメインを取得

- **.com / .net / .org / .dev など** — Cloudflare の **Domain Registration** → **Register Domain** から直接取得できます（原価販売で更新料が上乗せされないのが利点）。
- **.jp / .co.jp** — Cloudflare では取得できないため、お名前.com・エックスサーバードメイン等で取得し、取得後に Cloudflare へネームサーバーを変更します。

> 取得可能な TLD は変わることがあるので、実際の可否は Cloudflare の管理画面で確認してください。

### 3-2. Pages に紐付け

1. Pages プロジェクト → **Custom domains** → **Set up a custom domain**
2. 取得したドメインを入力（例 `arima-josanin.com`）
3. Cloudflare で取得した場合は DNS が自動設定されます。他社取得の場合は、案内される CNAME を DNS に追加します
4. `www` ありでもアクセスさせたい場合は `www.<ドメイン>` も同じ手順で追加します

### 3-3. サイト内の URL を書き換え

仮ドメイン `arima-josanin.com` がソースに入っているので、実際のドメインに置換します。

```sh
./set-domain.sh 実際のドメイン
git add -A && git commit -m "ドメインを設定" && git push
```

canonical / OGP / 構造化データ / sitemap.xml / robots.txt がまとめて書き換わります。

---

## 4. 公開後にやること（SEO）

### Google Search Console

1. [search.google.com/search-console](https://search.google.com/search-console) でプロパティを追加
2. 所有権確認（Cloudflare で DNS を管理していれば DNS 認証が簡単です）
3. **サイトマップ** に `sitemap.xml` を送信
4. **URL 検査** → **インデックス登録をリクエスト** でトップページの登録を促す

### Google ビジネスプロフィール（最重要）

「野々市 助産院」「野々市 産後ケア」のような検索では、通常のサイトより **Google マップの枠が上に出ます**。ここに載らないと集客の機会をかなり損ないます。

- [business.google.com](https://business.google.com) で登録（無料）
- ハガキ等での住所確認が必要なため、**公開と同時に申請しておく**のがおすすめです
- サイトに載せた情報（院名・住所・電話番号・営業時間）と **完全に一致させる** ことが重要です

### 表示速度の確認

[PageSpeed Insights](https://pagespeed.web.dev/) に公開後の URL を入れて確認します。

---

## ローカルでの確認方法

```sh
python3 -m http.server 8000
```

ブラウザで `http://localhost:8000` を開きます。
（`file://` で直接開くと `/favicon-32.png` などルート基準のパスが読めません）

---

## お知らせを更新する

トップページの「お知らせ」は `news.json` だけで管理しています。HTMLは触りません。

### 書き方

```json
[
  {
    "date": "2026-08-21",
    "title": "夏季休院のお知らせ",
    "body": "8月13日(木)〜16日(日)は休院いたします。"
  }
]
```

| 項目 | 必須 | 内容 |
| --- | --- | --- |
| `date` | 任意 | `2026-08-21` の形式。サイトでは `2026.08.21` と表示されます |
| `title` | 必須 | 見出し |
| `body` | 任意 | 本文。`\n` と書くと改行されます |

- 新しい順に自動で並び替わるので、書く順番は気にしなくて大丈夫です
- 表示されるのは **新しい5件まで**（古いものは残しておいても表示されません）
- 中身が `[]`（空）のときは、お知らせセクションごと表示されません

複数件を書くときは `{ }` のかたまりを `,` でつなぎます。**最後のかたまりの後ろにはカンマを付けません。**

```json
[
  { "date": "2026-09-01", "title": "9月の教室のご案内" },
  { "date": "2026-08-21", "title": "夏季休院のお知らせ" }
]
```

### 更新のしかた（ブラウザだけで完結）

1. [github.com/Takamaruru/arima](https://github.com/Takamaruru/arima) を開く
2. `news.json` をクリック
3. 右上の鉛筆マーク（Edit this file）をクリック
4. 内容を書き換える
5. 下の **Commit changes** をクリック
6. 1〜2分待つと本番サイトに反映されます

### うまく表示されないとき

カンマや引用符（`"`）の付け忘れがあると、お知らせが表示されなくなります（ページの他の部分は正常に表示されます）。

書式が正しいかは [jsonlint.com](https://jsonlint.com/) に貼り付けると確認できます。ブラウザの開発者ツールのコンソールにも原因が出ます。
