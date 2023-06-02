;;; bradix.el --- Braille-radix numbers  -*- lexical-binding: t; -*-

;; Author: Greg Pfeil <greg@technomadic.org>
;; Keywords: lisp
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/sellout/emacs-bradix
;; Version: 0.1.0

;;; Commentary:

;; More consistent, less biased numeric notation.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defun bradix--interpret-braille (character)
  "Determine the base to use from the braille CHARACTER provided.
Return nil if the provided character isn’t braille, otherwise a value in the
range 0–255."
  (when (<= ?⠀ character ?⣿)
    (- character ?⠀)))

(defun bradix--is-digit-separator (char)
  "Return non-nil if the provided CHAR is a valid digit separator."
  (or (eq char ?,)
      (eq (get-char-code-property char 'general-category) 'Zs)))

(defun bradix-radix (string)
  "Return the radix of the bradix-formatted STRING.
This does not validate the string, it simply looks for the first braille code
point and determines its value. It also returns the position of the radix point
as a second value."
  (when-let ((radix-point-pos (cl-position-if #'bradix--interpret-braille
                                              string)))
    (cl-values (bradix--interpret-braille (elt string radix-point-pos))
               radix-point-pos)))

;; TODO: Use https://github.com/mishoo/elisp-reader.el to create an (optional)
;;       reader extension to read these numbers
(defun bradix-parse (string)
  "Convert a STRING in bradix format to a number.
Bradix format uses Unicode braille code points as the radix point. It’s
interpreted in binary to determine the base. E.g., ⠌ = base 12 (in base 10).
A single arbitrary space character (although THIN SPACE is recommended) or comma
may be placed between each digit as a separator, but all of the separators must
use the same character. There can be a leading + or - (which also requires at
least one digit before the radix point, and for bases >10, A–Z are allowed,
case-insensitively. There can be an exponent, represented in the same base."
  (let ((num-string (cl-remove-if #'bradix--is-digit-separator string)))
    (cl-multiple-value-bind (radix radix-point-pos) (bradix-radix num-string)
      (let ((integral (substring num-string 0 radix-point-pos))
            (fractional (substring num-string (1+ radix-point-pos))))
        ;; TODO: Validate numerals & separators
        (cl-case radix
          ;; the only valid “nullary” number is 0, and there are no nullary
          ;; digits, so the string must be only “⠀” and separators.
          (0 (if (and (string-empty-p integral) (string-empty-p fractional))
                 0
               (error "Invalid nullary number")))
          ;; there currently are fractional unary numbers, but they are unusual
          ;; in that only values 1/(1+ (length n)) are representable
          (1 (let ((int (length integral)))
               (if (string-empty-p fractional)
                   int
                 (funcall (if (< int 0) #'- #'+)
                          int
                          (/ 1 (float (1+ (length fractional))))))))
          (t (if (<= radix 16)
                 (let ((int (string-to-number integral radix)))
                   (if (string-empty-p fractional)
                       int
                     (funcall (if (< int 0) #'- #'+)
                              int
                              (/ (float (string-to-number fractional radix))
                                 (expt radix (length fractional))))))
               (error "Only supports up to hexidecimal for now"))))))))

(provide 'bradix)
;;; bradix.el ends here
