import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// アプリのタイトル
  ///
  /// In ja, this message translates to:
  /// **'Talk Seed'**
  String get appTitle;

  /// 設定画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// 保存ボタン
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// 設定に戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'設定に戻る'**
  String get backToSettings;

  /// サイコロを振るボタン（DicePage用）
  ///
  /// In ja, this message translates to:
  /// **'サイコロを振る'**
  String get rollDice;

  /// 初期設定完了ボタン（サイコロ画面へ遷移）
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get complete;

  /// テーマ設定画面のメインCTA（サイコロ画面へすぐ遷移）
  ///
  /// In ja, this message translates to:
  /// **'すぐ振る'**
  String get rollNow;

  /// セッション設定画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'みんなで遊ぶ'**
  String get playWithOthers;

  /// 案B: サイコロ画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'サイコロで遊ぶ'**
  String get playWithDice;

  /// 案B: トピックカード画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'カードで遊ぶ'**
  String get playWithCards;

  /// 案B: いつもこれで遊ぶ（サイコロ）
  ///
  /// In ja, this message translates to:
  /// **'起動時にサイコロで開く'**
  String get alwaysOpenWithDice;

  /// 案B: いつもこれで遊ぶ（カード）
  ///
  /// In ja, this message translates to:
  /// **'起動時にカードで開く'**
  String get alwaysOpenWithCards;

  /// 案B: 起動時デフォルトのセクション見出し
  ///
  /// In ja, this message translates to:
  /// **'次回起動時'**
  String get startupDefaultSection;

  /// テーマ選択を促すメッセージ（サイコロ画面用）
  ///
  /// In ja, this message translates to:
  /// **'サイコロをタップして\nテーマを選ぼう！'**
  String get selectThemePrompt;

  /// テーマ選択を促すメッセージ（カード画面用）
  ///
  /// In ja, this message translates to:
  /// **'下のボタンで1枚引こう'**
  String get selectThemePromptCard;

  /// サイコロの面のラベル
  ///
  /// In ja, this message translates to:
  /// **'面{faceNumber}'**
  String faceLabel(int faceNumber);

  /// テーマ入力フィールドのヒント
  ///
  /// In ja, this message translates to:
  /// **'テーマを入力またはドラッグ'**
  String get themeInputHint;

  /// ドロップ可能な領域のヒント
  ///
  /// In ja, this message translates to:
  /// **'ここにドロップ'**
  String get dropHere;

  /// ランダムにセットボタン
  ///
  /// In ja, this message translates to:
  /// **'ランダムにセット'**
  String get randomSet;

  /// リセットボタン
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get reset;

  /// リセットと面リストの間の小タイトル
  ///
  /// In ja, this message translates to:
  /// **'各面の表示'**
  String get faceThemesList;

  /// テーマ候補セクションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'テーマ候補'**
  String get themeCandidates;

  /// ドラッグ＆ドロップの説明
  ///
  /// In ja, this message translates to:
  /// **'左のテキストボックスにドラッグ＆ドロップ'**
  String get dragAndDropHint;

  /// チュートリアル1ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'Talk Seedへようこそ！'**
  String get tutorialWelcome;

  /// チュートリアル1ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'サイコロでテーマを選んだり、カードで問いを引いて話を深めたり。\n\nみんなで盛り上がることも、仕事の場（チーム・会議・1on1）でも使えます。'**
  String get tutorialWelcomeBody;

  /// チュートリアル2ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'テーマを設定しよう'**
  String get tutorialSetTheme;

  /// チュートリアル2ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'「みんなで盛り上がる」で選ぶサイコロの、各面に表示するテーマを設定します。\n\n右側の候補からドラッグ＆ドロップするか、直接入力してください。'**
  String get tutorialSetThemeBody;

  /// チュートリアル3ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'サイコロを振る'**
  String get tutorialRollDice;

  /// チュートリアル3ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'設定が完了したら「サイコロを振る」ボタンを押してください。\n\n3Dアニメーションでサイコロが転がり、\nランダムなテーマが選ばれます。'**
  String get tutorialRollDiceBody;

  /// チュートリアル・カードページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'カードで遊ぶ'**
  String get tutorialCards;

  /// チュートリアル・カードページの本文
  ///
  /// In ja, this message translates to:
  /// **'「仕事で盛り上がる」では3種類のカードデッキが選べます。\n\nチームビルディング（価値観共有）、チェックイン・チェックアウト（会議の開始・終了）、自己内省・1on1（軽さ×深さの問い）です。'**
  String get tutorialCardsBody;

  /// チュートリアル設定ページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'設定を変更する'**
  String get tutorialChangeSettings;

  /// チュートリアル設定ページの本文
  ///
  /// In ja, this message translates to:
  /// **'いつでも設定画面からサイコロのテーマを変更できます。\n\n右上の設定アイコンからアクセスできます。'**
  String get tutorialChangeSettingsBody;

  /// チュートリアル最終ページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'準備完了！'**
  String get tutorialReady;

  /// チュートリアル最終ページの本文
  ///
  /// In ja, this message translates to:
  /// **'それでは、はじめましょう。\n\nサイコロでテーマを選んでも、カードで問いを引いてもOK。場に合わせて使ってください。'**
  String get tutorialReadyBody;

  /// タイマースキップボタン
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skip;

  /// チュートリアルの開始ボタン
  ///
  /// In ja, this message translates to:
  /// **'始める'**
  String get start;

  /// チュートリアルを表示するボタン
  ///
  /// In ja, this message translates to:
  /// **'チュートリアルを表示'**
  String get showTutorial;

  /// 正六面体のテーマ設定セクション
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get themeCube;

  /// テーマ編集セクションのサブタイトル
  ///
  /// In ja, this message translates to:
  /// **'あなたのテーマ'**
  String get yourThemes;

  /// テーマ候補エリアの説明文
  ///
  /// In ja, this message translates to:
  /// **'候補をドラッグで選択'**
  String get useVariantsToChooseTheme;

  /// No description provided for @themeSurprised.
  ///
  /// In ja, this message translates to:
  /// **'びっくりしたこと'**
  String get themeSurprised;

  /// No description provided for @themeFutureDream.
  ///
  /// In ja, this message translates to:
  /// **'将来の夢'**
  String get themeFutureDream;

  /// No description provided for @themeLoveStory.
  ///
  /// In ja, this message translates to:
  /// **'恋の話'**
  String get themeLoveStory;

  /// No description provided for @themeRecommendedBook.
  ///
  /// In ja, this message translates to:
  /// **'おすすめの本'**
  String get themeRecommendedBook;

  /// No description provided for @themeRecentHobby.
  ///
  /// In ja, this message translates to:
  /// **'最近ハマっていること'**
  String get themeRecentHobby;

  /// No description provided for @themeDislike.
  ///
  /// In ja, this message translates to:
  /// **'嫌いなこと'**
  String get themeDislike;

  /// No description provided for @themeFavoriteMovie.
  ///
  /// In ja, this message translates to:
  /// **'好きな映画'**
  String get themeFavoriteMovie;

  /// No description provided for @themeTreasure.
  ///
  /// In ja, this message translates to:
  /// **'大切にしていること'**
  String get themeTreasure;

  /// No description provided for @themeCried.
  ///
  /// In ja, this message translates to:
  /// **'泣いたこと'**
  String get themeCried;

  /// No description provided for @themeLaughed.
  ///
  /// In ja, this message translates to:
  /// **'笑ったこと'**
  String get themeLaughed;

  /// No description provided for @themeMoved.
  ///
  /// In ja, this message translates to:
  /// **'感動したこと'**
  String get themeMoved;

  /// No description provided for @themeRegret.
  ///
  /// In ja, this message translates to:
  /// **'後悔していること'**
  String get themeRegret;

  /// No description provided for @themeProud.
  ///
  /// In ja, this message translates to:
  /// **'誇らしいこと'**
  String get themeProud;

  /// No description provided for @themeEmbarrassed.
  ///
  /// In ja, this message translates to:
  /// **'恥ずかしかったこと'**
  String get themeEmbarrassed;

  /// No description provided for @themeFavoriteMusic.
  ///
  /// In ja, this message translates to:
  /// **'好きな音楽'**
  String get themeFavoriteMusic;

  /// No description provided for @themeFavoriteAnime.
  ///
  /// In ja, this message translates to:
  /// **'好きなアニメ'**
  String get themeFavoriteAnime;

  /// No description provided for @themeFavoriteGame.
  ///
  /// In ja, this message translates to:
  /// **'好きなゲーム'**
  String get themeFavoriteGame;

  /// No description provided for @themeFavoriteFood.
  ///
  /// In ja, this message translates to:
  /// **'好きな食べ物'**
  String get themeFavoriteFood;

  /// No description provided for @themeWantToVisit.
  ///
  /// In ja, this message translates to:
  /// **'行きたい場所'**
  String get themeWantToVisit;

  /// No description provided for @themeFavoriteSport.
  ///
  /// In ja, this message translates to:
  /// **'好きなスポーツ'**
  String get themeFavoriteSport;

  /// No description provided for @themeFriendMemory.
  ///
  /// In ja, this message translates to:
  /// **'友達との思い出'**
  String get themeFriendMemory;

  /// No description provided for @themeFamilyMemory.
  ///
  /// In ja, this message translates to:
  /// **'家族との思い出'**
  String get themeFamilyMemory;

  /// No description provided for @themeGrateful.
  ///
  /// In ja, this message translates to:
  /// **'感謝していること'**
  String get themeGrateful;

  /// No description provided for @themeSupporting.
  ///
  /// In ja, this message translates to:
  /// **'応援している人'**
  String get themeSupporting;

  /// No description provided for @themeWantToDo.
  ///
  /// In ja, this message translates to:
  /// **'やってみたいこと'**
  String get themeWantToDo;

  /// No description provided for @themeWantToAchieve.
  ///
  /// In ja, this message translates to:
  /// **'実現したいこと'**
  String get themeWantToAchieve;

  /// No description provided for @themeDreamJob.
  ///
  /// In ja, this message translates to:
  /// **'なりたい職業'**
  String get themeDreamJob;

  /// No description provided for @themeWantToVisitCountry.
  ///
  /// In ja, this message translates to:
  /// **'行ってみたい国'**
  String get themeWantToVisitCountry;

  /// No description provided for @themeRecentEvent.
  ///
  /// In ja, this message translates to:
  /// **'最近の出来事'**
  String get themeRecentEvent;

  /// No description provided for @themeTodayEvent.
  ///
  /// In ja, this message translates to:
  /// **'今日の出来事'**
  String get themeTodayEvent;

  /// No description provided for @themeWeekendPlan.
  ///
  /// In ja, this message translates to:
  /// **'週末の予定'**
  String get themeWeekendPlan;

  /// No description provided for @themeRelaxMethod.
  ///
  /// In ja, this message translates to:
  /// **'リラックス方法'**
  String get themeRelaxMethod;

  /// No description provided for @themeStressRelief.
  ///
  /// In ja, this message translates to:
  /// **'ストレス解消法'**
  String get themeStressRelief;

  /// No description provided for @themeMorningRoutine.
  ///
  /// In ja, this message translates to:
  /// **'朝のルーティン'**
  String get themeMorningRoutine;

  /// No description provided for @themeFavoriteWord.
  ///
  /// In ja, this message translates to:
  /// **'好きな言葉'**
  String get themeFavoriteWord;

  /// No description provided for @themeMotto.
  ///
  /// In ja, this message translates to:
  /// **'座右の銘'**
  String get themeMotto;

  /// No description provided for @themeImportantThing.
  ///
  /// In ja, this message translates to:
  /// **'大切なもの'**
  String get themeImportantThing;

  /// No description provided for @themeBelief.
  ///
  /// In ja, this message translates to:
  /// **'信じていること'**
  String get themeBelief;

  /// No description provided for @themeLifeLesson.
  ///
  /// In ja, this message translates to:
  /// **'人生で学んだこと'**
  String get themeLifeLesson;

  /// No description provided for @themeRecentWorry.
  ///
  /// In ja, this message translates to:
  /// **'最近の悩み'**
  String get themeRecentWorry;

  /// No description provided for @themeProudOf.
  ///
  /// In ja, this message translates to:
  /// **'自慢できること'**
  String get themeProudOf;

  /// No description provided for @themeUniqueSkill.
  ///
  /// In ja, this message translates to:
  /// **'変わった特技'**
  String get themeUniqueSkill;

  /// No description provided for @themeSecret.
  ///
  /// In ja, this message translates to:
  /// **'秘密にしていること'**
  String get themeSecret;

  /// No description provided for @themeChildhoodMemory.
  ///
  /// In ja, this message translates to:
  /// **'子供の頃の思い出'**
  String get themeChildhoodMemory;

  /// セッション設定画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'セッション設定'**
  String get sessionSetup;

  /// セッション設定の遊び方セクション見出し
  ///
  /// In ja, this message translates to:
  /// **'遊び方'**
  String get playModeLabel;

  /// 遊び方：サイコロ
  ///
  /// In ja, this message translates to:
  /// **'サイコロで'**
  String get playModeDice;

  /// 遊び方：トピックカード
  ///
  /// In ja, this message translates to:
  /// **'トピックカードで'**
  String get playModeTopicCard;

  /// トピックカード画面で1枚引くボタン
  ///
  /// In ja, this message translates to:
  /// **'トピックを引く'**
  String get drawTopic;

  /// チェックイン・チェックアウトの会議前フェーズ
  ///
  /// In ja, this message translates to:
  /// **'会議前'**
  String get phaseCheckIn;

  /// チェックイン・チェックアウトの会議後フェーズ
  ///
  /// In ja, this message translates to:
  /// **'会議後'**
  String get phaseCheckOut;

  /// No description provided for @checkInPickOnePrompt.
  ///
  /// In ja, this message translates to:
  /// **'この中から1問選んでください'**
  String get checkInPickOnePrompt;

  /// No description provided for @reselectQuestion.
  ///
  /// In ja, this message translates to:
  /// **'選び直す'**
  String get reselectQuestion;

  /// No description provided for @chosenCardLabelBefore.
  ///
  /// In ja, this message translates to:
  /// **'会議前に選んだ問い'**
  String get chosenCardLabelBefore;

  /// No description provided for @chosenCardLabelAfter.
  ///
  /// In ja, this message translates to:
  /// **'会議後に選んだ問い'**
  String get chosenCardLabelAfter;

  /// 参加人数のラベル
  ///
  /// In ja, this message translates to:
  /// **'参加人数'**
  String get playerCount;

  /// タイマー設定セクションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'タイマー設定'**
  String get timerSettings;

  /// タイマー有効化のチェックボックス
  ///
  /// In ja, this message translates to:
  /// **'タイマーを有効にする'**
  String get enableTimer;

  /// タイマー時間のラベル
  ///
  /// In ja, this message translates to:
  /// **'時間'**
  String get timerDuration;

  /// プレイヤー名のラベル
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー{number}'**
  String playerName(int number);

  /// セッション開始ボタン
  ///
  /// In ja, this message translates to:
  /// **'セッション開始'**
  String get startSession;

  /// 現在のプレイヤー表示
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー {current}/{total} の番'**
  String currentPlayer(int current, int total);

  /// 次のプレイヤーへ進むボタン
  ///
  /// In ja, this message translates to:
  /// **'次のプレイヤー'**
  String get nextPlayer;

  /// セッション終了ボタン
  ///
  /// In ja, this message translates to:
  /// **'セッション終了'**
  String get endSession;

  /// セッション終了画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'セッション終了'**
  String get sessionSummary;

  /// セッション終了ダイアログの本文
  ///
  /// In ja, this message translates to:
  /// **'全員の番が終わりました。'**
  String get sessionCompleteMessage;

  /// ラウンド番号
  ///
  /// In ja, this message translates to:
  /// **'ラウンド {number}'**
  String round(int number);

  /// タイマー一時停止ボタン
  ///
  /// In ja, this message translates to:
  /// **'一時停止'**
  String get pause;

  /// タイマー再開ボタン
  ///
  /// In ja, this message translates to:
  /// **'再開'**
  String get resume;

  /// 共有ボタン
  ///
  /// In ja, this message translates to:
  /// **'共有'**
  String get share;

  /// 新しいセッション開始ボタン
  ///
  /// In ja, this message translates to:
  /// **'新しいセッション'**
  String get newSession;

  /// セッション設定画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'セッション設定へ'**
  String get goToSessionSetup;

  /// テーマ設定画面に戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'テーマ設定に戻る'**
  String get backToThemeSettings;

  /// No description provided for @timer30Seconds.
  ///
  /// In ja, this message translates to:
  /// **'30秒'**
  String get timer30Seconds;

  /// No description provided for @timer1Minute.
  ///
  /// In ja, this message translates to:
  /// **'1分'**
  String get timer1Minute;

  /// No description provided for @timer2Minutes.
  ///
  /// In ja, this message translates to:
  /// **'2分'**
  String get timer2Minutes;

  /// No description provided for @timer3Minutes.
  ///
  /// In ja, this message translates to:
  /// **'3分'**
  String get timer3Minutes;

  /// No description provided for @timer5Minutes.
  ///
  /// In ja, this message translates to:
  /// **'5分'**
  String get timer5Minutes;

  /// No description provided for @timerUnlimited.
  ///
  /// In ja, this message translates to:
  /// **'無制限'**
  String get timerUnlimited;

  /// プレイヤー名セクションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー名（オプション）'**
  String get playerNamesOptional;

  /// プレイヤー名入力の説明
  ///
  /// In ja, this message translates to:
  /// **'入力するとセッション中に表示。空欄は番号で表示されます。'**
  String get playerNamesHint;

  /// No description provided for @sessionPreviewTitle.
  ///
  /// In ja, this message translates to:
  /// **'このセッション'**
  String get sessionPreviewTitle;

  /// No description provided for @sessionPreviewPlayers.
  ///
  /// In ja, this message translates to:
  /// **'{count}人でプレイ'**
  String sessionPreviewPlayers(int count);

  /// No description provided for @sessionPreviewTimer.
  ///
  /// In ja, this message translates to:
  /// **'制限時間：{timer}'**
  String sessionPreviewTimer(String timer);

  /// No description provided for @sessionPreviewNoTimer.
  ///
  /// In ja, this message translates to:
  /// **'タイマーなし'**
  String get sessionPreviewNoTimer;

  /// モード選択画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'遊び方を選んでください'**
  String get modeSelectionTitle;

  /// 初回画面セクション見出し（みんなで）
  ///
  /// In ja, this message translates to:
  /// **'みんなで盛り上がる'**
  String get homeSectionEveryone;

  /// 初回画面セクション見出し（仕事）
  ///
  /// In ja, this message translates to:
  /// **'仕事で盛り上がる'**
  String get homeSectionWork;

  /// 初回画面・みんなで盛り上がるの1項目
  ///
  /// In ja, this message translates to:
  /// **'サイコロ'**
  String get homeDiceLabel;

  /// モード選択画面に戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'モードを選び直す'**
  String get backToModeSelection;

  /// カード設定画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'カードを選ぶ'**
  String get cardSettingsTitle;

  /// デッキ選択の説明
  ///
  /// In ja, this message translates to:
  /// **'デッキを選んでください'**
  String get selectDeckPrompt;

  /// 選択したデッキで遊ぶボタン
  ///
  /// In ja, this message translates to:
  /// **'このデッキで遊ぶ'**
  String get playWithDeck;

  /// No description provided for @deckTeamBuilding.
  ///
  /// In ja, this message translates to:
  /// **'チームビルディング'**
  String get deckTeamBuilding;

  /// No description provided for @deckTeamBuildingDesc.
  ///
  /// In ja, this message translates to:
  /// **'価値観を共有し、チームの理解を深める'**
  String get deckTeamBuildingDesc;

  /// No description provided for @deckCheckIn.
  ///
  /// In ja, this message translates to:
  /// **'チェックイン・チェックアウト'**
  String get deckCheckIn;

  /// No description provided for @deckCheckInDesc.
  ///
  /// In ja, this message translates to:
  /// **'会議の開始・終了に。問いを元に全員が一言ずつ'**
  String get deckCheckInDesc;

  /// No description provided for @deckSelfReflection.
  ///
  /// In ja, this message translates to:
  /// **'自己内省・1on1'**
  String get deckSelfReflection;

  /// No description provided for @deckSelfReflectionDesc.
  ///
  /// In ja, this message translates to:
  /// **'軽さ×深さの問い。1人で内省も、1on1でも'**
  String get deckSelfReflectionDesc;

  /// No description provided for @deckOneOnOne.
  ///
  /// In ja, this message translates to:
  /// **'成長対話'**
  String get deckOneOnOne;

  /// No description provided for @deckOneOnOneDesc.
  ///
  /// In ja, this message translates to:
  /// **'1on1で。評価を抜きに、未来・詰まり・伸ばしたいことを話す'**
  String get deckOneOnOneDesc;

  /// No description provided for @deckRetrospective.
  ///
  /// In ja, this message translates to:
  /// **'振り返り'**
  String get deckRetrospective;

  /// No description provided for @deckRetrospectiveDesc.
  ///
  /// In ja, this message translates to:
  /// **'チームで。良かった点・改善点・学びを振り返る'**
  String get deckRetrospectiveDesc;

  /// No description provided for @deckIceBreaker.
  ///
  /// In ja, this message translates to:
  /// **'アイスブレイク'**
  String get deckIceBreaker;

  /// No description provided for @deckIceBreakerDesc.
  ///
  /// In ja, this message translates to:
  /// **'場あたために。雰囲気を和らげる軽い話題'**
  String get deckIceBreakerDesc;

  /// No description provided for @themeTrust.
  ///
  /// In ja, this message translates to:
  /// **'信頼関係を大切にする'**
  String get themeTrust;

  /// No description provided for @themeChallenge.
  ///
  /// In ja, this message translates to:
  /// **'挑戦を恐れない'**
  String get themeChallenge;

  /// No description provided for @themeGratitude.
  ///
  /// In ja, this message translates to:
  /// **'感謝を伝えることを大切にする'**
  String get themeGratitude;

  /// No description provided for @themeFeedback.
  ///
  /// In ja, this message translates to:
  /// **'フィードバックを歓迎する'**
  String get themeFeedback;

  /// No description provided for @themeFlexibility.
  ///
  /// In ja, this message translates to:
  /// **'柔軟に対応する'**
  String get themeFlexibility;

  /// No description provided for @themeResponsibility.
  ///
  /// In ja, this message translates to:
  /// **'責任を持ってやり遂げる'**
  String get themeResponsibility;

  /// No description provided for @themeGrowth.
  ///
  /// In ja, this message translates to:
  /// **'成長し続けたい'**
  String get themeGrowth;

  /// No description provided for @themeWorkLifeBalance.
  ///
  /// In ja, this message translates to:
  /// **'ワークライフバランスを重視する'**
  String get themeWorkLifeBalance;

  /// No description provided for @themeCollaboration.
  ///
  /// In ja, this message translates to:
  /// **'協力して成し遂げる'**
  String get themeCollaboration;

  /// No description provided for @themeTransparency.
  ///
  /// In ja, this message translates to:
  /// **'オープンに情報を共有する'**
  String get themeTransparency;

  /// No description provided for @themeWeeklyHighlight.
  ///
  /// In ja, this message translates to:
  /// **'今週のハイライト'**
  String get themeWeeklyHighlight;

  /// No description provided for @themeTodayGoal.
  ///
  /// In ja, this message translates to:
  /// **'今日の目標'**
  String get themeTodayGoal;

  /// No description provided for @themeBlocker.
  ///
  /// In ja, this message translates to:
  /// **'困っていること'**
  String get themeBlocker;

  /// No description provided for @themeCurrentMood.
  ///
  /// In ja, this message translates to:
  /// **'今の気持ち'**
  String get themeCurrentMood;

  /// No description provided for @themeOneWord.
  ///
  /// In ja, this message translates to:
  /// **'今日の一言'**
  String get themeOneWord;

  /// No description provided for @themeWellDone.
  ///
  /// In ja, this message translates to:
  /// **'うまくいったこと'**
  String get themeWellDone;

  /// No description provided for @themeStruggle.
  ///
  /// In ja, this message translates to:
  /// **'苦戦していること'**
  String get themeStruggle;

  /// No description provided for @themeWantToGrow.
  ///
  /// In ja, this message translates to:
  /// **'成長したいこと'**
  String get themeWantToGrow;

  /// No description provided for @themeFeedbackWant.
  ///
  /// In ja, this message translates to:
  /// **'フィードバックがほしいこと'**
  String get themeFeedbackWant;

  /// No description provided for @themeGoodPoint.
  ///
  /// In ja, this message translates to:
  /// **'良かった点'**
  String get themeGoodPoint;

  /// No description provided for @themeImprovePoint.
  ///
  /// In ja, this message translates to:
  /// **'改善したい点'**
  String get themeImprovePoint;

  /// No description provided for @themeLearnings.
  ///
  /// In ja, this message translates to:
  /// **'学んだこと'**
  String get themeLearnings;

  /// No description provided for @themeNextAction.
  ///
  /// In ja, this message translates to:
  /// **'次にやること'**
  String get themeNextAction;

  /// No description provided for @themeThanks.
  ///
  /// In ja, this message translates to:
  /// **'感謝したいこと'**
  String get themeThanks;

  /// No description provided for @themeHonesty.
  ///
  /// In ja, this message translates to:
  /// **'誠実であることを重んじる'**
  String get themeHonesty;

  /// No description provided for @themeInnovation.
  ///
  /// In ja, this message translates to:
  /// **'新しいやり方を試す'**
  String get themeInnovation;

  /// No description provided for @themeStability.
  ///
  /// In ja, this message translates to:
  /// **'安定を大切にする'**
  String get themeStability;

  /// No description provided for @themeAutonomy.
  ///
  /// In ja, this message translates to:
  /// **'自分の裁量で決めたい'**
  String get themeAutonomy;

  /// No description provided for @themeCommunity.
  ///
  /// In ja, this message translates to:
  /// **'仲間やチームを大切にする'**
  String get themeCommunity;

  /// No description provided for @themeQuality.
  ///
  /// In ja, this message translates to:
  /// **'質を最優先する'**
  String get themeQuality;

  /// No description provided for @themeSpeed.
  ///
  /// In ja, this message translates to:
  /// **'スピードを重視する'**
  String get themeSpeed;

  /// No description provided for @themeCustomerFirst.
  ///
  /// In ja, this message translates to:
  /// **'お客様第一で考える'**
  String get themeCustomerFirst;

  /// No description provided for @themeLearning.
  ///
  /// In ja, this message translates to:
  /// **'学び続けることを大切にする'**
  String get themeLearning;

  /// No description provided for @themeBalance.
  ///
  /// In ja, this message translates to:
  /// **'バランスを取ることを心がける'**
  String get themeBalance;

  /// No description provided for @themeCreativity.
  ///
  /// In ja, this message translates to:
  /// **'創造性を大切にする'**
  String get themeCreativity;

  /// No description provided for @themeEmpathy.
  ///
  /// In ja, this message translates to:
  /// **'相手の気持ちに寄り添う'**
  String get themeEmpathy;

  /// No description provided for @themeConsistency.
  ///
  /// In ja, this message translates to:
  /// **'一貫性を保つ'**
  String get themeConsistency;

  /// No description provided for @themeRespect.
  ///
  /// In ja, this message translates to:
  /// **'多様性を尊重する'**
  String get themeRespect;

  /// No description provided for @themeValuePriority.
  ///
  /// In ja, this message translates to:
  /// **'大切なことを優先する'**
  String get themeValuePriority;

  /// No description provided for @themeValueIntegrity.
  ///
  /// In ja, this message translates to:
  /// **'信じていることに従って行動する'**
  String get themeValueIntegrity;

  /// No description provided for @valuePlayerTurn.
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー{player}の番'**
  String valuePlayerTurn(int player);

  /// No description provided for @valueDiscardPrompt.
  ///
  /// In ja, this message translates to:
  /// **'自分の価値観から最も遠いカードをタップして捨ててください'**
  String get valueDiscardPrompt;

  /// No description provided for @valueRankPrompt.
  ///
  /// In ja, this message translates to:
  /// **'6枚を重要度順に並べてください（上＝大切、下＝手放す）'**
  String get valueRankPrompt;

  /// No description provided for @valueConfirmRanking.
  ///
  /// In ja, this message translates to:
  /// **'確定して手放す'**
  String get valueConfirmRanking;

  /// No description provided for @valueDiscardLabel.
  ///
  /// In ja, this message translates to:
  /// **'手放す'**
  String get valueDiscardLabel;

  /// No description provided for @valuePlayerFinalCards.
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー{player}が残した5枚'**
  String valuePlayerFinalCards(int player);

  /// No description provided for @valueNext.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get valueNext;

  /// No description provided for @valueGameComplete.
  ///
  /// In ja, this message translates to:
  /// **'お疲れさまでした'**
  String get valueGameComplete;

  /// No description provided for @valueSharePrompt.
  ///
  /// In ja, this message translates to:
  /// **'残った5枚のカードを参加者に見せ、共有しましょう'**
  String get valueSharePrompt;

  /// No description provided for @valuePlayerCount.
  ///
  /// In ja, this message translates to:
  /// **'参加人数'**
  String get valuePlayerCount;

  /// No description provided for @valueStart.
  ///
  /// In ja, this message translates to:
  /// **'スタート'**
  String get valueStart;

  /// No description provided for @valueBackToDeck.
  ///
  /// In ja, this message translates to:
  /// **'デッキ選択に戻る'**
  String get valueBackToDeck;

  /// No description provided for @valueDrawCard.
  ///
  /// In ja, this message translates to:
  /// **'山札から1枚引く'**
  String get valueDrawCard;

  /// No description provided for @valueRound.
  ///
  /// In ja, this message translates to:
  /// **'{current}/5 ラウンド'**
  String valueRound(int current);

  /// アセット読み込みエラーのタイトル
  ///
  /// In ja, this message translates to:
  /// **'データの読み込みに失敗しました'**
  String get errorDataLoadTitle;

  /// アセット読み込みエラーの本文
  ///
  /// In ja, this message translates to:
  /// **'問いのデータを読み込めませんでした。しばらくしてからもう一度お試しください。'**
  String get errorDataLoadMessage;

  /// 再試行ボタン
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get retry;

  /// エラーダイアログの閉じるボタン
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get dismiss;

  /// 起動時既定をクリアする設定のラベル
  ///
  /// In ja, this message translates to:
  /// **'起動時にモード選択を表示する'**
  String get showModeSelectionAtStartup;

  /// 起動時既定クリア時のスナックバー
  ///
  /// In ja, this message translates to:
  /// **'設定しました。次回起動時はモード選択が表示されます。'**
  String get showModeSelectionAtStartupDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
