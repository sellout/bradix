;; -*- lexical-binding: t; -*-

;;; Code:

(require 'bradix-reader)
(require 'buttercup)

(describe "bradix-reader"
  (describe "reading"
    (it "handles arbitrary radices"
      (expect ⠼12345⠌6789AB :to-equal 24677.553718640153)
      (expect ⠼12345⠐6789ab :to-equal 74565.4044443965)
      (expect ⠼12345⠈ :to-equal 5349)
      (expect ⠼⠂01010101 :to-equal 0.33203125)
      (expect ⠼-11100⠂01010101 :to-equal -28.33203125))))

(provide 'bradix-reader-tests)
;;; bradix-reader-tests.el ends here
