;;; package -- Summary:

;;; Commentary:

;;; Code:

;; Major mode configurations

(defvar cypher-mode-font-lock-keywords
  '(("\\<cypher\\>" . font-lock-keyword-face)))

(defvar cypher-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'cypher-send-buffer-or-region)
    (define-key map (kbd "C-c C-r") 'cypher-send-region)
    (define-key map (kbd "C-c C-b") 'cypher-send-buffer)
    ;; (define-key map (kbd "C-c C-i") 'cypher-interactive)
    ;(define-key map [remap beginning-of-defun] 'cypher-beginning-of-statement)
    ;(define-key map [remap end-of-defun] 'cypher-end-of-statement)
    map)
  "Mode map used for `cypher-mode'.")

(defcustom cypher-mode-hook '()
  "Hook for customizing `cypher-mode'."
  :type '(hook)
  :group 'Cypher)


(define-derived-mode cypher-mode prog-mode "Cypher"
  "A major mode to edit Cypher files."
  (font-lock-add-keywords nil cypher-mode-font-lock-keywords)

  ; Make comment-dwim work with cypher-mode
  (setq-local comment-start "//")
  (setq-local comment-end ""))

(add-to-list 'auto-mode-alist '("\\.cypher\\'" . cypher-mode))

;; Variables

(defvar cypher-mode-hook nil "Runs when cypher-mode is loaded.")

(defvar cypher-default-database "neo4j" "The default database.")

(defvar cypher-current-database cypher-default-database "The database that cypher-shell will query against.")

(defvar cypher-username nil "Database username.")

(defvar cypher-password nil "Database password.")

(defvar cypher-neo4j-binary "neo4j" "The Neo4j binary.")

(defvar cypher-shell-binary "cypher-shell" "The cypher-shell binary.")

(defvar cypher-shell-verbose-output t "Configure if cyper-shell output should be verbose or plain.")

;; Functions

(defun cypher-use-database (database-name)
  "Update the targeted database to DATABASE-NAME for the current session."
  (interactive "Database: ")
  (setq cypher-current-database database-name))

(defun cypher-set-username-password (username password)
  "Configure the USERNAME and PASSWORD."
  (interactive
   (list
    (read-string "Username: ")
    (read-string "Password: ")))
  (setq cypher-username username)
  (setq cypher-password password))

(defun cypher-get-cypher-shell-arguments ()
  "Get a formatted string that represents the cypher-shell cmd arguments."
  (format "-d %s -u %s -p %s --format %s"
          cypher-current-database
          (if (not cypher-username) (error (format "Please set %s" 'cypher-username)) cypher-username)
          (if (not cypher-password) (error (format"Please set %s" 'cypher-password)) cypher-password)
          (if cypher-shell-verbose-output "verbose" "plain")))

(defun cypher-send-buffer-or-region (&optional b e)
  (interactive "r")
  (if (use-region-p)
      (cypher-send-region b e)
    (cypher-send-buffer)))

(defun cypher-send-buffer ()
  "Send buffer to cypher-shell and evaluate."
  (interactive)
  (cypher-send (point-min) (point-max)))


(defun cypher-send-region (&optional b e)
  "Send region B to E to cypher-shell and evaluate.
Send buffer is no region is active."
  (interactive "r")
      (cypher-send b e))

(defun cypher-run-neo4j ()
  "Launch Neo4j console in a background process."
  (interactive)
  (start-process "neo4j" "*neo4j-console*" cypher-neo4j-binary "console"))


(defun cypher-send (b e)
  "Send region (beginning B and ending E) to cypher-shell and evaluate."
  (shell-command-on-region
   ;; beginning and end of region
   b
   e
   ;; command and parameters
   (format "%s %s" cypher-shell-binary (cypher-get-cypher-shell-arguments))
   ;; output buffer
   (get-buffer-create "*cypher-shell-output*")
   nil))

(provide 'cypher-mode)
;;; cypher-mode.el ends here
