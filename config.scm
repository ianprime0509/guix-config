;; This is an operating system configuration template
;; for a "desktop" setup without full-blown desktop
;; environments.

(use-modules (gnu) (gnu system nss))
(use-service-modules desktop xorg)
(use-package-modules bootloaders certs linux pulseaudio suckless wm xorg)

(define my-xorg-conf
  (xorg-configuration-file
   #:modules (cons* xf86-input-libinput %default-xorg-modules)
   #:extra-config '("Section \"InputClass\"
    Identifier \"AlpsPS/2 ALPS DualPoint TouchPad\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"AccelSpeed\" \"0.7\"
EndSection")))

(define %my-services
  (modify-services %desktop-services
    (slim-service-type config =>
                       (slim-configuration
                        (inherit config)
                        (startx (xorg-start-command
                                 #:configuration-file my-xorg-conf))))))

(operating-system
  (host-name "komputilo")
  (timezone "America/New_York")
  (locale "fr_FR.utf8")

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (target "/boot")))

  (file-systems (cons* (file-system
                         (device "my-root")
                         (title 'label)
                         (mount-point "/")
                         (type "ext4"))
                       (file-system
                         (device (uuid "E599-8158" 'fat))
                         (title 'uuid)
                         (mount-point "/boot")
                         (type "vfat"))
                       %base-file-systems))

  (users (cons (user-account
                (name "ian")
                (group "users")
                (supplementary-groups '("wheel" "netdev"
                                        "audio" "video"))
                (home-directory "/home/ian"))
               %base-user-accounts))

  (packages (cons* i3-wm i3status dmenu
                   pulseaudio
                   light                ; for setting backlight
                   nss-certs
                   %base-packages))

  ;; Use the "desktop" services, which include the X11
  ;; log-in service, networking with Wicd, and more.
  (services %my-services)

  (setuid-programs (cons* #~(string-append #$light "/bin/light")
                          %setuid-programs))

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))
