# 虎碼輸入方案

本方案爲採用**繁體簡碼**的**虎碼**輸入方案，方案設計來自[rime-xuma][rime-xuma]，碼表來自[虎碼官方版][huma-space]。

## 使用介紹

- 字集選擇（輸入時按 `Ctrl + O` 切換）：
  
  - 常用： 常用繁體 + 部分異體字（例：爲(為)、衆(眾)等字）+ 部分日本漢字，共計9600多個。
  
  - 全集： 不過濾字集

- 三重註解： 支持 *拆分* + *編碼* + *拼音* 提示。`Ctrl + C` 關閉註解，`Ctrl + Shift + C` 可以切換註解顯示等級。詳情參攷 [rime-xuma][rime-xuma] 。

   想要正確顯示拆分的字根，需要安裝對應的字體。下載安裝[字體下載][huma-space] 中的虎码方案必装字体。其中，`TumanPUA.ttf` 爲字根字體，`TH-Tshyn-P*` 支持超集字的顯示。

- 反查： ``` ` ```（反引號）反查，``` `P ```拼音反查，``` `B ``` 五筆畫反查。

- 繁入簡出： 輸入繁體編碼，輸出簡化字（規範字），全局快捷鍵 `Ctrl + Shift + Space` 。

- 全碼後置： 簡碼單字排序靠前，全碼重碼時降低排序，讓位於無簡碼字詞。默認開啓。

- 手動造詞： 使用`'`（單引號）引導，每個字以`'`（單引號）分隔。如：``` 'xx'xx'xx ```

- 選重： `；`（分號）次選，`'`（引號）三選。

- 單字模式：方案默認啟用了詞組，但也可通過 `詞組派 → 單字派` 選項進行切換。

- 標點：方案在一簡的三選位置上設置了快捷的標點符號，方便手機輸入，但需要手動在 Rime 中選擇 `漢字 → 外文`，使 `外文` 處於激活狀態。

- 符號： 可以使用 `/` 引導符號，比如，`/sx` 的候選有 `1. ± 2. ÷ 3. × 4. ∈ 5. ∏` 。
  
## 使用方案

複製目錄下所有文件到用戶文件夾，啓用方案（編輯用戶文件或在圖形界面勾選）後重新部署。

**註：如果你已有`rime.lua`文件，不要直接替換，而是把本方案的`rime.lua`文件的內容追加到你的`rime.lua`中。**

**註： 確保你已經有朙月拼音和五筆劃方案，否則不能部署成功。**

## Tips

1. 關閉四碼唯一時自動上屏

   **以下代碼在開頭都標註了文件名，若不存在，需手動創建，下同。**

   ```yaml
   # huma_trad.custom.yaml
   patch:
      speller/auto_select: false
   ```

2. 關閉四碼空碼時下一碼清屏

   ```yaml
   # huma_trad.custom.yaml
   patch: 
      speller/auto_clear: none # 可選有：manual（手動空格清屏），auto（空碼自動清屏），max_length（四碼時空碼頂字清屏，默認）
   ```

3. 開啓逐字提示（不完全匹配）

   ```yaml
   # huma_trad.custom.yaml
   patch: 
      translator/enable_completion: true 
   ```

4. 關閉造詞時逐字提示

   ```yaml
   # huma_trad.custom.yaml
   patch: 
      encode_sentence/enable_completion: false
   ```

## Q&A

1. Q： 爲什麼部署不成功？

   A： 確保你已經有朙月拼音和五筆劃方案，部分發行版（例如同文輸入法）並不內置，需要手動下載。 [朙月拼音](https://github.com/rime/rime-luna-pinyin) [五筆畫](https://github.com/rime/rime-stroke)

2. Q： 爲什麼部分功能無法使用（如字集過濾）？

   A： 確保你的發行版支持lua插件。

3. Q： 如何刪除用戶自造詞？

   A:  
      > 删除特定用户词：输入该词编码，移动光标选中该词，敲删词键 Ctrl + Delete 或 Shift + Delete （Mac OS 用 Shift + Fn + Delete），默认还绑定了 Ctrl + K。删除整个用户词典：先退出输入法程序或算法服务， 然后删除用户目录下的 huma_trad.userdb 目录，再启动输入法。

4. Q:  與官方碼表不同之處

   A:
      - **部分部件採用了「T」源字形，故其編碼與官方碼表不同。詳見: [#5](https://github.com/ywxt/rime-huma/issues/5)**
  
      - **添加了少量字根以解決部分字的重碼問題。詳見：[#8](https://github.com/ywxt/rime-huma/issues/8)**

      - 去除了容錯碼、回頭碼和音補。

         理由是官方碼表中的回頭碼是爲其自定義字集設計的，如果本方案添加回頭碼，就須要爲繁體字特別優化。容錯碼和音補則只有個別幾組字，爲其添加特碼有些不划算。

         暫時精力有限，以後可能會攷慮做。

      - 所有的特碼都在 `huma_trad.dict.yaml` 中定義，`huma.char.dict.yaml` 中全部恢復爲正常的編碼。
5. Q:  爲什麼某些字根字不在首選位置（如 `zh` 是 `其` 而非 `虎`）？

   A：
      第一種情況：由於字根編碼的位置被高頻字所佔用，這種情況可重複字根的小碼。比如，輸入 `zh` 時，`虎` 在三選上，而 `zhh`(`h` 爲 `虎` 的小碼)時，`虎` 會出現在首選位置。

      第二種情況：字根字非常罕用，故其位置設置爲其他常用字簡碼。如 `虍`、`兎` 等字。

[rime-xuma]: https://github.com/Ace-Who/rime-xuma
[huma-space]: http://huma.ysepan.com/
