{ pkgs, ... }:

{
  programs.hh3 = {
    enable = true;
    config = {
      canary = {
        enable = true;

        inspectAll = false;

        exts = {
          customRinging = {
            enabled = true;
            options.ptt_stop =
              "https://cdn.discordapp.com/attachments/228317351672545290/973531652745728000/MicUpLoud.wav";
            options.ptt_start =
              "https://cdn.discordapp.com/attachments/228317351672545290/973531761558568971/MicDownLoud.wav";
          };
          rpcTypeChanger = {
            enabled = true;
            options.mappings = {
              "402370117901484042" = "2";
              "899192189618368552" = "2";
            };
          };
          commands = {
            enabled = true;
            options.dangerMode = true;
          };
          imgxis = {
            enabled = false;
            options.smoothImage = true;
          };
          css = {
            enabled = true;
            options.cssPath = let mainFont = "Lato";
            in pkgs.writeText "discord.css" ''
              :root {
                --font-code: "Inconsolata" !important;
                --font-japanese: "M PLUS 1", "Mplus 1p" !important;
                --font-primary: "${mainFont}", "M PLUS 1", "Mplus 1p" !important;
                --font-display: "${mainFont}", "M PLUS 1", sans-serif !important;
                --font-headline: "ABC Ginto Nord","M PLUS 1",sans-serif !important;
              }

              [class^="markdown-"] [class^="codeInline-"],
              [class^="codeLine-"],
              [class^="codeBlockText-"],
              [class^="durationTimeDisplay-"],
              [class^="durationTimeSeparator-"],
              [class*="after_inlineCode-"],
              [class*="before_inlineCode-"],
              [class^="inlineCode-"],
              code.inline,
              code,
              .hljs {
                font-family: var(--font-code) !important;
                font-size: 16px !important;
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
          declutterTextButtons = {
            enabled = true;
            options.keepGif = true;
          };
        };

        enabledExts = [
          "inspect"
          "sentrynerf"
          "pseudoscience"
          "noVoice"
          "loadingScreen"
          "createEmoji"
          "copyAvatarUrl"
          "downmark"
          "experiments"
          "localStorage"
          "preserveToken"
          "postnet"
          "oldQuote"
          "3y3"
          "unravelMessage"
          "callIdling"
          "fixmentions"
          "imageUrls"
          "noconmsg"
          "timeInCall"
          "panic"
          "noJoinMessageWave"
          "tardid"
          "typingAvatars"
          "inviteToNowhere"
          "timeBarAllActivities"
          "hiddenProfileColors"
          "antiDelete"
          "mediaMosaicTweaks"
          "greentext"
        ];
      };
    };
  };
}
