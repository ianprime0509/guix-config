(define-module (local packages i3blocks)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages haskell))

(define-public i3blocks
  (let ((revision "1")
        (commit "28c2b092f7d41aa723dad18b0484dca0da1cbbf5"))
    (package
      (name "i3blocks")
      (version (string-append "1.4-" revision "." (string-take commit 7)))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/vivien/i3blocks.git")
                      (commit commit)))
                (file-name (string-append name "-" version "-checkout"))
                (sha256
                 (base32
                  "0xc7wiz6kk7208l1zsnz35qm5vaywr0af16amin746cxvbs5lnr5"))))
      (build-system gnu-build-system)
      (arguments
       '(#:make-flags (list "CC=gcc" (string-append "PREFIX=" %output))
         #:phases (modify-phases %standard-phases
                    ;; The only scripts are the pre-installed block
                    ;; scripts, which shouldn't be patched
                    (delete 'patch-source-shebangs)
                    (delete 'configure))
         #:tests? #f))
      (native-inputs `(("pandoc" ,ghc-pandoc)))
      (synopsis "Status line for the i3 window manager")
      (description "i3blocks is a status line for i3bar, one component of the
i3 window manager.  It allows for user customization in the form of ``blocks'',
where the content of each block is given by a user-defined command.  Blocks can
be updated independently at particular intervals, or upon reception of a signal
or on a mouse click event.  It aims to respect the i3bar protocol, providing
customization such as text alignment, urgency, color and more.")
      (home-page "https://github.com/vivien/i3blocks")
      (license license:gpl3+))))
