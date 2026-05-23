import { DEFAULT_LOCALE } from "./locale";
import type { Device, ProjectState, Slide } from "./types";

let _id = 0;
export const nid = () => `s_${Date.now().toString(36)}_${(_id++).toString(36)}`;

const en = (s: string) => ({ en: s });
const enJa = (enText: string, jaText: string) => ({ en: enText, ja: jaText });

const iphoneShot = (n: string) =>
  `/screenshots/apple/iphone/{locale}/${n}.png`;
const ipadShot = (n: string) => `/screenshots/apple/ipad/{locale}/${n}.png`;

function talkShuffleIphoneSlides(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: enJa("TALK SHUFFLE", "トーク支援"),
      headline: enJa("Pick a topic\nin seconds.", "話題が\nすぐ決まる"),
      screenshot: iphoneShot("01"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("3D DICE", "3Dサイコロ"),
      headline: enJa("Roll for your\nnext prompt.", "サイコロで\nテーマ決定"),
      screenshot: iphoneShot("02"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("SESSION", "セッション"),
      headline: enJa("Set players\nand timer.", "人数とタイマー\nを設定"),
      screenshot: iphoneShot("03"),
    },
    {
      id: nid(),
      layout: "device-top",
      label: enJa("VALUE CARDS", "価値観カード"),
      headline: enJa("Share values\nthrough play.", "価値観を\n共有する"),
      screenshot: iphoneShot("04"),
      inverted: true,
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("GROUP TALK", "グループ"),
      headline: enJa("Prompt cards\nfor teams.", "チーム向け\nプロンプト"),
      screenshot: iphoneShot("05"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("HISTORY", "履歴"),
      headline: enJa("Sessions stay\non your device.", "履歴は端末内\nに保存"),
      screenshot: iphoneShot("06"),
    },
  ];
}

function talkShuffleIpadSlides(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: enJa("TALK SHUFFLE", "トーク支援"),
      headline: enJa("Built for\nbigger sessions.", "大きな画面で\nもっと見やすく"),
      screenshot: ipadShot("01"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("3D DICE", "3Dサイコロ"),
      headline: enJa("Roll for your\nnext prompt.", "サイコロで\nテーマ決定"),
      screenshot: ipadShot("02"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("VALUE CARDS", "価値観カード"),
      headline: enJa("Rank and share\nwhat matters.", "大切な価値観を\n並べる"),
      screenshot: ipadShot("03"),
    },
    {
      id: nid(),
      layout: "device-top",
      label: enJa("SESSION", "セッション"),
      headline: enJa("Set players\nand timer.", "人数とタイマー\nを設定"),
      screenshot: ipadShot("04"),
      inverted: true,
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("GROUP TALK", "グループ"),
      headline: enJa("Prompt cards\nfor teams.", "チーム向け\nプロンプト"),
      screenshot: ipadShot("05"),
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: enJa("HISTORY", "履歴"),
      headline: enJa("Sessions stay\non your device.", "履歴は端末内\nに保存"),
      screenshot: ipadShot("06"),
    },
  ];
}

function makeStarterSlides(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("MEET YOUR APP"),
      headline: en("Sell one\nidea per slide."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: en("FEATURE 01"),
      headline: en("Your headline\nlives here."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "two-devices",
      label: en("FEATURE 02"),
      headline: en("Show two\nscreens at once."),
      screenshot: "",
      screenshotSecondary: "",
    },
    {
      id: nid(),
      layout: "device-top",
      label: en("FEATURE 03"),
      headline: en("Flip the contrast\nfor visual rhythm."),
      screenshot: "",
      inverted: true,
    },
    {
      id: nid(),
      layout: "no-device",
      label: en("MORE"),
      headline: en("And so\nmuch more."),
      screenshot: "",
    },
  ];
}

function ipadStarter(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("MEET YOUR APP"),
      headline: en("Made for\nthe big screen."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: en("FEATURE 01"),
      headline: en("Built for\nfocus."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "device-top",
      label: en("FEATURE 02"),
      headline: en("Always within reach."),
      screenshot: "",
      inverted: true,
    },
  ];
}

function tabletStarter(kind: "7" | "10"): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("MEET YOUR APP"),
      headline: en(kind === "7" ? "Pocket-sized\npower." : "Made for\nthe big screen."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "split-landscape",
      label: en("FEATURE 01"),
      headline: en("Wide canvas,\nbigger ideas."),
      screenshot: "",
    },
  ];
}

function fgStarter(): Slide[] {
  return [
    {
      id: nid(),
      layout: "feature-graphic",
      label: {},
      headline: enJa("Pick a topic fast.", "話題がすぐ決まる"),
      screenshot: "",
    },
  ];
}

export const DEFAULT_PROJECT: ProjectState = {
  appName: "Talk Shuffle",
  themeId: "talk-shuffle",
  locales: ["en", "ja"],
  locale: DEFAULT_LOCALE,
  device: "iphone",
  orientation: "portrait",
  appIcon: "/app-icon.png",
  slidesByDevice: {
    iphone: talkShuffleIphoneSlides(),
    android: makeStarterSlides(),
    ipad: talkShuffleIpadSlides(),
    "android-7": tabletStarter("7"),
    "android-10": tabletStarter("10"),
    "feature-graphic": fgStarter(),
  },
};

export function newSlide(layout: Slide["layout"] = "device-bottom"): Slide {
  return {
    id: nid(),
    layout,
    label: en("NEW"),
    headline: en("Edit this\nheadline."),
    screenshot: "",
  };
}

export function detectPlatform(device: Device): "ios" | "android" {
  return device === "iphone" || device === "ipad" ? "ios" : "android";
}
