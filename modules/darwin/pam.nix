{ ... }:

{
  # /etc/pam.d/sudo_local
  # "auth       sufficient     pam_tid.so"
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };
}
