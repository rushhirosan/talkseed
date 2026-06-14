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
  /// **'Talk Shuffleへようこそ'**
  String get tutorialWelcome;

  /// チュートリアル1ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'仕事やチームの場で、話題のきっかけをランダムに。サイコロやカードで、自然に会話が始まります。'**
  String get tutorialWelcomeBody;

  /// チュートリアル2ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'サイコロを振る'**
  String get tutorialRollDice;

  /// チュートリアル2ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'「サイコロを振る」を押すとサイコロが転がり、ランダムなテーマが選ばれます。'**
  String get tutorialRollDiceBody;

  /// チュートリアル3ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'価値観を知る'**
  String get tutorialValues;

  /// チュートリアル3ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'価値観カードで、自分が大切にしていることを並べ替えて共有。チームの相互理解に役立ちます。'**
  String get tutorialValuesBody;

  /// チュートリアル4ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'グループディスカッション'**
  String get tutorialGroupDiscussion;

  /// チュートリアル4ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'カテゴリーからお題を選び、全員で1つのテーマについて話し合います。タイマー付きで進行できます。'**
  String get tutorialGroupDiscussionBody;

  /// チュートリアル5ページ目のタイトル
  ///
  /// In ja, this message translates to:
  /// **'プレイヤー選択や履歴保存'**
  String get tutorialPlayersHistory;

  /// チュートリアル5ページ目の本文
  ///
  /// In ja, this message translates to:
  /// **'参加人数や名前、タイマーを設定できます。セッション後は履歴に保存され、あとから振り返れます。'**
  String get tutorialPlayersHistoryBody;

  /// チュートリアル最終ページのタイトル
  ///
  /// In ja, this message translates to:
  /// **'準備完了'**
  String get tutorialReady;

  /// チュートリアル最終ページの本文
  ///
  /// In ja, this message translates to:
  /// **'モードを選んで、さっそく始めましょう。場に合わせてサイコロ・価値観カード・グループディスカッションを使い分けられます。'**
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

  /// テーマ候補エリアの説明文（Web・広い画面）
  ///
  /// In ja, this message translates to:
  /// **'画面左にドラッグ'**
  String get useVariantsToChooseTheme;

  /// テーマ候補エリアの説明文（モバイル）
  ///
  /// In ja, this message translates to:
  /// **'入れ替えたいテーマをタップ → 下の候補をタップ'**
  String get themeTapToReplaceHint;

  /// モバイルでテーマ面を手入力するヒント
  ///
  /// In ja, this message translates to:
  /// **'長押しで自分で入力'**
  String get themeLongPressToEdit;

  /// 候補タップ時に面が未選択のとき
  ///
  /// In ja, this message translates to:
  /// **'先に入れ替えたいテーマをタップしてください'**
  String get themeSelectFaceFirst;

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

  /// セッション終了ダイアログの本文（全モード共通）
  ///
  /// In ja, this message translates to:
  /// **'セッションが終了しました。内容は履歴に保存しました。'**
  String get sessionCompleteAcknowledgeMessage;

  /// セッション終了ダイアログでトップへ戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get sessionCompleteEndButton;

  /// 終了ダイアログを閉じるだけのボタン（非推奨・互換用）
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get sessionCompleteAcknowledgeButton;

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

  /// 履歴詳細の参加者セクション見出し
  ///
  /// In ja, this message translates to:
  /// **'参加者'**
  String get historyPlayersTitle;

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

  /// 履歴詳細・議論モードでプレイヤー別のお題を表示
  ///
  /// In ja, this message translates to:
  /// **'プレイヤーごとのお題'**
  String get historyDiscussionPromptsTitle;

  /// 履歴詳細・議論モードのプレイヤー別リストの注記
  ///
  /// In ja, this message translates to:
  /// **'上から表示された順です。「別のお題へ」で差し替えたときは、そのたびに行が増えます。'**
  String get historyDiscussionPromptsFootnote;

  /// 履歴用のモード表示（ランダム／トップ画面に合わせる）
  ///
  /// In ja, this message translates to:
  /// **'ランダム'**
  String get historyModeDice;

  /// 履歴用のモード表示（価値観／トップ画面に合わせる）
  ///
  /// In ja, this message translates to:
  /// **'価値観'**
  String get historyModeValueCards;

  /// 履歴フィルタ（全て）
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get historyFilterAll;

  /// 履歴フィルタ（ランダム／トップ画面に合わせる）
  ///
  /// In ja, this message translates to:
  /// **'ランダム'**
  String get historyFilterDice;

  /// 履歴フィルタ（価値観／トップ画面に合わせる）
  ///
  /// In ja, this message translates to:
  /// **'価値観'**
  String get historyFilterValueCards;

  /// No description provided for @historyModeDiscussion.
  ///
  /// In ja, this message translates to:
  /// **'グループ'**
  String get historyModeDiscussion;

  /// No description provided for @historyFilterDiscussion.
  ///
  /// In ja, this message translates to:
  /// **'グループ'**
  String get historyFilterDiscussion;

  /// No description provided for @historyModeOneOnOne.
  ///
  /// In ja, this message translates to:
  /// **'1on1'**
  String get historyModeOneOnOne;

  /// No description provided for @historyFilterOneOnOne.
  ///
  /// In ja, this message translates to:
  /// **'1on1'**
  String get historyFilterOneOnOne;

  /// No description provided for @historyOneOnOnePromptsTitle.
  ///
  /// In ja, this message translates to:
  /// **'話した問い'**
  String get historyOneOnOnePromptsTitle;

  /// No description provided for @historyOneOnOneSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{count}フェーズ'**
  String historyOneOnOneSubtitle(int count);

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

  /// 案B：統合デッキ（問題解決＋社会課題）のショートラベル
  ///
  /// In ja, this message translates to:
  /// **'グループディスカッション'**
  String get homeThemeShortGroupDiscussion;

  /// No description provided for @homeThemeShortValues.
  ///
  /// In ja, this message translates to:
  /// **'価値観を知る'**
  String get homeThemeShortValues;

  /// トップ画面の小見出し（英字風ラベル）
  ///
  /// In ja, this message translates to:
  /// **'テーマセレクター'**
  String get homeCardLabel;

  /// トップ画面メイン見出し1行目
  ///
  /// In ja, this message translates to:
  /// **'テーマを'**
  String get homeThemeTitleLine1;

  /// トップ画面メイン見出し（グラデーション部分）
  ///
  /// In ja, this message translates to:
  /// **'選ぼう'**
  String get homeThemeTitleAccent;

  /// 価値観テーマカードの説明
  ///
  /// In ja, this message translates to:
  /// **'人生・優先事項・信念について'**
  String get homeThemeDescValues;

  /// グループディスカッションテーマカードの説明
  ///
  /// In ja, this message translates to:
  /// **'チームで深掘りするトピック'**
  String get homeThemeDescGroupDiscussion;

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

  /// 問題解決系と社会課題を統合したデッキ名
  ///
  /// In ja, this message translates to:
  /// **'グループディスカッション'**
  String get deckGroupDiscussion;

  /// No description provided for @deckGroupDiscussionDesc.
  ///
  /// In ja, this message translates to:
  /// **'論理・創造・推定・倫理、地政学・AI・気候・民主主義、人口・移民・働き方・地域など、みんなで話すお題'**
  String get deckGroupDiscussionDesc;

  /// No description provided for @discussionScreenTitle.
  ///
  /// In ja, this message translates to:
  /// **'議論モード'**
  String get discussionScreenTitle;

  /// No description provided for @discussionHint.
  ///
  /// In ja, this message translates to:
  /// **'裏向きのカードをタップすると選べます（もう一度タップで外せます）。緑の数字が選んだ順番です。横にスクロールして候補を見られます。'**
  String get discussionHint;

  /// No description provided for @discussionPickTopicsInstruction.
  ///
  /// In ja, this message translates to:
  /// **'このセッションで話すお題を {n} 枚選んでください。'**
  String discussionPickTopicsInstruction(int n);

  /// No description provided for @discussionSelectionProgress.
  ///
  /// In ja, this message translates to:
  /// **'選んだお題 {selected} / {target} 枚'**
  String discussionSelectionProgress(int selected, int target);

  /// No description provided for @discussionSnackbarSelectionCap.
  ///
  /// In ja, this message translates to:
  /// **'選べるのはこのセッションで最大 {n} 枚までです。'**
  String discussionSnackbarSelectionCap(int n);

  /// No description provided for @discussionSnackbarNeedMoreSelections.
  ///
  /// In ja, this message translates to:
  /// **'あと {n} 枚選んでから進んでください。'**
  String discussionSnackbarNeedMoreSelections(int n);

  /// No description provided for @discussionNextRoundButton.
  ///
  /// In ja, this message translates to:
  /// **'次のお題'**
  String get discussionNextRoundButton;

  /// No description provided for @discussionRoundProgress.
  ///
  /// In ja, this message translates to:
  /// **'お題 {current} / {total}'**
  String discussionRoundProgress(int current, int total);

  /// No description provided for @discussionPickTopicsAllOrSelectHint.
  ///
  /// In ja, this message translates to:
  /// **'ヒント: 何も選ばずに進むと、卓のお題をすべてこの順で話します。'**
  String get discussionPickTopicsAllOrSelectHint;

  /// No description provided for @discussionProceedToDiscussionButton.
  ///
  /// In ja, this message translates to:
  /// **'議論に進む'**
  String get discussionProceedToDiscussionButton;

  /// No description provided for @discussionPerCategoryOption.
  ///
  /// In ja, this message translates to:
  /// **'{n}枚ずつ'**
  String discussionPerCategoryOption(int n);

  /// No description provided for @discussionPreviewPerCategory.
  ///
  /// In ja, this message translates to:
  /// **'各カテゴリー最大{perCat}枚まで · プールは最大{total}枚'**
  String discussionPreviewPerCategory(int perCat, int total);

  /// No description provided for @discussionPreviewNeedCategorySelection.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリーを1つ以上選ぶと、ここに枚数の目安が表示されます'**
  String get discussionPreviewNeedCategorySelection;

  /// No description provided for @discussionSelectAtLeastOneCategory.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリーを1つ以上選んでください'**
  String get discussionSelectAtLeastOneCategory;

  /// No description provided for @discussionTableSummary.
  ///
  /// In ja, this message translates to:
  /// **'各カテゴリー最大{perCat}枚 · 卓{total}枚'**
  String discussionTableSummary(int perCat, int total);

  /// No description provided for @discussionTotalCardsOnTable.
  ///
  /// In ja, this message translates to:
  /// **'お題 {n} 枚'**
  String discussionTotalCardsOnTable(int n);

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

  /// No description provided for @discussionDeckScopeTitle.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリーごとのお題（上限）'**
  String get discussionDeckScopeTitle;

  /// No description provided for @discussionDeckScopeHint.
  ///
  /// In ja, this message translates to:
  /// **'選んだカテゴリーそれぞれから、卓の候補として載せるお題の最大枚数です（お題が足りないカテゴリーはそれ以下になります）。'**
  String get discussionDeckScopeHint;

  /// No description provided for @discussionThemeFilterTitle.
  ///
  /// In ja, this message translates to:
  /// **'テーマを絞る'**
  String get discussionThemeFilterTitle;

  /// No description provided for @discussionThemeFilterHint.
  ///
  /// In ja, this message translates to:
  /// **'卓に出すカテゴリーをオンにしてください（1つ以上）。'**
  String get discussionThemeFilterHint;

  /// No description provided for @discussionThemeFilterSelectAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get discussionThemeFilterSelectAll;

  /// No description provided for @discussionThemeFilterClearAll.
  ///
  /// In ja, this message translates to:
  /// **'解除'**
  String get discussionThemeFilterClearAll;

  /// No description provided for @discussionTotalThemesOnTableTitle.
  ///
  /// In ja, this message translates to:
  /// **'話すお題の数（卓の枚数）'**
  String get discussionTotalThemesOnTableTitle;

  /// No description provided for @discussionTotalThemesOnTableHint.
  ///
  /// In ja, this message translates to:
  /// **'このセッションでは、この枚数ぶんお題について話します。次の画面で卓からその枚数を選んでください（「すべて」のときは未選択のまま進むと卓のお題を順に全部話します）。'**
  String get discussionTotalThemesOnTableHint;

  /// No description provided for @discussionTotalThemesOnTableDropdownDisabled.
  ///
  /// In ja, this message translates to:
  /// **'（上でカテゴリーを選ぶと設定できます）'**
  String get discussionTotalThemesOnTableDropdownDisabled;

  /// No description provided for @discussionTotalThemesOnTableAllOption.
  ///
  /// In ja, this message translates to:
  /// **'すべて（最大{max}枚）'**
  String discussionTotalThemesOnTableAllOption(int max);

  /// No description provided for @discussionTotalThemesOnTableCountOption.
  ///
  /// In ja, this message translates to:
  /// **'{n}枚'**
  String discussionTotalThemesOnTableCountOption(int n);

  /// No description provided for @discussionTotalThemesOnTableEffective.
  ///
  /// In ja, this message translates to:
  /// **'このセッション: {count}枚のお題を話す'**
  String discussionTotalThemesOnTableEffective(int count);

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

  /// No description provided for @discussionGroupKickoffTitle.
  ///
  /// In ja, this message translates to:
  /// **'グループディスカッションを始めよう'**
  String get discussionGroupKickoffTitle;

  /// No description provided for @discussionGroupKickoffLead.
  ///
  /// In ja, this message translates to:
  /// **'全員で {count} 個のお題について話し合います。'**
  String discussionGroupKickoffLead(int count);

  /// No description provided for @discussionGroupTopicsTitle.
  ///
  /// In ja, this message translates to:
  /// **'今回のお題'**
  String get discussionGroupTopicsTitle;

  /// No description provided for @discussionGroupTopicsCount.
  ///
  /// In ja, this message translates to:
  /// **'{count} 個のお題'**
  String discussionGroupTopicsCount(int count);

  /// No description provided for @discussionGroupHint.
  ///
  /// In ja, this message translates to:
  /// **'全員で順番に話したり、自由に深掘りしたりしてOKです。'**
  String get discussionGroupHint;

  /// No description provided for @discussionGroupTopicsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'お題がありません。テーマの絞り込みを見直してください。'**
  String get discussionGroupTopicsEmpty;

  /// No description provided for @discussionGroupReshuffle.
  ///
  /// In ja, this message translates to:
  /// **'お題をシャッフルし直す'**
  String get discussionGroupReshuffle;

  /// 表示中のお題と現在番のプレイヤーを対応づける
  ///
  /// In ja, this message translates to:
  /// **'このお題に話すのは、{turnLabel}。'**
  String promptBelongsToTurn(String turnLabel);

  /// No description provided for @discussionSessionPromptsTitle.
  ///
  /// In ja, this message translates to:
  /// **'このセッションのお題（プレイヤー別）'**
  String get discussionSessionPromptsTitle;

  /// No description provided for @discussionPromptTimelineTitle.
  ///
  /// In ja, this message translates to:
  /// **'お題の記録（時系列）'**
  String get discussionPromptTimelineTitle;

  /// No description provided for @discussionPromptTimelineSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'確定したお題が時系列で並びます。'**
  String get discussionPromptTimelineSubtitle;

  /// No description provided for @discussionTurnNotYet.
  ///
  /// In ja, this message translates to:
  /// **'（このあと）'**
  String get discussionTurnNotYet;

  /// No description provided for @discussionWaitingPick.
  ///
  /// In ja, this message translates to:
  /// **'カードをタップしてお題を選んでください'**
  String get discussionWaitingPick;

  /// No description provided for @discussionPickFromCardsHeading.
  ///
  /// In ja, this message translates to:
  /// **'裏向きのカード（横にスクロール）'**
  String get discussionPickFromCardsHeading;

  /// No description provided for @discussionKickoffTitle.
  ///
  /// In ja, this message translates to:
  /// **'全員のお題がそろいました'**
  String get discussionKickoffTitle;

  /// No description provided for @discussionKickoffSpeakingLead.
  ///
  /// In ja, this message translates to:
  /// **'話す順の目安: {order}。まずは {first} から。一人ずつ短く共有してから、自由に深掘りしましょう。'**
  String discussionKickoffSpeakingLead(String order, String first);

  /// No description provided for @discussionKickoffTimerNote.
  ///
  /// In ja, this message translates to:
  /// **'「{buttonLabel}」を押すと、{duration} からタイマーのカウントがはじまります。'**
  String discussionKickoffTimerNote(String buttonLabel, String duration);

  /// No description provided for @discussionKickoffStartButton.
  ///
  /// In ja, this message translates to:
  /// **'議論を始める'**
  String get discussionKickoffStartButton;

  /// No description provided for @discussionActiveFirstSpeakerCaption.
  ///
  /// In ja, this message translates to:
  /// **'まず話を始める目安'**
  String get discussionActiveFirstSpeakerCaption;

  /// No description provided for @discussionActiveOrderLine.
  ///
  /// In ja, this message translates to:
  /// **'このあとの順番: {order}'**
  String discussionActiveOrderLine(String order);

  /// No description provided for @discussionFirstSpeakerTag.
  ///
  /// In ja, this message translates to:
  /// **'最初'**
  String get discussionFirstSpeakerTag;

  /// No description provided for @discussionDiscussionCardWithTimer.
  ///
  /// In ja, this message translates to:
  /// **'タイマーは目安です。場のお題を軸に、みんなで自由に深掘りしてOKです。'**
  String get discussionDiscussionCardWithTimer;

  /// No description provided for @discussionDiscussionCardNoTimer.
  ///
  /// In ja, this message translates to:
  /// **'場のお題を軸に、みんなで自由に深掘りしてOKです。'**
  String get discussionDiscussionCardNoTimer;

  /// No description provided for @discussionEndDiscussionButton.
  ///
  /// In ja, this message translates to:
  /// **'議論を終了'**
  String get discussionEndDiscussionButton;

  /// No description provided for @discussionConfirmTopic.
  ///
  /// In ja, this message translates to:
  /// **'このお題で話す'**
  String get discussionConfirmTopic;

  /// No description provided for @discussionLockedPick.
  ///
  /// In ja, this message translates to:
  /// **'お題が決まりました。準備ができたら「次のプレイヤー」をタップ'**
  String get discussionLockedPick;

  /// No description provided for @discussionUncategorizedTitle.
  ///
  /// In ja, this message translates to:
  /// **'お題'**
  String get discussionUncategorizedTitle;

  /// No description provided for @discussionCatProbLogical.
  ///
  /// In ja, this message translates to:
  /// **'論理的に組み立てる'**
  String get discussionCatProbLogical;

  /// No description provided for @discussionCatProbCreative.
  ///
  /// In ja, this message translates to:
  /// **'創造的に考える'**
  String get discussionCatProbCreative;

  /// No description provided for @discussionCatProbFermi.
  ///
  /// In ja, this message translates to:
  /// **'フェルミ推定'**
  String get discussionCatProbFermi;

  /// No description provided for @discussionCatProbDilemma.
  ///
  /// In ja, this message translates to:
  /// **'ジレンマ・倫理'**
  String get discussionCatProbDilemma;

  /// No description provided for @discussionCatSocGeo.
  ///
  /// In ja, this message translates to:
  /// **'地理・地政学'**
  String get discussionCatSocGeo;

  /// No description provided for @discussionCatSocAiGap.
  ///
  /// In ja, this message translates to:
  /// **'AI・デジタル格差'**
  String get discussionCatSocAiGap;

  /// No description provided for @discussionCatSocClimate.
  ///
  /// In ja, this message translates to:
  /// **'気候・環境'**
  String get discussionCatSocClimate;

  /// No description provided for @discussionCatSocDemocracy.
  ///
  /// In ja, this message translates to:
  /// **'民主主義・ガバナンス'**
  String get discussionCatSocDemocracy;

  /// No description provided for @discussionCatSocJapanDecline.
  ///
  /// In ja, this message translates to:
  /// **'人口動態・少子化'**
  String get discussionCatSocJapanDecline;

  /// No description provided for @discussionCatSocJapanImmigration.
  ///
  /// In ja, this message translates to:
  /// **'移民・多文化社会'**
  String get discussionCatSocJapanImmigration;

  /// No description provided for @discussionCatSocJapanWork.
  ///
  /// In ja, this message translates to:
  /// **'働き方・雇用・組織'**
  String get discussionCatSocJapanWork;

  /// No description provided for @discussionCatSocJapanLocal.
  ///
  /// In ja, this message translates to:
  /// **'地方・インフラ・コミュニティ'**
  String get discussionCatSocJapanLocal;

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
  /// **'チェックインから締めまで7段。1人の内省も、定例1on1も'**
  String get deckSelfReflectionDesc;

  /// No description provided for @oneOnOnePhaseCheckin.
  ///
  /// In ja, this message translates to:
  /// **'チェックイン'**
  String get oneOnOnePhaseCheckin;

  /// No description provided for @oneOnOnePhaseWorkStatus.
  ///
  /// In ja, this message translates to:
  /// **'業務・進捗'**
  String get oneOnOnePhaseWorkStatus;

  /// No description provided for @oneOnOnePhaseSelfReflection.
  ///
  /// In ja, this message translates to:
  /// **'成長・内省'**
  String get oneOnOnePhaseSelfReflection;

  /// No description provided for @oneOnOnePhaseGrowth.
  ///
  /// In ja, this message translates to:
  /// **'関係性・FB'**
  String get oneOnOnePhaseGrowth;

  /// No description provided for @oneOnOnePhaseCareer.
  ///
  /// In ja, this message translates to:
  /// **'キャリア'**
  String get oneOnOnePhaseCareer;

  /// No description provided for @oneOnOnePhaseMotivation.
  ///
  /// In ja, this message translates to:
  /// **'働き方'**
  String get oneOnOnePhaseMotivation;

  /// No description provided for @oneOnOnePhaseClosing.
  ///
  /// In ja, this message translates to:
  /// **'締め'**
  String get oneOnOnePhaseClosing;

  /// No description provided for @oneOnOnePhaseProgress.
  ///
  /// In ja, this message translates to:
  /// **'フェーズ {current} / {total}'**
  String oneOnOnePhaseProgress(int current, int total);

  /// No description provided for @oneOnOnePhaseHintCheckin.
  ///
  /// In ja, this message translates to:
  /// **'調子と今日話したいことを確認'**
  String get oneOnOnePhaseHintCheckin;

  /// No description provided for @oneOnOnePhaseHintWorkStatus.
  ///
  /// In ja, this message translates to:
  /// **'今週の仕事・進捗・ボトルネック'**
  String get oneOnOnePhaseHintWorkStatus;

  /// No description provided for @oneOnOnePhaseHintSelfReflection.
  ///
  /// In ja, this message translates to:
  /// **'学び・強み・意味を探る'**
  String get oneOnOnePhaseHintSelfReflection;

  /// No description provided for @oneOnOnePhaseHintGrowth.
  ///
  /// In ja, this message translates to:
  /// **'フィードバックとチームの関係性'**
  String get oneOnOnePhaseHintGrowth;

  /// No description provided for @oneOnOnePhaseHintCareer.
  ///
  /// In ja, this message translates to:
  /// **'将来の方向性とキャリアの迷い'**
  String get oneOnOnePhaseHintCareer;

  /// No description provided for @oneOnOnePhaseHintMotivation.
  ///
  /// In ja, this message translates to:
  /// **'モチベーションと働き方の改善'**
  String get oneOnOnePhaseHintMotivation;

  /// No description provided for @oneOnOnePhaseHintClosing.
  ///
  /// In ja, this message translates to:
  /// **'コミットと次回への引き継ぎ'**
  String get oneOnOnePhaseHintClosing;

  /// No description provided for @oneOnOnePickPrompt.
  ///
  /// In ja, this message translates to:
  /// **'このフェーズで話す問いを1つ選んでください'**
  String get oneOnOnePickPrompt;

  /// No description provided for @oneOnOneMoreCandidates.
  ///
  /// In ja, this message translates to:
  /// **'ほかの候補を見る'**
  String get oneOnOneMoreCandidates;

  /// No description provided for @oneOnOneChangeQuestion.
  ///
  /// In ja, this message translates to:
  /// **'選び直す'**
  String get oneOnOneChangeQuestion;

  /// No description provided for @oneOnOneTalkingAbout.
  ///
  /// In ja, this message translates to:
  /// **'この問いで話す'**
  String get oneOnOneTalkingAbout;

  /// No description provided for @oneOnOneAnotherQuestion.
  ///
  /// In ja, this message translates to:
  /// **'別の問い（このフェーズ）'**
  String get oneOnOneAnotherQuestion;

  /// No description provided for @oneOnOneNextPhase.
  ///
  /// In ja, this message translates to:
  /// **'次のフェーズへ'**
  String get oneOnOneNextPhase;

  /// No description provided for @oneOnOnePreviousPhase.
  ///
  /// In ja, this message translates to:
  /// **'前のフェーズへ'**
  String get oneOnOnePreviousPhase;

  /// No description provided for @oneOnOneCompleteSession.
  ///
  /// In ja, this message translates to:
  /// **'1on1を終える'**
  String get oneOnOneCompleteSession;

  /// No description provided for @oneOnOneSessionCompleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'1on1お疲れさまでした'**
  String get oneOnOneSessionCompleteTitle;

  /// No description provided for @oneOnOneSessionCompleteMessage.
  ///
  /// In ja, this message translates to:
  /// **'7つのフェーズを一通り話せました。次回もチェックインから始めましょう。'**
  String get oneOnOneSessionCompleteMessage;

  /// No description provided for @homeThemeShortOneOnOne.
  ///
  /// In ja, this message translates to:
  /// **'1on1'**
  String get homeThemeShortOneOnOne;

  /// No description provided for @homeThemeDescOneOnOne.
  ///
  /// In ja, this message translates to:
  /// **'チェックインから順に。定例1on1の型で進める'**
  String get homeThemeDescOneOnOne;

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
  /// **'あなたの国で、主要都市の大きな駅を1日に利用する人は何人？'**
  String get themeProbFermi1;

  /// No description provided for @themeProbFermi2.
  ///
  /// In ja, this message translates to:
  /// **'あなたの国にあるオフィス用の椅子の総数は？'**
  String get themeProbFermi2;

  /// No description provided for @themeProbFermi3.
  ///
  /// In ja, this message translates to:
  /// **'自社の社員が1年間に書くメールの総文字数は？'**
  String get themeProbFermi3;

  /// No description provided for @themeProbFermi4.
  ///
  /// In ja, this message translates to:
  /// **'あなたの国の首都圏に、信号機はいくつある？'**
  String get themeProbFermi4;

  /// No description provided for @themeProbFermi5.
  ///
  /// In ja, this message translates to:
  /// **'あなたの国で1日に消費されるコーヒーのカップ数は？'**
  String get themeProbFermi5;

  /// No description provided for @themeProbFermi6.
  ///
  /// In ja, this message translates to:
  /// **'あなたの国の小売で1日に廃棄される即食・弁当類は何個？'**
  String get themeProbFermi6;

  /// No description provided for @themeProbFermi7.
  ///
  /// In ja, this message translates to:
  /// **'自社のオフィスで1年間に使われる電力量はどのくらい？'**
  String get themeProbFermi7;

  /// No description provided for @themeProbFermi8.
  ///
  /// In ja, this message translates to:
  /// **'あなたがよく知る大都市で、タクシーの1日の総走行距離は？'**
  String get themeProbFermi8;

  /// No description provided for @themeProbFermi9.
  ///
  /// In ja, this message translates to:
  /// **'あなたの国のスマートフォンのバッテリー容量を合計すると何Wh？'**
  String get themeProbFermi9;

  /// No description provided for @themeProbFermi10.
  ///
  /// In ja, this message translates to:
  /// **'今この瞬間、あなたと同じタイムゾーンで会議をしている人は何人？'**
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
  /// **'大国間の対立が激化したとき、企業は特定の経済圏に寄るべきか、多極でいくべきか？'**
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
  /// **'大規模な地域紛争が長期化すると、グローバルビジネスにどんな影響が続くか？'**
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
  /// **'再生可能エネルギーの供給が少数国に集中しつつある。世界はそれでいいか？'**
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
  /// **'働き世代の人口が一世代で半分になった社会で、あなたの仕事は残ると思うか？'**
  String get themeSocJapanDecline1;

  /// No description provided for @themeSocJapanDecline2.
  ///
  /// In ja, this message translates to:
  /// **'出生率を上げる政策のうち、最も効きそうなものは何か。そもそも政策で上げるべきか？'**
  String get themeSocJapanDecline2;

  /// No description provided for @themeSocJapanDecline3.
  ///
  /// In ja, this message translates to:
  /// **'人口減少を「問題」ではなく「チャンス」と捉えるなら、最初に投資したい分野は？'**
  String get themeSocJapanDecline3;

  /// No description provided for @themeSocJapanDecline4.
  ///
  /// In ja, this message translates to:
  /// **'高齢者医療を現役世代の拠出で支える仕組みは、長期的に持続可能か？'**
  String get themeSocJapanDecline4;

  /// No description provided for @themeSocJapanDecline5.
  ///
  /// In ja, this message translates to:
  /// **'法定退職年齢を80歳に引き上げる案に、賛成か反対か？'**
  String get themeSocJapanDecline5;

  /// No description provided for @themeSocJapanDecline6.
  ///
  /// In ja, this message translates to:
  /// **'子どもを持たない選択をする人を、社会はどう扱うべきか？'**
  String get themeSocJapanDecline6;

  /// No description provided for @themeSocJapanDecline7.
  ///
  /// In ja, this message translates to:
  /// **'子育て支援や税制優遇は、持たない人にとって公平か？'**
  String get themeSocJapanDecline7;

  /// No description provided for @themeSocJapanDecline8.
  ///
  /// In ja, this message translates to:
  /// **'介護ロボットが普及しても、家族が担うべきケアは残るか？'**
  String get themeSocJapanDecline8;

  /// No description provided for @themeSocJapanDecline9.
  ///
  /// In ja, this message translates to:
  /// **'結婚や出産のタイミングに、伝統的な暦や迷信が影響する—無害な文化か、問題か？'**
  String get themeSocJapanDecline9;

  /// No description provided for @themeSocJapanDecline10.
  ///
  /// In ja, this message translates to:
  /// **'あなたが80歳のとき、次の世代のためにどんな社会にしていたいか？'**
  String get themeSocJapanDecline10;

  /// No description provided for @themeSocJapanImmigration1.
  ///
  /// In ja, this message translates to:
  /// **'人手不足を移民労働で補うことへの、メリットと懸念は？'**
  String get themeSocJapanImmigration1;

  /// No description provided for @themeSocJapanImmigration2.
  ///
  /// In ja, this message translates to:
  /// **'公用語が話せない子どもの教育コストは、誰が負担すべきか？'**
  String get themeSocJapanImmigration2;

  /// No description provided for @themeSocJapanImmigration3.
  ///
  /// In ja, this message translates to:
  /// **'高度人材に自国が選ばれない理由は何か。変えるには？'**
  String get themeSocJapanImmigration3;

  /// No description provided for @themeSocJapanImmigration4.
  ///
  /// In ja, this message translates to:
  /// **'「移民は必要」と答えつつ身近には避けたくなる心理は何か？'**
  String get themeSocJapanImmigration4;

  /// No description provided for @themeSocJapanImmigration5.
  ///
  /// In ja, this message translates to:
  /// **'低出生を補うために移民を増やすと、社会のアイデンティティはどう変わるか？'**
  String get themeSocJapanImmigration5;

  /// No description provided for @themeSocJapanImmigration6.
  ///
  /// In ja, this message translates to:
  /// **'「自国らしさ」とは何か。守るべきか、更新していいか？'**
  String get themeSocJapanImmigration6;

  /// No description provided for @themeSocJapanImmigration7.
  ///
  /// In ja, this message translates to:
  /// **'多国籍チームが機能するために、制度や文化で何が必要か？'**
  String get themeSocJapanImmigration7;

  /// No description provided for @themeSocJapanImmigration8.
  ///
  /// In ja, this message translates to:
  /// **'移民をめぐる政治対立が社会を分断する事例から、何を学ぶべきか？'**
  String get themeSocJapanImmigration8;

  /// No description provided for @themeSocJapanImmigration9.
  ///
  /// In ja, this message translates to:
  /// **'外国籍による土地取得を制限することに、賛成か反対か。根拠は？'**
  String get themeSocJapanImmigration9;

  /// No description provided for @themeSocJapanImmigration10.
  ///
  /// In ja, this message translates to:
  /// **'50年後、自国がより多民族化していたとしたら、プラスかリスクか？'**
  String get themeSocJapanImmigration10;

  /// No description provided for @themeSocJapanWork1.
  ///
  /// In ja, this message translates to:
  /// **'週4日労働が標準になったとき、企業と個人はそれぞれ何を変える必要があるか？'**
  String get themeSocJapanWork1;

  /// No description provided for @themeSocJapanWork2.
  ///
  /// In ja, this message translates to:
  /// **'大規模な同期採用と長期雇用を前提にしたモデルは、今も通用するか？'**
  String get themeSocJapanWork2;

  /// No description provided for @themeSocJapanWork3.
  ///
  /// In ja, this message translates to:
  /// **'成果が同じなら、労働時間が短い人と長い人の評価は同じにすべきか？'**
  String get themeSocJapanWork3;

  /// No description provided for @themeSocJapanWork4.
  ///
  /// In ja, this message translates to:
  /// **'副業を全面解禁すると、組織への忠誠や機密管理はどうなるか？'**
  String get themeSocJapanWork4;

  /// No description provided for @themeSocJapanWork5.
  ///
  /// In ja, this message translates to:
  /// **'「やりがい搾取」はなぜなくならないのか。誰が変えるべきか？'**
  String get themeSocJapanWork5;

  /// No description provided for @themeSocJapanWork6.
  ///
  /// In ja, this message translates to:
  /// **'マネージャーがスター社員より給与が低い逆転は、健全か問題か？'**
  String get themeSocJapanWork6;

  /// No description provided for @themeSocJapanWork7.
  ///
  /// In ja, this message translates to:
  /// **'燃え尽きを防ぐ責任は、個人か雇用者か、二者で分担か？'**
  String get themeSocJapanWork7;

  /// No description provided for @themeSocJapanWork8.
  ///
  /// In ja, this message translates to:
  /// **'リモートと出社、協働の質ではどちらが優れているか。誰が決めるべきか？'**
  String get themeSocJapanWork8;

  /// No description provided for @themeSocJapanWork9.
  ///
  /// In ja, this message translates to:
  /// **'同僚との業務外の食事・集まりは、労務か文化か。境界線は？'**
  String get themeSocJapanWork9;

  /// No description provided for @themeSocJapanWork10.
  ///
  /// In ja, this message translates to:
  /// **'10年後も、従来型のフルタイム雇用が主流だと思うか？'**
  String get themeSocJapanWork10;

  /// No description provided for @themeSocJapanLocal1.
  ///
  /// In ja, this message translates to:
  /// **'公共交通が細った地域でも、生活に必要な移動権は保障すべきか？'**
  String get themeSocJapanLocal1;

  /// No description provided for @themeSocJapanLocal2.
  ///
  /// In ja, this message translates to:
  /// **'子どもが減り閉校した施設の跡地に、何を置くべきか？'**
  String get themeSocJapanLocal2;

  /// No description provided for @themeSocJapanLocal3.
  ///
  /// In ja, this message translates to:
  /// **'リモートワークは地方・中小都市の活性化の切り札になり得るか、限界か？'**
  String get themeSocJapanLocal3;

  /// No description provided for @themeSocJapanLocal4.
  ///
  /// In ja, this message translates to:
  /// **'住民が極小規模の集落に、都市部と同等の公共サービスを供給し続けるべきか？'**
  String get themeSocJapanLocal4;

  /// No description provided for @themeSocJapanLocal5.
  ///
  /// In ja, this message translates to:
  /// **'老朽化インフラの安全のための増税に、賛成か反対か？'**
  String get themeSocJapanLocal5;

  /// No description provided for @themeSocJapanLocal6.
  ///
  /// In ja, this message translates to:
  /// **'大都市への人口集中は問題か、効率的な結果か？'**
  String get themeSocJapanLocal6;

  /// No description provided for @themeSocJapanLocal7.
  ///
  /// In ja, this message translates to:
  /// **'本社機能を中小都市や地方へ移す企業が成功するために必要な条件は？'**
  String get themeSocJapanLocal7;

  /// No description provided for @themeSocJapanLocal8.
  ///
  /// In ja, this message translates to:
  /// **'人口減の地域に「衰退・存続リスク」などのラベルを付けることは、プラスかマイナスか？'**
  String get themeSocJapanLocal8;

  /// No description provided for @themeSocJapanLocal9.
  ///
  /// In ja, this message translates to:
  /// **'大都市から地方・中小都市へ移住するなら、最低限ほしい条件は？'**
  String get themeSocJapanLocal9;

  /// No description provided for @themeSocJapanLocal10.
  ///
  /// In ja, this message translates to:
  /// **'地域格差の解消の主責任は、中央政府・地方政府・企業・個人のどこにあるか？'**
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
