;;; bradix-reader.el --- Reader extension for Bradix  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'bradix)
(require 'elisp-reader)

(er-def-syntax ?⠼
               (lambda (in _ch)
                 (bradix-parse (er-read-while in
                                              (lambda (ch)
                                                (not (er-whitespace? ch)))))))

(provide 'bradix-reader)
;;; bradix-reader.el ends here
