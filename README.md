depletion prediction for Mackerel
===

Mackerelで管理しているサーバーのディスクの枯渇予測をします。
リファクタリング時に気付いたんですが，公式に似たような機能が追加されてた…。
https://mackerel.io/ja/blog/entry/weekly/20160729

起動方法
---
```bash
$ carton install
$ carton exec -- plackup -I lib app.psgi
```
