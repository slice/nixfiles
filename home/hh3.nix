{ pkgs, ... }:

let
  conservative = [
    "sentrynerf"
    "pseudoscience"
    "localStorage"
    "preserveToken"
    "noconmsg"
  ];
  full = conservative ++ [
    "loadingScreen"
    "createEmoji"
    "copyAvatarUrl"
    "experiments"
    "postnet"
    "oldQuote"
    "3y3"
    "unravelMessage"
    "callIdling"
    "fixmentions"
    "imageUrls"
    "panic"
    "noJoinMessageWave"
    "tardid"
    "inviteToNowhere"
    "timeBarAllActivities"
    "hiddenProfileColors"
    "mediaMosaicTweaks"
  ];
in
{
  programs.hh3 = {
    enable = true;
    config = {
      canary = {
        enable = true;
        inspectAll = true;

        exts = {
          customRinging = {
            enabled = false;
            options.ptt_stop = "https://cdn.discordapp.com/attachments/228317351672545290/973531652745728000/MicUpLoud.wav";
            options.ptt_start = "https://cdn.discordapp.com/attachments/228317351672545290/973531761558568971/MicDownLoud.wav";
          };
          rpcTypeChanger = {
            enabled = false;
            options.mappings = {
              "402370117901484042" = "2";
              "899192189618368552" = "2";
            };
          };
          commands = {
            enabled = false;
            options.dangerMode = true;
          };
          css = {
            enabled = true;
            options.cssPath =
              let
                mainFont = "Lato";
              in
              pkgs.writeText "discord.css" ''
                :root {
                  --font-code: "PragmataPro" !important;
                  --font-japanese: "M PLUS 1", "Mplus 1p" !important;
                  --font-primary: "${mainFont}", "M PLUS 1", "Mplus 1p" !important;
                  --font-display: "${mainFont}", "M PLUS 1", sans-serif !important;
                  --font-headline: "ABC Ginto Nord","M PLUS 1",sans-serif !important;
                }

                :root:not(.app-focused) {
                  [class*="sidebar"],
                  [data-list-id="guildsnav"],
                  [aria-label="Channel header"] {
                    opacity: 0.4;
                    filter: grayscale(100%);
                  }
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
                  font-size: 14px !important;
                }
              '';
          };
          whoJoined = {
            enabled = true;
            options.username = true;
          };
          hiddenTyping = {
            enabled = false;
            options.whenInvisible = true;
          };
          declutterTextButtons = {
            enabled = false;
            options.keepGif = true;
          };
        };

        enabledExts = conservative;
      };
    };
  };
}
