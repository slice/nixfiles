{ pkgs, ... }:

{
  programs.hh3 = {
    enable = true;
    config = {
      canary = {
        enable = true;

        inspectAll = false;

        exts = {
          pinnedDMs = {
            enabled = true;
            options.pinned = [ "896562285596778547" "939928912710991953" ];
          };
          volumeLimit = {
            enabled = true;
            options.limit = 500;
          };
          customRinging = {
            enabled = true;
            options.ptt_stop =
              "https://cdn.discordapp.com/attachments/228317351672545290/973531652745728000/MicUpLoud.wav";
            options.ptt_start =
              "https://cdn.discordapp.com/attachments/228317351672545290/973531761558568971/MicDownLoud.wav";
          };
          consistentLayout = {
            enabled = true;
            options.mappings = {
              "805978396974514210" = "805978396974514209";
              "720021430456156191" = "720021452526714911";
              "720021441831239730" = "720021452526714911";
              "881009103818874911" = "881008163879522364";
              "149998215457013760" = "882132747005624351";
            };
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
          pseudoNitro = {
            enabled = true;
            options.parseOnly = true;
          };
          css = {
            enabled = true;
            options.cssPath = let mainFont = "Source Sans Pro";
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
          typingChannel = {
            enabled = true;
            options.ignoreSelf = true;
          };
          declutterTextButtons = {
            enabled = true;
            options.keepGif = true;
          };
        };

        enabledExts = [
          "autopatch"
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
          "unravelMessage"
          "callIdling"
          "fixmentions"
          "imageUrls"
          "uncollapseThreads"
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
          "inviteToNowhere"
          "timeBarAllActivities"
          "hiddenProfileColors"
          "arbitraryVoiceMessages"
          "antiDelete"
        ];
      };
    };
  };
}
