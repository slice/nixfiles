{ pkgs, ... }:

{
  programs.hh3 = {
    enable = true;
    config = {
      canary = {
        enable = true;

        # my beloved
        inspectAll = true;

        exts = {
          pinnedDMs = {
            enabled = true;
            options = {
              pinned = [
                "896923292013834260"
                "896562285596778547"
                "723796426827759647"
              ];
            };
          };
          consistentLayout = {
            enabled = true;
            options = {
              mappings = {
                "805978396974514210" = "805978396974514209";
                "720021430456156191" = "720021452526714911";
                "720021441831239730" = "720021452526714911";
                "881009103818874911" = "881008163879522364";
                "149998215457013760" = "882132747005624351";
              };
            };
          };
          commands = {
            enabled = true;
            options.dangerMode = true;
          };
          imgxis = {
            enabled = true;
            options.smoothImage = true;
          };
          pseudoNitro = {
            enabled = true;
            options.parseOnly = true;
          };
          css = {
            enabled = true;
            options.cssPath = pkgs.writeText "discord.css" ''
              :root {
                --font-code: PragmataPro !important;
              }
              code,
              [class^="markup-"] code,
              [class^="after_inlineCode-"],
              [class^="inlineCode-"],
              [class^="before_inlineCode-"],
              [class^="codeBlockText-"] [class^="codeLine-"],
              .codeBlockText-311wOq, .codeLine-3a3dbd {
                font-family: PragmataPro !important;
              }
            '';
          };
          whoJoined = {
            enabled = true;
            options.username = true;
          };
          hiddenTyping = {
            enabled = true;
            options.whenInvisible = true;
          };
        };

        enabledExts = [
          "whoReacted"
          "inspect"
          "sentrynerf"
          "pseudoscience"
          "noVoice"
          "noAgeGate"
          "upload"
          "loadingScreen"
          "createEmoji"
          "copyAvatarUrl"
          "downmark"
          "experiments"
          "localStorage"
          "preserveToken"
          "postnet"
          "imgtitle"
          "oldQuote"
          "3y3"
          "typingChannel"
          "unravelMessage"
          "callIdling"
          "fixmentions"
          "imageUrls"
          "noconmsg"
          "timeInCall"
          "greentext"
          "panic"
          "hateno"
          "channelleak"
          "activitiesEverywhere"
          "noJoinMessageWave"
          "messageLinkPreview"
          "ruby"
          "tardid"
          "typingAvatars"
        ];
      };
    };
  };
}
