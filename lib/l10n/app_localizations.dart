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
  /// **'Talk Shuffle'**
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
  /// **'セッションへ'**
  String get playWithOthers;

  /// 案B: サイコロ画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'サイコロへ'**
  String get playWithDice;

  /// 案B: トピックカード画面へ遷移するボタン
  ///
  /// In ja, this message translates to:
  /// **'カードで遊ぶ'**
  String get playWithCards;

  /// 起動時デフォルト。randomLabel は homeRandomDecideLabel と同一に渡す
  ///
  /// In ja, this message translates to:
  /// **'次回起動も「{randomLabel}」と同じ流れで開く'**
  String alwaysOpenWithDice(String randomLabel);

  /// ランダム起動オプションの補足（サイコロという語を使わない）
  ///
  /// In ja, this message translates to:
  /// **'この一覧を開かず、テーマを決める準備画面から始まります（上のボタンと同じ経路）'**
  String get alwaysOpenWithDiceHint;

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

  /// サイコロでテーマが出た時のキャッチフレーズ
  ///
  /// In ja, this message translates to:
  /// **'このテーマが出たー！'**
  String get themeResultAnnouncement;

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

  /// サイコロ・価値観カードのバイブ設定
  ///
  /// In ja, this message translates to:
  /// **'バイブを有効にする'**
  String get vibrationEnabled;

  /// タイマー終了時のシステム通知音（バイブとは別）
  ///
  /// In ja, this message translates to:
  /// **'タイマー終了音'**
  String get timerSoundEnabled;

  /// リセットと面リストの間の小タイトル
  ///
  /// In ja, this message translates to:
  /// **'サイコロの面の表示'**
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
  /// **'Talk Shuffleへようこそ！'**
  String get tutorialWelcome;

  /// チュートリアル1ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'サイコロでテーマを選ぶか、カードで自分の価値観を話します。盛り上がりにも仕事の場にも使えます。'**
  String get tutorialWelcomeBody;

  /// チュートリアル2ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'テーマを設定しよう'**
  String get tutorialSetTheme;

  /// チュートリアル2ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'各面のテーマを、候補からドラッグまたは直接入力で設定します。'**
  String get tutorialSetThemeBody;

  /// チュートリアル3ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'サイコロを振る'**
  String get tutorialRollDice;

  /// チュートリアル3ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'「サイコロを振る」を押すとサイコロが転がり、ランダムなテーマが選ばれます。'**
  String get tutorialRollDiceBody;

  /// チュートリアル・カードページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'カードで遊ぶ'**
  String get tutorialCards;

  /// チュートリアル・カードページの本文
  ///
  /// In ja, this message translates to:
  /// **'「仕事で盛り上がる」では3種類のカードデッキが選べます。\n\n価値観カード（価値観共有）、会議前・振り返り（会議の開始・終了）、自己内省・1on1（軽さ×深さの問い）です。'**
  String get tutorialCardsBody;

  /// チュートリアル設定ページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'設定を変更する'**
  String get tutorialChangeSettings;

  /// チュートリアル設定ページの本文
  ///
  /// In ja, this message translates to:
  /// **'いつでも戻るボタンで設定画面に戻り、人数やタイマーを変更できます。'**
  String get tutorialChangeSettingsBody;

  /// チュートリアル最終ページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'準備完了！'**
  String get tutorialReady;

  /// チュートリアル最終ページの本文
  ///
  /// In ja, this message translates to:
  /// **'サイコロでテーマを選んでも、カードで価値観を話し合ってもOK。場に合わせて使いましょう。'**
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
  /// **'話すテーマを選ぼう'**
  String get yourThemes;

  /// テーマ候補エリアの説明文
  ///
  /// In ja, this message translates to:
  /// **'画面左にドラッグ'**
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

  /// 会議前・振り返りの会議前フェーズ
  ///
  /// In ja, this message translates to:
  /// **'会議前'**
  String get phaseCheckIn;

  /// 会議前・振り返りの会議後フェーズ
  ///
  /// In ja, this message translates to:
  /// **'会議後'**
  String get phaseCheckOut;

  /// No description provided for @checkInPickOnePrompt.
  ///
  /// In ja, this message translates to:
  /// **'この中から1問選んでください'**
  String get checkInPickOnePrompt;

  /// No description provided for @checkInHowManyPrompt.
  ///
  /// In ja, this message translates to:
  /// **'何枚選びますか？'**
  String get checkInHowManyPrompt;

  /// No description provided for @checkInCardsOne.
  ///
  /// In ja, this message translates to:
  /// **'1枚'**
  String get checkInCardsOne;

  /// No description provided for @checkInCardsTwo.
  ///
  /// In ja, this message translates to:
  /// **'2枚'**
  String get checkInCardsTwo;

  /// No description provided for @checkInCardsThree.
  ///
  /// In ja, this message translates to:
  /// **'3枚'**
  String get checkInCardsThree;

  /// No description provided for @checkInDrawCountButton.
  ///
  /// In ja, this message translates to:
  /// **'この枚数で選ぶ'**
  String get checkInDrawCountButton;

  /// No description provided for @levelBeginner.
  ///
  /// In ja, this message translates to:
  /// **'初級'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In ja, this message translates to:
  /// **'中級'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In ja, this message translates to:
  /// **'上級'**
  String get levelAdvanced;

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

  /// カウントダウン終了時の非モーダル表示
  ///
  /// In ja, this message translates to:
  /// **'時間です'**
  String get timerTimeUp;

  /// タイマー終了後に1分延長するボタン
  ///
  /// In ja, this message translates to:
  /// **'+1分'**
  String get timerExtendOneMinute;

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

  /// セッション振り返り画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'今話したセッションのまとめ'**
  String get sessionSummaryScreenTitle;

  /// 投票画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'一番面白かった人は？'**
  String get voteTitle;

  /// 投票画面のサブタイトル
  ///
  /// In ja, this message translates to:
  /// **'今回のトピックで一番話が面白かった人に1票'**
  String get voteSubtitle;

  /// 投票しているプレイヤー表示
  ///
  /// In ja, this message translates to:
  /// **'投票者：{player}'**
  String voteVoterLabel(String player);

  /// 投票結果の見出し
  ///
  /// In ja, this message translates to:
  /// **'投票結果'**
  String get voteResultsTitle;

  /// 投票数の表示
  ///
  /// In ja, this message translates to:
  /// **'{count}票'**
  String voteCount(int count);

  /// 投票スキップボタン
  ///
  /// In ja, this message translates to:
  /// **'投票をスキップ'**
  String get voteSkip;

  /// 振り返り画面でセッションを終了するボタン
  ///
  /// In ja, this message translates to:
  /// **'セッションを終了'**
  String get sessionEndButton;

  /// 振り返り画面のプレイヤー行（プレイヤー名）
  ///
  /// In ja, this message translates to:
  /// **'{player}のトピック'**
  String sessionSummaryPlayerTheme(String player);

  /// 履歴一覧のタイトル
  ///
  /// In ja, this message translates to:
  /// **'履歴'**
  String get historyTitle;

  /// 情報メニューのツールチップ
  ///
  /// In ja, this message translates to:
  /// **'アプリについて'**
  String get aboutApp;

  /// サポートページへのリンク
  ///
  /// In ja, this message translates to:
  /// **'サポート'**
  String get support;

  /// プライバシーポリシーへのリンク
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// 履歴が空のときのメッセージ
  ///
  /// In ja, this message translates to:
  /// **'まだ記録がありません'**
  String get historyEmptyMessage;

  /// フィルタ結果が空のときのメッセージ
  ///
  /// In ja, this message translates to:
  /// **'条件に合う履歴がありません'**
  String get historyEmptyFiltered;

  /// 履歴一覧の表示テキスト
  ///
  /// In ja, this message translates to:
  /// **'{date} {mode}をプレイ'**
  String historyListItemTitle(String date, String mode);

  /// 履歴の参加人数表示
  ///
  /// In ja, this message translates to:
  /// **'{count}人でプレイ'**
  String historyPlayerCount(int count);

  /// 履歴詳細画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'履歴詳細'**
  String get historyDetailTitle;

  /// 履歴詳細の概要セクション
  ///
  /// In ja, this message translates to:
  /// **'概要'**
  String get historySummaryTitle;

  /// 履歴詳細の出たテーマセクション
  ///
  /// In ja, this message translates to:
  /// **'出たテーマ'**
  String get historyTopicsTitle;

  /// 履歴詳細の選択カードセクション
  ///
  /// In ja, this message translates to:
  /// **'選択したカード'**
  String get historySelectedCardsTitle;

  /// 履歴用のモード表示（サイコロ）
  ///
  /// In ja, this message translates to:
  /// **'サイコロ'**
  String get historyModeDice;

  /// 履歴用のモード表示（価値観カード）
  ///
  /// In ja, this message translates to:
  /// **'価値観カード'**
  String get historyModeValueCards;

  /// 履歴フィルタ（全て）
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get historyFilterAll;

  /// 履歴フィルタ（サイコロ）
  ///
  /// In ja, this message translates to:
  /// **'サイコロ'**
  String get historyFilterDice;

  /// 履歴フィルタ（価値観カード）
  ///
  /// In ja, this message translates to:
  /// **'価値観カード'**
  String get historyFilterValueCards;

  /// No description provided for @historyModeDiscussion.
  ///
  /// In ja, this message translates to:
  /// **'議論・お題'**
  String get historyModeDiscussion;

  /// No description provided for @historyFilterDiscussion.
  ///
  /// In ja, this message translates to:
  /// **'議論・お題'**
  String get historyFilterDiscussion;

  /// 履歴全削除ボタン
  ///
  /// In ja, this message translates to:
  /// **'履歴を全削除'**
  String get historyDeleteAll;

  /// 履歴全削除の確認ダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'履歴を全削除しますか？'**
  String get historyDeleteAllTitle;

  /// 履歴全削除の確認ダイアログ本文
  ///
  /// In ja, this message translates to:
  /// **'この端末の履歴がすべて削除されます。'**
  String get historyDeleteAllMessage;

  /// 履歴1件削除ボタン
  ///
  /// In ja, this message translates to:
  /// **'この履歴を削除'**
  String get historyDeleteOne;

  /// 履歴1件削除の確認ダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'この履歴を削除しますか？'**
  String get historyDeleteOneTitle;

  /// 履歴1件削除の確認ダイアログ本文
  ///
  /// In ja, this message translates to:
  /// **'この履歴は元に戻せません。'**
  String get historyDeleteOneMessage;

  /// 削除ボタン
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// キャンセルボタン
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

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
  /// **'プレイヤー名を指定できます、下のボックスをタップ'**
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
  /// **'Welcome to Talk Shuffle!\n遊び方を選んでください'**
  String get modeSelectionTitle;

  /// 初回画面セクション見出し（みんなで）
  ///
  /// In ja, this message translates to:
  /// **'サイコロを振ってランダムな話題で盛り上がろう'**
  String get homeSectionEveryone;

  /// 初回画面セクション見出し（仕事）
  ///
  /// In ja, this message translates to:
  /// **'カードを選択して互いに価値観を表現しよう'**
  String get homeSectionWork;

  /// 初回画面・みんなで盛り上がるの1項目
  ///
  /// In ja, this message translates to:
  /// **'ランダムトピック'**
  String get homeDiceLabel;

  /// 案B：テーマ選択カード内の見出し
  ///
  /// In ja, this message translates to:
  /// **'テーマを選ぼう'**
  String get homeThemePickTitle;

  /// 案B：ランダム開始ボタン（サイコロ相当）
  ///
  /// In ja, this message translates to:
  /// **'ランダムで決める'**
  String get homeRandomDecideLabel;

  /// No description provided for @homeThemeShortSocial.
  ///
  /// In ja, this message translates to:
  /// **'社会課題'**
  String get homeThemeShortSocial;

  /// No description provided for @homeThemeShortProblem.
  ///
  /// In ja, this message translates to:
  /// **'問題解決'**
  String get homeThemeShortProblem;

  /// No description provided for @homeThemeShortValues.
  ///
  /// In ja, this message translates to:
  /// **'価値観'**
  String get homeThemeShortValues;

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
  /// **'価値観カード'**
  String get deckTeamBuilding;

  /// No description provided for @deckTeamBuildingDesc.
  ///
  /// In ja, this message translates to:
  /// **'価値観を共有し、チームの理解を深める'**
  String get deckTeamBuildingDesc;

  /// No description provided for @deckProblemSolving.
  ///
  /// In ja, this message translates to:
  /// **'問題解決練習カード'**
  String get deckProblemSolving;

  /// No description provided for @deckProblemSolvingDesc.
  ///
  /// In ja, this message translates to:
  /// **'課題の整理の練習：目的・選択肢・リスク・次の一歩'**
  String get deckProblemSolvingDesc;

  /// No description provided for @deckSocialIssues.
  ///
  /// In ja, this message translates to:
  /// **'社会課題ディスカッション'**
  String get deckSocialIssues;

  /// No description provided for @deckSocialIssuesDesc.
  ///
  /// In ja, this message translates to:
  /// **'現代のテーマを、構造的かつ尊重し合う形で議論する'**
  String get deckSocialIssuesDesc;

  /// No description provided for @discussionScreenTitle.
  ///
  /// In ja, this message translates to:
  /// **'議論モード'**
  String get discussionScreenTitle;

  /// No description provided for @discussionHint.
  ///
  /// In ja, this message translates to:
  /// **'順位づけは不要です。話がひと段落したら、別のお題へ進んで大丈夫です。'**
  String get discussionHint;

  /// No description provided for @discussionNextTopic.
  ///
  /// In ja, this message translates to:
  /// **'別のお題へ'**
  String get discussionNextTopic;

  /// No description provided for @discussionNextTopicHelp.
  ///
  /// In ja, this message translates to:
  /// **'別の切り口がほしくなったら（任意）'**
  String get discussionNextTopicHelp;

  /// No description provided for @discussionPromptQueue.
  ///
  /// In ja, this message translates to:
  /// **'お題の並び · {current}/{total} · いつでもスキップOK'**
  String discussionPromptQueue(int current, int total);

  /// No description provided for @discussionSessionEndTitle.
  ///
  /// In ja, this message translates to:
  /// **'このセッションの終わり'**
  String get discussionSessionEndTitle;

  /// No description provided for @discussionSessionEndBody.
  ///
  /// In ja, this message translates to:
  /// **'お題をすべて使い切らなくて大丈夫です。全員が一度ずつ話したら終了です。'**
  String get discussionSessionEndBody;

  /// No description provided for @discussionDeckScopeTitle.
  ///
  /// In ja, this message translates to:
  /// **'このセッションで使うお題'**
  String get discussionDeckScopeTitle;

  /// No description provided for @discussionDeckScopeFull.
  ///
  /// In ja, this message translates to:
  /// **'デッキ全枚（シャッフル）'**
  String get discussionDeckScopeFull;

  /// No description provided for @discussionDeckScopeTen.
  ///
  /// In ja, this message translates to:
  /// **'10枚だけランダム'**
  String get discussionDeckScopeTen;

  /// No description provided for @discussionDeckScopeSix.
  ///
  /// In ja, this message translates to:
  /// **'6枚だけランダム'**
  String get discussionDeckScopeSix;

  /// No description provided for @discussionDeckScopeThree.
  ///
  /// In ja, this message translates to:
  /// **'3枚だけ（深掘り向け）'**
  String get discussionDeckScopeThree;

  /// No description provided for @discussionPreviewAllPrompts.
  ///
  /// In ja, this message translates to:
  /// **'お題: 全{deck}枚をシャッフル'**
  String discussionPreviewAllPrompts(int deck);

  /// No description provided for @discussionPreviewSampledPrompts.
  ///
  /// In ja, this message translates to:
  /// **'お題: {deck}枚中から{n}枚をランダム抽出'**
  String discussionPreviewSampledPrompts(int n, int deck);

  /// No description provided for @discussionPreviewSessionEnd.
  ///
  /// In ja, this message translates to:
  /// **'終了: 全員が一度話したとき'**
  String get discussionPreviewSessionEnd;

  /// No description provided for @deckCheckIn.
  ///
  /// In ja, this message translates to:
  /// **'会議前・振り返り'**
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

  /// No description provided for @themeProbLogical1.
  ///
  /// In ja, this message translates to:
  /// **'売上が先月比30%ダウン。考えられる原因をMECEに分類せよ'**
  String get themeProbLogical1;

  /// No description provided for @themeProbLogical2.
  ///
  /// In ja, this message translates to:
  /// **'施策AとB、どちらを優先する？判断軸を3つ挙げて説明せよ'**
  String get themeProbLogical2;

  /// No description provided for @themeProbLogical3.
  ///
  /// In ja, this message translates to:
  /// **'会議が毎回長引く。根本原因はどこにあるか構造的に分析せよ'**
  String get themeProbLogical3;

  /// No description provided for @themeProbLogical4.
  ///
  /// In ja, this message translates to:
  /// **'新規事業の参入可否を1分で判断するには？最低限必要な情報は何か'**
  String get themeProbLogical4;

  /// No description provided for @themeProbLogical5.
  ///
  /// In ja, this message translates to:
  /// **'顧客からのクレームが増えている。どこから手をつけるか優先順位をつけよ'**
  String get themeProbLogical5;

  /// No description provided for @themeProbLogical6.
  ///
  /// In ja, this message translates to:
  /// **'チームの生産性が下がっている。ボトルネックを特定するために何を調べるか'**
  String get themeProbLogical6;

  /// No description provided for @themeProbLogical7.
  ///
  /// In ja, this message translates to:
  /// **'「コストを20%削減せよ」と言われた。どのカテゴリから削るか論理的に説明せよ'**
  String get themeProbLogical7;

  /// No description provided for @themeProbLogical8.
  ///
  /// In ja, this message translates to:
  /// **'A案とB案でデータが相反している。どちらを信頼するか、判断基準を示せ'**
  String get themeProbLogical8;

  /// No description provided for @themeProbLogical9.
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトが炎上しかけている。まず誰に何を報告するか、優先順位をつけよ'**
  String get themeProbLogical9;

  /// No description provided for @themeProbLogical10.
  ///
  /// In ja, this message translates to:
  /// **'「忙しいのに成果が出ない」状態を構造的に説明し、打ち手を示せ'**
  String get themeProbLogical10;

  /// No description provided for @themeProbCreative1.
  ///
  /// In ja, this message translates to:
  /// **'「待ち時間」を価値に変えるビジネスを3つ考えよ'**
  String get themeProbCreative1;

  /// No description provided for @themeProbCreative2.
  ///
  /// In ja, this message translates to:
  /// **'社内の紙をゼロにするには？常識を疑って発想せよ'**
  String get themeProbCreative2;

  /// No description provided for @themeProbCreative3.
  ///
  /// In ja, this message translates to:
  /// **'競合と全く逆の戦略を取るとしたら何をする？'**
  String get themeProbCreative3;

  /// No description provided for @themeProbCreative4.
  ///
  /// In ja, this message translates to:
  /// **'10年後、あなたの職種はどう変わる？それを逆手にとるアイデアは'**
  String get themeProbCreative4;

  /// No description provided for @themeProbCreative5.
  ///
  /// In ja, this message translates to:
  /// **'自社のサービスを「子ども向け」にリデザインするとしたら？'**
  String get themeProbCreative5;

  /// No description provided for @themeProbCreative6.
  ///
  /// In ja, this message translates to:
  /// **'予算ゼロで社員のモチベーションを上げる方法を5つ出せ'**
  String get themeProbCreative6;

  /// No description provided for @themeProbCreative7.
  ///
  /// In ja, this message translates to:
  /// **'「失敗したプロジェクト」を資産に変えるアイデアを考えよ'**
  String get themeProbCreative7;

  /// No description provided for @themeProbCreative8.
  ///
  /// In ja, this message translates to:
  /// **'他業界から1つビジネスモデルを借りてきて、自社に応用せよ'**
  String get themeProbCreative8;

  /// No description provided for @themeProbCreative9.
  ///
  /// In ja, this message translates to:
  /// **'「通勤時間」を会社の強みに変えるにはどうする？'**
  String get themeProbCreative9;

  /// No description provided for @themeProbCreative10.
  ///
  /// In ja, this message translates to:
  /// **'もし価格を10倍にするとしたら、何を変える必要があるか？'**
  String get themeProbCreative10;

  /// No description provided for @themeProbFermi1.
  ///
  /// In ja, this message translates to:
  /// **'渋谷駅を1日に通過する人は何人？'**
  String get themeProbFermi1;

  /// No description provided for @themeProbFermi2.
  ///
  /// In ja, this message translates to:
  /// **'日本全国のオフィスの椅子の数は？'**
  String get themeProbFermi2;

  /// No description provided for @themeProbFermi3.
  ///
  /// In ja, this message translates to:
  /// **'自社の社員が1年間に書くメールの総文字数は？'**
  String get themeProbFermi3;

  /// No description provided for @themeProbFermi4.
  ///
  /// In ja, this message translates to:
  /// **'東京都内に信号機はいくつある？'**
  String get themeProbFermi4;

  /// No description provided for @themeProbFermi5.
  ///
  /// In ja, this message translates to:
  /// **'日本で1日に消費されるコーヒーのカップ数は？'**
  String get themeProbFermi5;

  /// No description provided for @themeProbFermi6.
  ///
  /// In ja, this message translates to:
  /// **'日本全国のコンビニで1日に捨てられる弁当の数は？'**
  String get themeProbFermi6;

  /// No description provided for @themeProbFermi7.
  ///
  /// In ja, this message translates to:
  /// **'自社のオフィスで1年間に使われる電力量はどのくらい？'**
  String get themeProbFermi7;

  /// No description provided for @themeProbFermi8.
  ///
  /// In ja, this message translates to:
  /// **'東京都内を走るタクシーの総走行距離（1日）は？'**
  String get themeProbFermi8;

  /// No description provided for @themeProbFermi9.
  ///
  /// In ja, this message translates to:
  /// **'日本全国のスマートフォンのバッテリーを合計すると何Wh？'**
  String get themeProbFermi9;

  /// No description provided for @themeProbFermi10.
  ///
  /// In ja, this message translates to:
  /// **'今この瞬間、日本で会議をしている人は何人いる？'**
  String get themeProbFermi10;

  /// No description provided for @themeProbDilemma1.
  ///
  /// In ja, this message translates to:
  /// **'優秀だが協調性のないメンバー。残す？外す？判断基準を言語化せよ'**
  String get themeProbDilemma1;

  /// No description provided for @themeProbDilemma2.
  ///
  /// In ja, this message translates to:
  /// **'締め切り厳守 vs クオリティ死守。どちらを選ぶ？条件は？'**
  String get themeProbDilemma2;

  /// No description provided for @themeProbDilemma3.
  ///
  /// In ja, this message translates to:
  /// **'上司の判断が明らかに間違っている。あなたはどう動く？'**
  String get themeProbDilemma3;

  /// No description provided for @themeProbDilemma4.
  ///
  /// In ja, this message translates to:
  /// **'短期利益 vs 長期ブランド。トレードオフが生じたときの優先順位は？'**
  String get themeProbDilemma4;

  /// No description provided for @themeProbDilemma5.
  ///
  /// In ja, this message translates to:
  /// **'チームの仲が良すぎて馴れ合いになっている。どう介入する？'**
  String get themeProbDilemma5;

  /// No description provided for @themeProbDilemma6.
  ///
  /// In ja, this message translates to:
  /// **'正直に言うと相手を傷つける。でも黙ると組織が傷つく。どうする？'**
  String get themeProbDilemma6;

  /// No description provided for @themeProbDilemma7.
  ///
  /// In ja, this message translates to:
  /// **'実力はあるが自己主張が強すぎる部下と、素直だが成長が遅い部下。どちらを昇進させる？'**
  String get themeProbDilemma7;

  /// No description provided for @themeProbDilemma8.
  ///
  /// In ja, this message translates to:
  /// **'成功確率20%だが成功すれば大きいA案と、確実だが小さく終わるB案。どちらを取る？'**
  String get themeProbDilemma8;

  /// No description provided for @themeProbDilemma9.
  ///
  /// In ja, this message translates to:
  /// **'自分のミスを報告すると、チームの評価が下がる可能性がある。どうする？'**
  String get themeProbDilemma9;

  /// No description provided for @themeProbDilemma10.
  ///
  /// In ja, this message translates to:
  /// **'リソースが足りない。既存顧客の満足度を守る vs 新規顧客を獲得する。どちらを優先？'**
  String get themeProbDilemma10;

  /// No description provided for @themeSocGeo1.
  ///
  /// In ja, this message translates to:
  /// **'米中対立が激化したとき、企業はどちらの経済圏を選ぶべきか？'**
  String get themeSocGeo1;

  /// No description provided for @themeSocGeo2.
  ///
  /// In ja, this message translates to:
  /// **'関税・貿易戦争は「国を守る手段」か、「世界を貧しくする愚策」か？'**
  String get themeSocGeo2;

  /// No description provided for @themeSocGeo3.
  ///
  /// In ja, this message translates to:
  /// **'経済安全保障のために、企業はどこまでサプライチェーンを自国回帰すべきか？'**
  String get themeSocGeo3;

  /// No description provided for @themeSocGeo4.
  ///
  /// In ja, this message translates to:
  /// **'ロシア・ウクライナ戦争が長期化すると、グローバルビジネスにどんな影響が続くか？'**
  String get themeSocGeo4;

  /// No description provided for @themeSocGeo5.
  ///
  /// In ja, this message translates to:
  /// **'「友好国とだけ貿易するフレンドショアリング」は現実的な戦略か？'**
  String get themeSocGeo5;

  /// No description provided for @themeSocGeo6.
  ///
  /// In ja, this message translates to:
  /// **'中東情勢が不安定なまま続く場合、エネルギーコストに企業はどう備えるか？'**
  String get themeSocGeo6;

  /// No description provided for @themeSocGeo7.
  ///
  /// In ja, this message translates to:
  /// **'国連・WTOへの信頼が崩れたとき、世界秩序はどう維持されるか？'**
  String get themeSocGeo7;

  /// No description provided for @themeSocGeo8.
  ///
  /// In ja, this message translates to:
  /// **'地政学リスクを「経営課題」として扱えていない企業は生き残れるか？'**
  String get themeSocGeo8;

  /// No description provided for @themeSocGeo9.
  ///
  /// In ja, this message translates to:
  /// **'グローバルサウス（新興国・途上国）の台頭は、世界にとってチャンスか脅威か？'**
  String get themeSocGeo9;

  /// No description provided for @themeSocGeo10.
  ///
  /// In ja, this message translates to:
  /// **'「どの国とも仲良くする」外交戦略は、これからも通用するか？'**
  String get themeSocGeo10;

  /// No description provided for @themeSocAiGap1.
  ///
  /// In ja, this message translates to:
  /// **'AIの恩恵を受けるのは結局、お金と技術を持つ国や企業だけではないか？'**
  String get themeSocAiGap1;

  /// No description provided for @themeSocAiGap2.
  ///
  /// In ja, this message translates to:
  /// **'AIが意思決定した結果に問題が起きたとき、責任は誰が取るのか？'**
  String get themeSocAiGap2;

  /// No description provided for @themeSocAiGap3.
  ///
  /// In ja, this message translates to:
  /// **'採用・融資・医療診断をAIが決める社会は、公平か？危険か？'**
  String get themeSocAiGap3;

  /// No description provided for @themeSocAiGap4.
  ///
  /// In ja, this message translates to:
  /// **'特定の企業がAIを独占することは、民主主義への脅威になるか？'**
  String get themeSocAiGap4;

  /// No description provided for @themeSocAiGap5.
  ///
  /// In ja, this message translates to:
  /// **'国境を越えて動くAIを誰が規制すべきか？各国政府？国際機関？企業自身？'**
  String get themeSocAiGap5;

  /// No description provided for @themeSocAiGap6.
  ///
  /// In ja, this message translates to:
  /// **'AIによる雇用喪失に対し、ベーシックインカムは解決策になるか？'**
  String get themeSocAiGap6;

  /// No description provided for @themeSocAiGap7.
  ///
  /// In ja, this message translates to:
  /// **'AI格差により先進国と途上国の生産性の差が広がることを、誰が止めるべきか？'**
  String get themeSocAiGap7;

  /// No description provided for @themeSocAiGap8.
  ///
  /// In ja, this message translates to:
  /// **'生成AIで大量の偽情報が拡散する社会で、「本物」をどう見分けるか？'**
  String get themeSocAiGap8;

  /// No description provided for @themeSocAiGap9.
  ///
  /// In ja, this message translates to:
  /// **'AIを「兵器」として使う国が増えた場合、国際的なルールは作れるか？'**
  String get themeSocAiGap9;

  /// No description provided for @themeSocAiGap10.
  ///
  /// In ja, this message translates to:
  /// **'10年後、AIが「持てる国」と「持たざる国」の差をどう変えると思うか？'**
  String get themeSocAiGap10;

  /// No description provided for @themeSocClimate1.
  ///
  /// In ja, this message translates to:
  /// **'気候変動対策に消極的な国の製品に「炭素関税」をかけることは公平か？'**
  String get themeSocClimate1;

  /// No description provided for @themeSocClimate2.
  ///
  /// In ja, this message translates to:
  /// **'再生可能エネルギーのリーダーが中国になりつつある。世界はそれでいいか？'**
  String get themeSocClimate2;

  /// No description provided for @themeSocClimate3.
  ///
  /// In ja, this message translates to:
  /// **'企業のESGレポートはほとんど「グリーンウォッシュ」だと思うか？'**
  String get themeSocClimate3;

  /// No description provided for @themeSocClimate4.
  ///
  /// In ja, this message translates to:
  /// **'気候変動で住めなくなった地域からの「気候難民」を、豊かな国はどう受け入れるべきか？'**
  String get themeSocClimate4;

  /// No description provided for @themeSocClimate5.
  ///
  /// In ja, this message translates to:
  /// **'経済成長と脱炭素は本当に両立できるか？'**
  String get themeSocClimate5;

  /// No description provided for @themeSocClimate6.
  ///
  /// In ja, this message translates to:
  /// **'肉食・航空機利用など個人の行動変容で、気候は本当に変わるか？'**
  String get themeSocClimate6;

  /// No description provided for @themeSocClimate7.
  ///
  /// In ja, this message translates to:
  /// **'先進国と途上国で、気候変動対策の「責任」は同じであるべきか？'**
  String get themeSocClimate7;

  /// No description provided for @themeSocClimate8.
  ///
  /// In ja, this message translates to:
  /// **'原子力を「グリーンエネルギー」と呼ぶことに、賛成か反対か？'**
  String get themeSocClimate8;

  /// No description provided for @themeSocClimate9.
  ///
  /// In ja, this message translates to:
  /// **'2050年ゼロカーボンが達成できない場合、次の世代にどう説明するか？'**
  String get themeSocClimate9;

  /// No description provided for @themeSocClimate10.
  ///
  /// In ja, this message translates to:
  /// **'気候変動対策として、今すぐ一つだけ実行するとしたら何を選ぶか？'**
  String get themeSocClimate10;

  /// No description provided for @themeSocDemocracy1.
  ///
  /// In ja, this message translates to:
  /// **'富裕層への課税を強化して格差を縮めることに、賛成か反対か？'**
  String get themeSocDemocracy1;

  /// No description provided for @themeSocDemocracy2.
  ///
  /// In ja, this message translates to:
  /// **'SNSのアルゴリズムは民主主義を壊しているか？それとも強化しているか？'**
  String get themeSocDemocracy2;

  /// No description provided for @themeSocDemocracy3.
  ///
  /// In ja, this message translates to:
  /// **'選挙にAIや偽情報が介入した場合、選挙結果は有効か？'**
  String get themeSocDemocracy3;

  /// No description provided for @themeSocDemocracy4.
  ///
  /// In ja, this message translates to:
  /// **'「強いリーダーシップ」と「独裁」の境界線はどこか？'**
  String get themeSocDemocracy4;

  /// No description provided for @themeSocDemocracy5.
  ///
  /// In ja, this message translates to:
  /// **'フェイクニュースを拡散した人は、法的に罰せられるべきか？'**
  String get themeSocDemocracy5;

  /// No description provided for @themeSocDemocracy6.
  ///
  /// In ja, this message translates to:
  /// **'SNSプラットフォームは「言論の場」か、「メディア企業」として規制されるべきか？'**
  String get themeSocDemocracy6;

  /// No description provided for @themeSocDemocracy7.
  ///
  /// In ja, this message translates to:
  /// **'「エコーチェンバー」から抜け出すために、個人は何ができるか？'**
  String get themeSocDemocracy7;

  /// No description provided for @themeSocDemocracy8.
  ///
  /// In ja, this message translates to:
  /// **'世界各地で「エリートへの怒り」が高まっている。その根本原因は何か？'**
  String get themeSocDemocracy8;

  /// No description provided for @themeSocDemocracy9.
  ///
  /// In ja, this message translates to:
  /// **'先進国が「民主主義を広める」と言うとき、それは本当に善意か？'**
  String get themeSocDemocracy9;

  /// No description provided for @themeSocDemocracy10.
  ///
  /// In ja, this message translates to:
  /// **'「社会の分断」を一番深めているのは何か？メディア？政治家？アルゴリズム？'**
  String get themeSocDemocracy10;

  /// No description provided for @themeSocJapanDecline1.
  ///
  /// In ja, this message translates to:
  /// **'人口が今の半分になる社会で、あなたの仕事は存在しているか？'**
  String get themeSocJapanDecline1;

  /// No description provided for @themeSocJapanDecline2.
  ///
  /// In ja, this message translates to:
  /// **'少子化対策として「最も効果が高い」施策は何だと思うか？'**
  String get themeSocJapanDecline2;

  /// No description provided for @themeSocJapanDecline3.
  ///
  /// In ja, this message translates to:
  /// **'人口減少を「問題」ではなく「チャンス」と捉えるとしたら、何が見えてくるか？'**
  String get themeSocJapanDecline3;

  /// No description provided for @themeSocJapanDecline4.
  ///
  /// In ja, this message translates to:
  /// **'高齢者の医療費を現役世代が支え続ける仕組みは、持続可能か？'**
  String get themeSocJapanDecline4;

  /// No description provided for @themeSocJapanDecline5.
  ///
  /// In ja, this message translates to:
  /// **'定年を80歳に引き上げることに、賛成か反対か？'**
  String get themeSocJapanDecline5;

  /// No description provided for @themeSocJapanDecline6.
  ///
  /// In ja, this message translates to:
  /// **'子どもを産まない選択をする人を、社会はどう扱うべきか？'**
  String get themeSocJapanDecline6;

  /// No description provided for @themeSocJapanDecline7.
  ///
  /// In ja, this message translates to:
  /// **'「子どもを産んだ人が得をする税制」は公平か？不公平か？'**
  String get themeSocJapanDecline7;

  /// No description provided for @themeSocJapanDecline8.
  ///
  /// In ja, this message translates to:
  /// **'介護ロボットが普及しても、家族が介護すべき場面はあるか？'**
  String get themeSocJapanDecline8;

  /// No description provided for @themeSocJapanDecline9.
  ///
  /// In ja, this message translates to:
  /// **'2026年は丙午。迷信が出生数に影響する社会をどう思うか？'**
  String get themeSocJapanDecline9;

  /// No description provided for @themeSocJapanDecline10.
  ///
  /// In ja, this message translates to:
  /// **'あなたが80歳になったとき、どんな社会に生きていたいか？'**
  String get themeSocJapanDecline10;

  /// No description provided for @themeSocJapanImmigration1.
  ///
  /// In ja, this message translates to:
  /// **'人手不足を外国人労働者で補うことへの、あなたのリアルな本音は？'**
  String get themeSocJapanImmigration1;

  /// No description provided for @themeSocJapanImmigration2.
  ///
  /// In ja, this message translates to:
  /// **'日本語が話せない子どもへの教育コストは、誰が負うべきか？'**
  String get themeSocJapanImmigration2;

  /// No description provided for @themeSocJapanImmigration3.
  ///
  /// In ja, this message translates to:
  /// **'高度人材の外国人が日本を選ばない理由は何か？どうすれば変わるか？'**
  String get themeSocJapanImmigration3;

  /// No description provided for @themeSocJapanImmigration4.
  ///
  /// In ja, this message translates to:
  /// **'「移民を受け入れるべき」と言いながら、自分の隣人には嫌だと感じるのはなぜか？'**
  String get themeSocJapanImmigration4;

  /// No description provided for @themeSocJapanImmigration5.
  ///
  /// In ja, this message translates to:
  /// **'少子化対策として移民を増やすことは、文化的アイデンティティを変えるか？'**
  String get themeSocJapanImmigration5;

  /// No description provided for @themeSocJapanImmigration6.
  ///
  /// In ja, this message translates to:
  /// **'「日本人らしさ」とは何か？それは守るべきものか、変わっていいものか？'**
  String get themeSocJapanImmigration6;

  /// No description provided for @themeSocJapanImmigration7.
  ///
  /// In ja, this message translates to:
  /// **'外国人が多い職場で、チームとしてまとまるために何が必要か？'**
  String get themeSocJapanImmigration7;

  /// No description provided for @themeSocJapanImmigration8.
  ///
  /// In ja, this message translates to:
  /// **'欧米で外国人問題が国家分断につながっている。日本は同じ道をたどるか？'**
  String get themeSocJapanImmigration8;

  /// No description provided for @themeSocJapanImmigration9.
  ///
  /// In ja, this message translates to:
  /// **'外国人の土地取得を制限することに、賛成か反対か？'**
  String get themeSocJapanImmigration9;

  /// No description provided for @themeSocJapanImmigration10.
  ///
  /// In ja, this message translates to:
  /// **'50年後の日本が多民族国家になっていたとしたら、それはよいことか？'**
  String get themeSocJapanImmigration10;

  /// No description provided for @themeSocJapanWork1.
  ///
  /// In ja, this message translates to:
  /// **'週4日勤務が標準になったとき、会社と個人はそれぞれ何を変える必要があるか？'**
  String get themeSocJapanWork1;

  /// No description provided for @themeSocJapanWork2.
  ///
  /// In ja, this message translates to:
  /// **'新卒一括採用・終身雇用は、今の時代に合っているか？'**
  String get themeSocJapanWork2;

  /// No description provided for @themeSocJapanWork3.
  ///
  /// In ja, this message translates to:
  /// **'成果が同じなら、働く時間が短い人と長い人の評価は同じにすべきか？'**
  String get themeSocJapanWork3;

  /// No description provided for @themeSocJapanWork4.
  ///
  /// In ja, this message translates to:
  /// **'副業を全員に解禁すると、組織への忠誠心は下がるか？'**
  String get themeSocJapanWork4;

  /// No description provided for @themeSocJapanWork5.
  ///
  /// In ja, this message translates to:
  /// **'「やりがい搾取」はなぜなくならないのか？誰が変えるべきか？'**
  String get themeSocJapanWork5;

  /// No description provided for @themeSocJapanWork6.
  ///
  /// In ja, this message translates to:
  /// **'上司が部下より給与が低い逆転現象は、問題か？健全か？'**
  String get themeSocJapanWork6;

  /// No description provided for @themeSocJapanWork7.
  ///
  /// In ja, this message translates to:
  /// **'燃え尽き症候群（バーンアウト）を防ぐ責任は、個人か？会社か？'**
  String get themeSocJapanWork7;

  /// No description provided for @themeSocJapanWork8.
  ///
  /// In ja, this message translates to:
  /// **'テレワークと出社、チームにとって本当にいいのはどちらか？'**
  String get themeSocJapanWork8;

  /// No description provided for @themeSocJapanWork9.
  ///
  /// In ja, this message translates to:
  /// **'「会社の飲み会」は業務か？プライベートか？'**
  String get themeSocJapanWork9;

  /// No description provided for @themeSocJapanWork10.
  ///
  /// In ja, this message translates to:
  /// **'10年後、「会社員」という働き方は主流であり続けるか？'**
  String get themeSocJapanWork10;

  /// No description provided for @themeSocJapanLocal1.
  ///
  /// In ja, this message translates to:
  /// **'バスも電車もなくなった地方に、住み続ける権利を社会は保障すべきか？'**
  String get themeSocJapanLocal1;

  /// No description provided for @themeSocJapanLocal2.
  ///
  /// In ja, this message translates to:
  /// **'廃校になった学校の跡地を、何に使うべきか？'**
  String get themeSocJapanLocal2;

  /// No description provided for @themeSocJapanLocal3.
  ///
  /// In ja, this message translates to:
  /// **'リモートワークは地方創生の救世主になれるか？それとも幻想か？'**
  String get themeSocJapanLocal3;

  /// No description provided for @themeSocJapanLocal4.
  ///
  /// In ja, this message translates to:
  /// **'人口が100人を切った村に、公共サービスを提供し続けるべきか？'**
  String get themeSocJapanLocal4;

  /// No description provided for @themeSocJapanLocal5.
  ///
  /// In ja, this message translates to:
  /// **'老朽化したインフラを維持するために増税することに、賛成か反対か？'**
  String get themeSocJapanLocal5;

  /// No description provided for @themeSocJapanLocal6.
  ///
  /// In ja, this message translates to:
  /// **'都市への人口集中は「問題」か？それとも「効率的な選択」か？'**
  String get themeSocJapanLocal6;

  /// No description provided for @themeSocJapanLocal7.
  ///
  /// In ja, this message translates to:
  /// **'地方に本社機能を移転した企業は、本当に成功できるか？'**
  String get themeSocJapanLocal7;

  /// No description provided for @themeSocJapanLocal8.
  ///
  /// In ja, this message translates to:
  /// **'「消滅可能性都市」というレッテルを貼ることは、地方にとってプラスかマイナスか？'**
  String get themeSocJapanLocal8;

  /// No description provided for @themeSocJapanLocal9.
  ///
  /// In ja, this message translates to:
  /// **'あなたが地方移住を決断するとしたら、最低限必要な条件は何か？'**
  String get themeSocJapanLocal9;

  /// No description provided for @themeSocJapanLocal10.
  ///
  /// In ja, this message translates to:
  /// **'地方の問題を解決する責任は、国・自治体・企業・個人のどこにあるか？'**
  String get themeSocJapanLocal10;

  /// No description provided for @valuePlayerTurn.
  ///
  /// In ja, this message translates to:
  /// **'{displayName}の番'**
  String valuePlayerTurn(String displayName);

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
  /// **'{displayName}が残した5枚'**
  String valuePlayerFinalCards(String displayName);

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

  /// 最後のプレイヤー共有後のボタン（押すとセッション設定に戻る）
  ///
  /// In ja, this message translates to:
  /// **'お疲れ様でした、セッションに戻る'**
  String get valueSessionCompleteAndBack;

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

  /// No description provided for @valueTutorialTooltip.
  ///
  /// In ja, this message translates to:
  /// **'チュートリアル'**
  String get valueTutorialTooltip;

  /// No description provided for @valueTutorialPage1Title.
  ///
  /// In ja, this message translates to:
  /// **'参加人数を選んでスタート'**
  String get valueTutorialPage1Title;

  /// No description provided for @valueTutorialPage1Body.
  ///
  /// In ja, this message translates to:
  /// **'2〜10人で遊べます。人数やタイマー設定をしてプレイを始めましょう。'**
  String get valueTutorialPage1Body;

  /// No description provided for @valueTutorialPage2Title.
  ///
  /// In ja, this message translates to:
  /// **'価値観カードでは1枚捨てて、5枚をランキング'**
  String get valueTutorialPage2Title;

  /// No description provided for @valueTutorialPage2Body.
  ///
  /// In ja, this message translates to:
  /// **'各ラウンドで1枚引きます。6枚になったら価値観から遠いカードを1枚捨て、残り5枚を重要度順に並べて確定します。'**
  String get valueTutorialPage2Body;

  /// No description provided for @valueTutorialPage3Title.
  ///
  /// In ja, this message translates to:
  /// **'5ラウンドで残り5枚を共有'**
  String get valueTutorialPage3Title;

  /// No description provided for @valueTutorialPage3Body.
  ///
  /// In ja, this message translates to:
  /// **'5ラウンド終えると、それぞれ残り5枚のカードが残ります。参加者に見せて、なぜそのカードを残したか共有しましょう。'**
  String get valueTutorialPage3Body;

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
