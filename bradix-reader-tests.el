;; -*- lexical-binding: t; -*-

;;; Code:

(require 'bradix-reader)
(require 'buttercup)

(defun bradix--read (string)
  "Return the value read from the STRING."
  (car (er-read-from-string string)))

(describe "bradix-reader"
  (describe "reading"
    (describe "sanity"
      (it "is read as a number by elisp-reader"
        (expect (type-of (bradix--read "⠼12345⠈")) :to-be 'integer)
        (expect (type-of (bradix--read "⠼12345⠌6789AB")) :to-be 'float)))
    (it "handles arbitrary radices"
      (expect (bradix--read "⠼12345⠌6789AB") :to-equal 24677.553718640153)
      (expect (bradix--read "⠼12345⠐6789ab") :to-equal 74565.4044443965)
      (expect (bradix--read "⠼12345⠈") :to-equal 5349)
      (expect (bradix--read "⠼⠂01010101") :to-equal 0.33203125)
      (expect (bradix--read "⠼-11100⠂01010101") :to-equal -28.33203125))))

(provide 'bradix-reader-tests)
;;; bradix-reader-tests.el ends here
