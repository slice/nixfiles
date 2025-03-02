{ ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # caps lock becomes escape
  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };

  console = {
    # https://adeverteuil.github.io/linux-console-fonts-screenshots/#lat4-19psfu
    font = "lat4-19";
    # use xserver xkb options
    useXkbConfig = true;
  };
}
