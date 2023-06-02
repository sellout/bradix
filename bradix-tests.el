;; -*- lexical-binding: t; -*-

;;; Code:

(require 'bradix)
(require 'buttercup)

(describe "bradix"
  (describe "radix identification"
    (it "identifies them in isolation"
      (expect (bradix-radix "⠀") :to-equal '(0 0))
      (expect (bradix-radix "⠁") :to-equal '(1 0))
      (expect (bradix-radix "⠂") :to-equal '(2 0))
      (expect (bradix-radix "⠈") :to-equal '(8 0))
      (expect (bradix-radix "⠊") :to-equal '(10 0))
      (expect (bradix-radix "⠌") :to-equal '(12 0))
      (expect (bradix-radix "⠐") :to-equal '(16 0))
      (expect (bradix-radix "⣿") :to-equal '(255 0)))
    (it "ignores non-braille characters"
      (expect (bradix-radix "⟿") :to-be nil)
      (expect (bradix-radix "⤀") :to-be nil))
    (it "handles them in numbers"
      (expect (bradix-radix "12 345⠌678 9AB") :to-equal '(12 6))
      (expect (bradix-radix "12,345⠐678,9ab") :to-equal '(16 6))
      (expect (bradix-radix "12,345⠈") :to-equal '(8 6))
      (expect (bradix-radix "⠂0101 0101") :to-equal '(2 0))
      (expect (bradix-radix "-1 1100⠂0101 0101") :to-equal '(2 7))))
  (describe "parsing"
    (it "handles arbitrary radices"
      (expect (bradix-parse "12 345⠌678 9AB") :to-equal 24677.553718640153))
    (it "handles separators"
      (expect (bradix-parse "12,345⠐678,9ab") :to-equal 74565.4044443965)
      (expect (bradix-parse "12,345⠈") :to-equal 5349))
    (it "handles empty integer components"
      (expect (bradix-parse "⠂0101 0101") :to-equal 0.33203125))
    (it "handles signedness indicators"
      (expect (bradix-parse "-1 1100⠂0101 0101") :to-equal -28.33203125))))

(provide 'bradix-tests)
;;; bradix-tests.el ends here
