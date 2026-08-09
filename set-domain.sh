#!/bin/sh
# 独自ドメインが決まったら、このスクリプトでサイト内のURLを一括置換します。
#
#   ./set-domain.sh arima-josanin.jp
#
# 置換対象: canonical / OGP / 構造化データ / sitemap.xml / robots.txt

set -eu

NEW_DOMAIN="${1:-}"
OLD_DOMAIN="arima-josanin.com"

if [ -z "$NEW_DOMAIN" ]; then
  echo "使い方: ./set-domain.sh <新しいドメイン>   例) ./set-domain.sh arima-josanin.jp" >&2
  exit 1
fi

# http:// や https:// 、末尾スラッシュが付いていても受け付ける
NEW_DOMAIN=$(printf '%s' "$NEW_DOMAIN" | sed -e 's#^https\{0,1\}://##' -e 's#/$##')

cd "$(dirname "$0")"

FILES="index.html reservation.html sitemap.xml robots.txt"
for f in $FILES; do
  [ -f "$f" ] || continue
  perl -pi -e "s/\Q$OLD_DOMAIN\E/$NEW_DOMAIN/g" "$f"
done

echo "ドメインを $OLD_DOMAIN → $NEW_DOMAIN に置換しました。"
echo
echo "残り: このスクリプト内の OLD_DOMAIN も新しいドメインに書き換えておくと、"
echo "      次回ドメインを変更するときも同じ手順で使えます。"
grep -h -o "https://$NEW_DOMAIN[^\"< ]*" $FILES | sort -u
