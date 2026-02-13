// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Talk Seed';

  @override
  String get settings => '設定';

  @override
  String get save => '保存';

  @override
  String get backToSettings => '設定に戻る';

  @override
  String get rollDice => 'サイコロを振る';

  @override
  String get complete => '完了';

  @override
  String get rollNow => 'すぐ振る';

  @override
  String get playWithOthers => 'みんなで遊ぶ';

  @override
  String get playWithDice => 'サイコロで遊ぶ';

  @override
  String get playWithCards => 'カードで遊ぶ';

  @override
  String get alwaysOpenWithDice => '起動時にサイコロで開く';

  @override
  String get alwaysOpenWithCards => '起動時にカードで開く';

  @override
  String get startupDefaultSection => '次回起動時';

  @override
  String get selectThemePrompt => 'サイコロをタップして\nテーマを選ぼう！';

  @override
  String get selectThemePromptCard => '下のボタンで1枚引こう';

  @override
  String faceLabel(int faceNumber) {
    return '面$faceNumber';
  }

  @override
  String get themeInputHint => 'テーマを入力またはドラッグ';

  @override
  String get dropHere => 'ここにドロップ';

  @override
  String get randomSet => 'ランダムにセット';

  @override
  String get reset => 'リセット';

  @override
  String get faceThemesList => '各面の表示';

  @override
  String get themeCandidates => 'テーマ候補';

  @override
  String get dragAndDropHint => '左のテキストボックスにドラッグ＆ドロップ';

  @override
  String get tutorialWelcome => 'Talk Seedへようこそ！';

  @override
  String get tutorialWelcomeBody =>
      'サイコロでテーマを選んだり、カードで問いを引いて話を深めたり。\n\nみんなで盛り上がることも、仕事の場（チーム・会議・1on1）でも使えます。';

  @override
  String get tutorialSetTheme => 'テーマを設定しよう';

  @override
  String get tutorialSetThemeBody =>
      '「みんなで盛り上がる」で選ぶサイコロの、各面に表示するテーマを設定します。\n\n右側の候補からドラッグ＆ドロップするか、直接入力してください。';

  @override
  String get tutorialRollDice => 'サイコロを振る';

  @override
  String get tutorialRollDiceBody =>
      '設定が完了したら「サイコロを振る」ボタンを押してください。\n\n3Dアニメーションでサイコロが転がり、\nランダムなテーマが選ばれます。';

  @override
  String get tutorialCards => 'カードで遊ぶ';

  @override
  String get tutorialCardsBody =>
      '「仕事で盛り上がる」では3種類のカードデッキが選べます。\n\nチームビルディング（価値観共有）、チェックイン・チェックアウト（会議の開始・終了）、自己内省・1on1（軽さ×深さの問い）です。';

  @override
  String get tutorialChangeSettings => '設定を変更する';

  @override
  String get tutorialChangeSettingsBody =>
      'いつでも設定画面からサイコロのテーマを変更できます。\n\n右上の設定アイコンからアクセスできます。';

  @override
  String get tutorialReady => '準備完了！';

  @override
  String get tutorialReadyBody =>
      'それでは、はじめましょう。\n\nサイコロでテーマを選んでも、カードで問いを引いてもOK。場に合わせて使ってください。';

  @override
  String get skip => 'スキップ';

  @override
  String get start => '始める';

  @override
  String get showTutorial => 'チュートリアルを表示';

  @override
  String get themeCube => 'テーマ';

  @override
  String get yourThemes => 'あなたのテーマ';

  @override
  String get useVariantsToChooseTheme => '候補をドラッグで選択';

  @override
  String get themeSurprised => 'びっくりしたこと';

  @override
  String get themeFutureDream => '将来の夢';

  @override
  String get themeLoveStory => '恋の話';

  @override
  String get themeRecommendedBook => 'おすすめの本';

  @override
  String get themeRecentHobby => '最近ハマっていること';

  @override
  String get themeDislike => '嫌いなこと';

  @override
  String get themeFavoriteMovie => '好きな映画';

  @override
  String get themeTreasure => '大切にしていること';

  @override
  String get themeCried => '泣いたこと';

  @override
  String get themeLaughed => '笑ったこと';

  @override
  String get themeMoved => '感動したこと';

  @override
  String get themeRegret => '後悔していること';

  @override
  String get themeProud => '誇らしいこと';

  @override
  String get themeEmbarrassed => '恥ずかしかったこと';

  @override
  String get themeFavoriteMusic => '好きな音楽';

  @override
  String get themeFavoriteAnime => '好きなアニメ';

  @override
  String get themeFavoriteGame => '好きなゲーム';

  @override
  String get themeFavoriteFood => '好きな食べ物';

  @override
  String get themeWantToVisit => '行きたい場所';

  @override
  String get themeFavoriteSport => '好きなスポーツ';

  @override
  String get themeFriendMemory => '友達との思い出';

  @override
  String get themeFamilyMemory => '家族との思い出';

  @override
  String get themeGrateful => '感謝していること';

  @override
  String get themeSupporting => '応援している人';

  @override
  String get themeWantToDo => 'やってみたいこと';

  @override
  String get themeWantToAchieve => '実現したいこと';

  @override
  String get themeDreamJob => 'なりたい職業';

  @override
  String get themeWantToVisitCountry => '行ってみたい国';

  @override
  String get themeRecentEvent => '最近の出来事';

  @override
  String get themeTodayEvent => '今日の出来事';

  @override
  String get themeWeekendPlan => '週末の予定';

  @override
  String get themeRelaxMethod => 'リラックス方法';

  @override
  String get themeStressRelief => 'ストレス解消法';

  @override
  String get themeMorningRoutine => '朝のルーティン';

  @override
  String get themeFavoriteWord => '好きな言葉';

  @override
  String get themeMotto => '座右の銘';

  @override
  String get themeImportantThing => '大切なもの';

  @override
  String get themeBelief => '信じていること';

  @override
  String get themeLifeLesson => '人生で学んだこと';

  @override
  String get themeRecentWorry => '最近の悩み';

  @override
  String get themeProudOf => '自慢できること';

  @override
  String get themeUniqueSkill => '変わった特技';

  @override
  String get themeSecret => '秘密にしていること';

  @override
  String get themeChildhoodMemory => '子供の頃の思い出';

  @override
  String get sessionSetup => 'セッション設定';

  @override
  String get playModeLabel => '遊び方';

  @override
  String get playModeDice => 'サイコロで';

  @override
  String get playModeTopicCard => 'トピックカードで';

  @override
  String get drawTopic => 'トピックを引く';

  @override
  String get phaseCheckIn => '会議前';

  @override
  String get phaseCheckOut => '会議後';

  @override
  String get checkInPickOnePrompt => 'この中から1問選んでください';

  @override
  String get reselectQuestion => '選び直す';

  @override
  String get chosenCardLabelBefore => '会議前に選んだ問い';

  @override
  String get chosenCardLabelAfter => '会議後に選んだ問い';

  @override
  String get playerCount => '参加人数';

  @override
  String get timerSettings => 'タイマー設定';

  @override
  String get enableTimer => 'タイマーを有効にする';

  @override
  String get timerDuration => '時間';

  @override
  String playerName(int number) {
    return 'プレイヤー$number';
  }

  @override
  String get startSession => 'セッション開始';

  @override
  String currentPlayer(int current, int total) {
    return 'プレイヤー $current/$total の番';
  }

  @override
  String get nextPlayer => '次のプレイヤー';

  @override
  String get endSession => 'セッション終了';

  @override
  String get sessionSummary => 'セッション終了';

  @override
  String get sessionCompleteMessage => '全員の番が終わりました。';

  @override
  String round(int number) {
    return 'ラウンド $number';
  }

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get share => '共有';

  @override
  String get newSession => '新しいセッション';

  @override
  String get goToSessionSetup => 'セッション設定へ';

  @override
  String get backToThemeSettings => 'テーマ設定に戻る';

  @override
  String get timer30Seconds => '30秒';

  @override
  String get timer1Minute => '1分';

  @override
  String get timer2Minutes => '2分';

  @override
  String get timer3Minutes => '3分';

  @override
  String get timer5Minutes => '5分';

  @override
  String get timerUnlimited => '無制限';

  @override
  String get playerNamesOptional => 'プレイヤー名（オプション）';

  @override
  String get playerNamesHint => '入力するとセッション中に表示。空欄は番号で表示されます。';

  @override
  String get sessionPreviewTitle => 'このセッション';

  @override
  String sessionPreviewPlayers(int count) {
    return '$count人でプレイ';
  }

  @override
  String sessionPreviewTimer(String timer) {
    return '制限時間：$timer';
  }

  @override
  String get sessionPreviewNoTimer => 'タイマーなし';

  @override
  String get modeSelectionTitle => '遊び方を選んでください';

  @override
  String get homeSectionEveryone => 'みんなで盛り上がる';

  @override
  String get homeSectionWork => '仕事で盛り上がる';

  @override
  String get homeDiceLabel => 'サイコロ';

  @override
  String get backToModeSelection => 'モードを選び直す';

  @override
  String get cardSettingsTitle => 'カードを選ぶ';

  @override
  String get selectDeckPrompt => 'デッキを選んでください';

  @override
  String get playWithDeck => 'このデッキで遊ぶ';

  @override
  String get deckTeamBuilding => 'チームビルディング';

  @override
  String get deckTeamBuildingDesc => '価値観を共有し、チームの理解を深める';

  @override
  String get deckCheckIn => 'チェックイン・チェックアウト';

  @override
  String get deckCheckInDesc => '会議の開始・終了に。問いを元に全員が一言ずつ';

  @override
  String get deckSelfReflection => '自己内省・1on1';

  @override
  String get deckSelfReflectionDesc => '軽さ×深さの問い。1人で内省も、1on1でも';

  @override
  String get deckOneOnOne => '成長対話';

  @override
  String get deckOneOnOneDesc => '1on1で。評価を抜きに、未来・詰まり・伸ばしたいことを話す';

  @override
  String get deckRetrospective => '振り返り';

  @override
  String get deckRetrospectiveDesc => 'チームで。良かった点・改善点・学びを振り返る';

  @override
  String get deckIceBreaker => 'アイスブレイク';

  @override
  String get deckIceBreakerDesc => '場あたために。雰囲気を和らげる軽い話題';

  @override
  String get themeTrust => '信頼関係を大切にする';

  @override
  String get themeChallenge => '挑戦を恐れない';

  @override
  String get themeGratitude => '感謝を伝えることを大切にする';

  @override
  String get themeFeedback => 'フィードバックを歓迎する';

  @override
  String get themeFlexibility => '柔軟に対応する';

  @override
  String get themeResponsibility => '責任を持ってやり遂げる';

  @override
  String get themeGrowth => '成長し続けたい';

  @override
  String get themeWorkLifeBalance => 'ワークライフバランスを重視する';

  @override
  String get themeCollaboration => '協力して成し遂げる';

  @override
  String get themeTransparency => 'オープンに情報を共有する';

  @override
  String get themeWeeklyHighlight => '今週のハイライト';

  @override
  String get themeTodayGoal => '今日の目標';

  @override
  String get themeBlocker => '困っていること';

  @override
  String get themeCurrentMood => '今の気持ち';

  @override
  String get themeOneWord => '今日の一言';

  @override
  String get themeWellDone => 'うまくいったこと';

  @override
  String get themeStruggle => '苦戦していること';

  @override
  String get themeWantToGrow => '成長したいこと';

  @override
  String get themeFeedbackWant => 'フィードバックがほしいこと';

  @override
  String get themeGoodPoint => '良かった点';

  @override
  String get themeImprovePoint => '改善したい点';

  @override
  String get themeLearnings => '学んだこと';

  @override
  String get themeNextAction => '次にやること';

  @override
  String get themeThanks => '感謝したいこと';

  @override
  String get themeHonesty => '誠実であることを重んじる';

  @override
  String get themeInnovation => '新しいやり方を試す';

  @override
  String get themeStability => '安定を大切にする';

  @override
  String get themeAutonomy => '自分の裁量で決めたい';

  @override
  String get themeCommunity => '仲間やチームを大切にする';

  @override
  String get themeQuality => '質を最優先する';

  @override
  String get themeSpeed => 'スピードを重視する';

  @override
  String get themeCustomerFirst => 'お客様第一で考える';

  @override
  String get themeLearning => '学び続けることを大切にする';

  @override
  String get themeBalance => 'バランスを取ることを心がける';

  @override
  String get themeCreativity => '創造性を大切にする';

  @override
  String get themeEmpathy => '相手の気持ちに寄り添う';

  @override
  String get themeConsistency => '一貫性を保つ';

  @override
  String get themeRespect => '多様性を尊重する';

  @override
  String get themeValuePriority => '大切なことを優先する';

  @override
  String get themeValueIntegrity => '信じていることに従って行動する';

  @override
  String valuePlayerTurn(int player) {
    return 'プレイヤー$playerの番';
  }

  @override
  String get valueDiscardPrompt => '自分の価値観から最も遠いカードをタップして捨ててください';

  @override
  String get valueRankPrompt => '6枚を重要度順に並べてください（上＝大切、下＝手放す）';

  @override
  String get valueConfirmRanking => '確定して手放す';

  @override
  String get valueDiscardLabel => '手放す';

  @override
  String valuePlayerFinalCards(int player) {
    return 'プレイヤー$playerが残した5枚';
  }

  @override
  String get valueNext => '次へ';

  @override
  String get valueGameComplete => 'お疲れさまでした';

  @override
  String get valueSharePrompt => '残った5枚のカードを参加者に見せ、共有しましょう';

  @override
  String get valuePlayerCount => '参加人数';

  @override
  String get valueStart => 'スタート';

  @override
  String get valueBackToDeck => 'デッキ選択に戻る';

  @override
  String get valueDrawCard => '山札から1枚引く';

  @override
  String valueRound(int current) {
    return '$current/5 ラウンド';
  }

  @override
  String get errorDataLoadTitle => 'データの読み込みに失敗しました';

  @override
  String get errorDataLoadMessage => '問いのデータを読み込めませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get retry => '再試行';

  @override
  String get dismiss => '閉じる';
}
