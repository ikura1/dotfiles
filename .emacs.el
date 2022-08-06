;;新設されたインデントを無効にしてみる
(electric-indent-mode -1)

;; 補完で大文字小文字無視
(setq read-file-name-completion-ignore-case t)

;; bufferの先頭でカーソルを戻そうとしても音をならなくする
(defun previous-line (arg)
  (interactive "p")
  (condition-case nil
      (line-move (- arg))
    (beginning-of-buffer)))

;; ファイル末の改行がなければ追加
(setq require-final-newline t)

;;tabは4文字分、改行後に自動インデント
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;====================================
;;ショートカット
;====================================
;正規表現検索をC-Sに設定してみる
;global-set-key "\C-S" 'isearch-forward-regexp)

;c-mで自動インデント
;; (global-set-key (kdb "C-m") 'newline-and-indent)

;;; キーバインド
(define-key global-map (kbd "C-h") 'delete-backward-char) ;削除
(define-key global-map (kbd "C-/") 'advertised-undo) ;UNDO

;; 指定行にジャンプする
;; (define-key global-map (kdb "C-xj") 'goto-line)

;====================================
;;見た目の設定
;====================================
;; オープニングメッセージを表示しない
(setq inhibit-startup-message t)

;; scroll-bar-mode "right" or "left" or "nil"
;;(set-scroll-bar-mode 'nil)

;; ウインドウ分割時に画面外へ出る文章を折り返す
(setq truncate-partial-width-windows nil)

;; 編集行のハイライト
(global-hl-line-mode)

;; 対応する括弧を光らせる。
(show-paren-mode 1)

;;; ツールバー(add-to-list 'default-frame-alist '(alpha . 0))を非表示
;; M-x tool-bar-mode で表示非表示を切り替えられる
(tool-bar-mode -1)

;;; メニューバーを非表示
;; M-x menu-bar-mode で表示非表示を切り替えられる
(menu-bar-mode -1)

;; set alpha
(add-to-list 'default-frame-alist '(alpha . (76 )))
;; emacs24? alpha
;;(set-frame-parameter nil 'alpha 25)

;; カレントウィンドウの透明度を変更する (85%)
;; (set-frame-parameter nil 'alpha 0.85)
;; (set-frame-parameter nil 'alpha 65)

;; 透明度の下限 (15%)
(setq frame-alpha-lower-limit 15)

;; set font and screen
(progn
  ;; 文字の色を設定します。
  (add-to-list 'default-frame-alist '(foreground-color . "azure1"))
  ;; 背景色を設定します。
  (add-to-list 'default-frame-alist '(background-color . "black"))
  ;; カーソルの色を設定します。
  (add-to-list 'default-frame-alist '(cursor-color . "green"))
  ;; マウスポインタの色を設定します。
  (add-to-list 'default-frame-alist '(mouse-color . "green"))
  ;; モードラインの文字の色を設定します。
  (set-face-foreground 'mode-line "white")
  ;; モードラインの背景色を設定します。
  (set-face-background 'mode-line "DimGrey")
  ;; 選択中のリージョンの色を設定します。
  (set-face-background 'region "Blue")
  ;; モードライン（アクティブでないバッファ）の文字色を設定します。
  (set-face-foreground 'mode-line-inactive "gray30")
  ;; モードライン（アクティブでないバッファ）の背景色を設定します。
  (set-face-background 'mode-line-inactive "gray85")
)


;====================================
;;全角スペースとかに色を付ける
;====================================
(defface my-face-b-1 '((t (:background "SeaGreen"))) nil)
(defface my-face-b-1 '((t (:background "SeaGreen"))) nil)
(defface my-face-b-2 '((t (:background "SeaGreen"))) nil)
(defface my-face-b-2 '((t (:background "SeaGreen"))) nil)
(defface my-face-u-1 '((t (:foreground "SeaGreen" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
(font-lock-add-keywords
  major-mode
  '(
    ("　" 0 my-face-b-1 append)
    ("\t" 0 my-face-b-2 append)
    ("[ ]+$" 0 my-face-u-1 append)
    )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
                              (if font-lock-mode
                                  nil
                                (font-lock-mode t))))
