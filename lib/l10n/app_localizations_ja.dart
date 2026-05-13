// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Talk Shuffle';

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
  String get playWithOthers => 'セッションへ';

  @override
  String get playWithDice => 'サイコロへ';

  @override
  String get playWithCards => 'カードで遊ぶ';

  @override
  String alwaysOpenWithDice(String randomLabel) {
    return '次回起動も「$randomLabel」と同じ流れで開く';
  }

  @override
  String get alwaysOpenWithDiceHint =>
      'この一覧を開かず、テーマを決める準備画面から始まります（上のボタンと同じ経路）';

  @override
  String get alwaysOpenWithCards => '起動時にカードで開く';

  @override
  String get startupDefaultSection => '次回起動時';

  @override
  String get selectThemePrompt => 'サイコロをタップして\nテーマを選ぼう！';

  @override
  String get selectThemePromptCard => '下のボタンで1枚引こう';

  @override
  String get themeResultAnnouncement => 'このテーマが出たー！';

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
  String get vibrationEnabled => 'バイブを有効にする';

  @override
  String get timerSoundEnabled => 'タイマー終了音';

  @override
  String get faceThemesList => 'サイコロの面の表示';

  @override
  String get themeCandidates => 'テーマ候補';

  @override
  String get dragAndDropHint => '左のテキストボックスにドラッグ＆ドロップ';

  @override
  String get tutorialWelcome => 'Talk Shuffleへようこそ！';

  @override
  String get tutorialWelcomeBody =>
      'サイコロでテーマを選ぶか、カードで自分の価値観を話します。盛り上がりにも仕事の場にも使えます。';

  @override
  String get tutorialSetTheme => 'テーマを設定しよう';

  @override
  String get tutorialSetThemeBody => '各面のテーマを、候補からドラッグまたは直接入力で設定します。';

  @override
  String get tutorialRollDice => 'サイコロを振る';

  @override
  String get tutorialRollDiceBody => '「サイコロを振る」を押すとサイコロが転がり、ランダムなテーマが選ばれます。';

  @override
  String get tutorialCards => 'カードで遊ぶ';

  @override
  String get tutorialCardsBody =>
      '「仕事で盛り上がる」では3種類のカードデッキが選べます。\n\n価値観カード（価値観共有）、会議前・振り返り（会議の開始・終了）、自己内省・1on1（軽さ×深さの問い）です。';

  @override
  String get tutorialChangeSettings => '設定を変更する';

  @override
  String get tutorialChangeSettingsBody => 'いつでも戻るボタンで設定画面に戻り、人数やタイマーを変更できます。';

  @override
  String get tutorialReady => '準備完了！';

  @override
  String get tutorialReadyBody =>
      'サイコロでテーマを選んでも、カードで価値観を話し合ってもOK。場に合わせて使いましょう。';

  @override
  String get skip => 'スキップ';

  @override
  String get start => '始める';

  @override
  String get showTutorial => 'チュートリアルを表示';

  @override
  String get themeCube => 'テーマ';

  @override
  String get yourThemes => '話すテーマを選ぼう';

  @override
  String get useVariantsToChooseTheme => '画面左にドラッグ';

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
  String get checkInHowManyPrompt => '何枚選びますか？';

  @override
  String get checkInCardsOne => '1枚';

  @override
  String get checkInCardsTwo => '2枚';

  @override
  String get checkInCardsThree => '3枚';

  @override
  String get checkInDrawCountButton => 'この枚数で選ぶ';

  @override
  String get levelBeginner => '初級';

  @override
  String get levelIntermediate => '中級';

  @override
  String get levelAdvanced => '上級';

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
  String get timerTimeUp => '時間です';

  @override
  String get timerExtendOneMinute => '+1分';

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
  String get sessionCompleteAcknowledgeMessage =>
      '全員の番が終わりました。今回選んだお題は履歴に保存しました。もう一度練習するときは、左上の戻るから設定画面へ戻ってください。';

  @override
  String get sessionCompleteAcknowledgeButton => '閉じる';

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
  String get sessionSummaryScreenTitle => '今話したセッションのまとめ';

  @override
  String get voteTitle => '一番面白かった人は？';

  @override
  String get voteSubtitle => '今回のトピックで一番話が面白かった人に1票';

  @override
  String voteVoterLabel(String player) {
    return '投票者：$player';
  }

  @override
  String get voteResultsTitle => '投票結果';

  @override
  String voteCount(int count) {
    return '$count票';
  }

  @override
  String get voteSkip => '投票をスキップ';

  @override
  String get sessionEndButton => 'セッションを終了';

  @override
  String sessionSummaryPlayerTheme(String player) {
    return '$playerのトピック';
  }

  @override
  String get historyTitle => '履歴';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get support => 'サポート';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get historyEmptyMessage => 'まだ記録がありません';

  @override
  String get historyEmptyFiltered => '条件に合う履歴がありません';

  @override
  String historyListItemTitle(String date, String mode) {
    return '$date $modeをプレイ';
  }

  @override
  String historyPlayerCount(int count) {
    return '$count人でプレイ';
  }

  @override
  String get historyDetailTitle => '履歴詳細';

  @override
  String get historySummaryTitle => '概要';

  @override
  String get historyTopicsTitle => '出たテーマ';

  @override
  String get historySelectedCardsTitle => '選択したカード';

  @override
  String get historyDiscussionPromptsTitle => 'プレイヤーごとのお題';

  @override
  String get historyDiscussionPromptsFootnote =>
      '上から表示された順です。「別のお題へ」で差し替えたときは、そのたびに行が増えます。';

  @override
  String get historyModeDice => 'サイコロ';

  @override
  String get historyModeValueCards => '価値観カード';

  @override
  String get historyFilterAll => 'すべて';

  @override
  String get historyFilterDice => 'サイコロ';

  @override
  String get historyFilterValueCards => '価値観カード';

  @override
  String get historyModeDiscussion => '議論・お題';

  @override
  String get historyFilterDiscussion => '議論・お題';

  @override
  String get historyDeleteAll => '履歴を全削除';

  @override
  String get historyDeleteAllTitle => '履歴を全削除しますか？';

  @override
  String get historyDeleteAllMessage => 'この端末の履歴がすべて削除されます。';

  @override
  String get historyDeleteOne => 'この履歴を削除';

  @override
  String get historyDeleteOneTitle => 'この履歴を削除しますか？';

  @override
  String get historyDeleteOneMessage => 'この履歴は元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

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
  String get playerNamesHint => 'プレイヤー名を指定できます、下のボックスをタップ';

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
  String get modeSelectionTitle => 'Welcome to Talk Shuffle!\n遊び方を選んでください';

  @override
  String get homeSectionEveryone => 'サイコロを振ってランダムな話題で盛り上がろう';

  @override
  String get homeSectionWork => 'カードを選択して互いに価値観を表現しよう';

  @override
  String get homeDiceLabel => 'ランダムトピック';

  @override
  String get homeThemePickTitle => 'テーマを選ぼう';

  @override
  String get homeRandomDecideLabel => 'ランダムで決める';

  @override
  String get homeThemeShortGroupDiscussion => 'グループ議論';

  @override
  String get homeThemeShortValues => '価値観';

  @override
  String get backToModeSelection => 'モードを選び直す';

  @override
  String get cardSettingsTitle => 'カードを選ぶ';

  @override
  String get selectDeckPrompt => 'デッキを選んでください';

  @override
  String get playWithDeck => 'このデッキで遊ぶ';

  @override
  String get deckTeamBuilding => '価値観カード';

  @override
  String get deckTeamBuildingDesc => '価値観を共有し、チームの理解を深める';

  @override
  String get deckGroupDiscussion => 'グループディスカッション';

  @override
  String get deckGroupDiscussionDesc => '論理・創造・フェルミ推定・ジレンマから現代の社会課題まで、みんなで話すお題';

  @override
  String get discussionScreenTitle => '議論モード';

  @override
  String get discussionHint =>
      'カテゴリーごとに裏向きのカードがあります。タップで表面を見られ、もう一度タップすると裏に戻ります。このお題で話すなら確定してください。別のお題なら、ほかのカードをタップしてください。';

  @override
  String get discussionNextTopic => '別のお題へ';

  @override
  String get discussionNextTopicHelp => '別の切り口がほしくなったら（任意）';

  @override
  String discussionPromptQueue(int current, int total) {
    return 'お題の並び · $current/$total · いつでもスキップOK';
  }

  @override
  String get discussionDeckScopeTitle => '表示する候補カード';

  @override
  String get discussionThemeFilterTitle => 'テーマを絞る';

  @override
  String get discussionThemeFilterHint => 'タップで含めるカテゴリーを選べます。最低1つはオンにしてください。';

  @override
  String get discussionDeckScopeFull => 'デッキ全枚（シャッフル）';

  @override
  String get discussionDeckScopeTen => '10枚だけランダム';

  @override
  String get discussionDeckScopeSix => '6枚だけランダム';

  @override
  String get discussionDeckScopeThree => '3枚だけ（深掘り向け）';

  @override
  String discussionPreviewAllPrompts(int deck) {
    return 'お題: 全$deck枚をシャッフル';
  }

  @override
  String discussionPreviewSampledPrompts(int n, int deck) {
    return 'お題: $deck枚中から$n枚をランダム抽出';
  }

  @override
  String get discussionPreviewSessionEnd => '終了: 全員が一度話したとき';

  @override
  String promptBelongsToTurn(String turnLabel) {
    return 'このお題に話すのは、$turnLabel。';
  }

  @override
  String get discussionSessionPromptsTitle => 'このセッションのお題（プレイヤー別）';

  @override
  String get discussionPromptTimelineTitle => 'お題の記録（時系列）';

  @override
  String get discussionPromptTimelineSubtitle => '確定したお題が時系列で並びます。';

  @override
  String get discussionTurnNotYet => '（このあと）';

  @override
  String get discussionWaitingPick => 'カードをタップしてお題を選んでください';

  @override
  String get discussionPickFromCardsHeading => '裏向きのカード（横にスクロール）';

  @override
  String get discussionKickoffTitle => '全員のお題がそろいました';

  @override
  String discussionKickoffSpeakingLead(String order, String first) {
    return '話す順の目安: $order。まずは $first から。一人ずつ短く共有してから、自由に深掘りしましょう。';
  }

  @override
  String discussionKickoffTimerNote(String buttonLabel, String duration) {
    return '「$buttonLabel」を押すと、$duration からタイマーのカウントがはじまります。';
  }

  @override
  String get discussionKickoffStartButton => '議論を始める';

  @override
  String get discussionActiveFirstSpeakerCaption => 'まず話を始める目安';

  @override
  String discussionActiveOrderLine(String order) {
    return 'このあとの順番: $order';
  }

  @override
  String get discussionFirstSpeakerTag => '最初';

  @override
  String get discussionDiscussionCardWithTimer =>
      'タイマーは目安です。全員が一度ずつ共有したら、一緒に深掘りしてOKです。';

  @override
  String get discussionDiscussionCardNoTimer =>
      '全員が一度ずつ共有したら、そのまま一緒に深掘りしてOKです。';

  @override
  String get discussionEndDiscussionButton => '議論を終了';

  @override
  String get discussionConfirmTopic => 'このお題で話す';

  @override
  String get discussionLockedPick => 'お題が決まりました。準備ができたら「次のプレイヤー」をタップ';

  @override
  String get discussionUncategorizedTitle => 'お題';

  @override
  String get discussionCatProbLogical => '論理的に組み立てる';

  @override
  String get discussionCatProbCreative => '創造的に考える';

  @override
  String get discussionCatProbFermi => 'フェルミ推定';

  @override
  String get discussionCatProbDilemma => 'ジレンマ・倫理';

  @override
  String get discussionCatSocGeo => '地理・地政学';

  @override
  String get discussionCatSocAiGap => 'AI・デジタル格差';

  @override
  String get discussionCatSocClimate => '気候・環境';

  @override
  String get discussionCatSocDemocracy => '民主主義・ガバナンス';

  @override
  String get discussionCatSocJapanDecline => '日本：衰退・人口';

  @override
  String get discussionCatSocJapanImmigration => '日本：移民';

  @override
  String get discussionCatSocJapanWork => '日本：働き方・雇用';

  @override
  String get discussionCatSocJapanLocal => '日本：地域・コミュニティ';

  @override
  String get deckCheckIn => '会議前・振り返り';

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
  String get themeProbLogical1 => '売上が先月比30%ダウン。考えられる原因をMECEに分類せよ';

  @override
  String get themeProbLogical2 => '施策AとB、どちらを優先する？判断軸を3つ挙げて説明せよ';

  @override
  String get themeProbLogical3 => '会議が毎回長引く。根本原因はどこにあるか構造的に分析せよ';

  @override
  String get themeProbLogical4 => '新規事業の参入可否を1分で判断するには？最低限必要な情報は何か';

  @override
  String get themeProbLogical5 => '顧客からのクレームが増えている。どこから手をつけるか優先順位をつけよ';

  @override
  String get themeProbLogical6 => 'チームの生産性が下がっている。ボトルネックを特定するために何を調べるか';

  @override
  String get themeProbLogical7 => '「コストを20%削減せよ」と言われた。どのカテゴリから削るか論理的に説明せよ';

  @override
  String get themeProbLogical8 => 'A案とB案でデータが相反している。どちらを信頼するか、判断基準を示せ';

  @override
  String get themeProbLogical9 => 'プロジェクトが炎上しかけている。まず誰に何を報告するか、優先順位をつけよ';

  @override
  String get themeProbLogical10 => '「忙しいのに成果が出ない」状態を構造的に説明し、打ち手を示せ';

  @override
  String get themeProbCreative1 => '「待ち時間」を価値に変えるビジネスを3つ考えよ';

  @override
  String get themeProbCreative2 => '社内の紙をゼロにするには？常識を疑って発想せよ';

  @override
  String get themeProbCreative3 => '競合と全く逆の戦略を取るとしたら何をする？';

  @override
  String get themeProbCreative4 => '10年後、あなたの職種はどう変わる？それを逆手にとるアイデアは';

  @override
  String get themeProbCreative5 => '自社のサービスを「子ども向け」にリデザインするとしたら？';

  @override
  String get themeProbCreative6 => '予算ゼロで社員のモチベーションを上げる方法を5つ出せ';

  @override
  String get themeProbCreative7 => '「失敗したプロジェクト」を資産に変えるアイデアを考えよ';

  @override
  String get themeProbCreative8 => '他業界から1つビジネスモデルを借りてきて、自社に応用せよ';

  @override
  String get themeProbCreative9 => '「通勤時間」を会社の強みに変えるにはどうする？';

  @override
  String get themeProbCreative10 => 'もし価格を10倍にするとしたら、何を変える必要があるか？';

  @override
  String get themeProbFermi1 => '渋谷駅を1日に通過する人は何人？';

  @override
  String get themeProbFermi2 => '日本全国のオフィスの椅子の数は？';

  @override
  String get themeProbFermi3 => '自社の社員が1年間に書くメールの総文字数は？';

  @override
  String get themeProbFermi4 => '東京都内に信号機はいくつある？';

  @override
  String get themeProbFermi5 => '日本で1日に消費されるコーヒーのカップ数は？';

  @override
  String get themeProbFermi6 => '日本全国のコンビニで1日に捨てられる弁当の数は？';

  @override
  String get themeProbFermi7 => '自社のオフィスで1年間に使われる電力量はどのくらい？';

  @override
  String get themeProbFermi8 => '東京都内を走るタクシーの総走行距離（1日）は？';

  @override
  String get themeProbFermi9 => '日本全国のスマートフォンのバッテリーを合計すると何Wh？';

  @override
  String get themeProbFermi10 => '今この瞬間、日本で会議をしている人は何人いる？';

  @override
  String get themeProbDilemma1 => '優秀だが協調性のないメンバー。残す？外す？判断基準を言語化せよ';

  @override
  String get themeProbDilemma2 => '締め切り厳守 vs クオリティ死守。どちらを選ぶ？条件は？';

  @override
  String get themeProbDilemma3 => '上司の判断が明らかに間違っている。あなたはどう動く？';

  @override
  String get themeProbDilemma4 => '短期利益 vs 長期ブランド。トレードオフが生じたときの優先順位は？';

  @override
  String get themeProbDilemma5 => 'チームの仲が良すぎて馴れ合いになっている。どう介入する？';

  @override
  String get themeProbDilemma6 => '正直に言うと相手を傷つける。でも黙ると組織が傷つく。どうする？';

  @override
  String get themeProbDilemma7 => '実力はあるが自己主張が強すぎる部下と、素直だが成長が遅い部下。どちらを昇進させる？';

  @override
  String get themeProbDilemma8 => '成功確率20%だが成功すれば大きいA案と、確実だが小さく終わるB案。どちらを取る？';

  @override
  String get themeProbDilemma9 => '自分のミスを報告すると、チームの評価が下がる可能性がある。どうする？';

  @override
  String get themeProbDilemma10 => 'リソースが足りない。既存顧客の満足度を守る vs 新規顧客を獲得する。どちらを優先？';

  @override
  String get themeSocGeo1 => '米中対立が激化したとき、企業はどちらの経済圏を選ぶべきか？';

  @override
  String get themeSocGeo2 => '関税・貿易戦争は「国を守る手段」か、「世界を貧しくする愚策」か？';

  @override
  String get themeSocGeo3 => '経済安全保障のために、企業はどこまでサプライチェーンを自国回帰すべきか？';

  @override
  String get themeSocGeo4 => 'ロシア・ウクライナ戦争が長期化すると、グローバルビジネスにどんな影響が続くか？';

  @override
  String get themeSocGeo5 => '「友好国とだけ貿易するフレンドショアリング」は現実的な戦略か？';

  @override
  String get themeSocGeo6 => '中東情勢が不安定なまま続く場合、エネルギーコストに企業はどう備えるか？';

  @override
  String get themeSocGeo7 => '国連・WTOへの信頼が崩れたとき、世界秩序はどう維持されるか？';

  @override
  String get themeSocGeo8 => '地政学リスクを「経営課題」として扱えていない企業は生き残れるか？';

  @override
  String get themeSocGeo9 => 'グローバルサウス（新興国・途上国）の台頭は、世界にとってチャンスか脅威か？';

  @override
  String get themeSocGeo10 => '「どの国とも仲良くする」外交戦略は、これからも通用するか？';

  @override
  String get themeSocAiGap1 => 'AIの恩恵を受けるのは結局、お金と技術を持つ国や企業だけではないか？';

  @override
  String get themeSocAiGap2 => 'AIが意思決定した結果に問題が起きたとき、責任は誰が取るのか？';

  @override
  String get themeSocAiGap3 => '採用・融資・医療診断をAIが決める社会は、公平か？危険か？';

  @override
  String get themeSocAiGap4 => '特定の企業がAIを独占することは、民主主義への脅威になるか？';

  @override
  String get themeSocAiGap5 => '国境を越えて動くAIを誰が規制すべきか？各国政府？国際機関？企業自身？';

  @override
  String get themeSocAiGap6 => 'AIによる雇用喪失に対し、ベーシックインカムは解決策になるか？';

  @override
  String get themeSocAiGap7 => 'AI格差により先進国と途上国の生産性の差が広がることを、誰が止めるべきか？';

  @override
  String get themeSocAiGap8 => '生成AIで大量の偽情報が拡散する社会で、「本物」をどう見分けるか？';

  @override
  String get themeSocAiGap9 => 'AIを「兵器」として使う国が増えた場合、国際的なルールは作れるか？';

  @override
  String get themeSocAiGap10 => '10年後、AIが「持てる国」と「持たざる国」の差をどう変えると思うか？';

  @override
  String get themeSocClimate1 => '気候変動対策に消極的な国の製品に「炭素関税」をかけることは公平か？';

  @override
  String get themeSocClimate2 => '再生可能エネルギーのリーダーが中国になりつつある。世界はそれでいいか？';

  @override
  String get themeSocClimate3 => '企業のESGレポートはほとんど「グリーンウォッシュ」だと思うか？';

  @override
  String get themeSocClimate4 => '気候変動で住めなくなった地域からの「気候難民」を、豊かな国はどう受け入れるべきか？';

  @override
  String get themeSocClimate5 => '経済成長と脱炭素は本当に両立できるか？';

  @override
  String get themeSocClimate6 => '肉食・航空機利用など個人の行動変容で、気候は本当に変わるか？';

  @override
  String get themeSocClimate7 => '先進国と途上国で、気候変動対策の「責任」は同じであるべきか？';

  @override
  String get themeSocClimate8 => '原子力を「グリーンエネルギー」と呼ぶことに、賛成か反対か？';

  @override
  String get themeSocClimate9 => '2050年ゼロカーボンが達成できない場合、次の世代にどう説明するか？';

  @override
  String get themeSocClimate10 => '気候変動対策として、今すぐ一つだけ実行するとしたら何を選ぶか？';

  @override
  String get themeSocDemocracy1 => '富裕層への課税を強化して格差を縮めることに、賛成か反対か？';

  @override
  String get themeSocDemocracy2 => 'SNSのアルゴリズムは民主主義を壊しているか？それとも強化しているか？';

  @override
  String get themeSocDemocracy3 => '選挙にAIや偽情報が介入した場合、選挙結果は有効か？';

  @override
  String get themeSocDemocracy4 => '「強いリーダーシップ」と「独裁」の境界線はどこか？';

  @override
  String get themeSocDemocracy5 => 'フェイクニュースを拡散した人は、法的に罰せられるべきか？';

  @override
  String get themeSocDemocracy6 => 'SNSプラットフォームは「言論の場」か、「メディア企業」として規制されるべきか？';

  @override
  String get themeSocDemocracy7 => '「エコーチェンバー」から抜け出すために、個人は何ができるか？';

  @override
  String get themeSocDemocracy8 => '世界各地で「エリートへの怒り」が高まっている。その根本原因は何か？';

  @override
  String get themeSocDemocracy9 => '先進国が「民主主義を広める」と言うとき、それは本当に善意か？';

  @override
  String get themeSocDemocracy10 => '「社会の分断」を一番深めているのは何か？メディア？政治家？アルゴリズム？';

  @override
  String get themeSocJapanDecline1 => '人口が今の半分になる社会で、あなたの仕事は存在しているか？';

  @override
  String get themeSocJapanDecline2 => '少子化対策として「最も効果が高い」施策は何だと思うか？';

  @override
  String get themeSocJapanDecline3 => '人口減少を「問題」ではなく「チャンス」と捉えるとしたら、何が見えてくるか？';

  @override
  String get themeSocJapanDecline4 => '高齢者の医療費を現役世代が支え続ける仕組みは、持続可能か？';

  @override
  String get themeSocJapanDecline5 => '定年を80歳に引き上げることに、賛成か反対か？';

  @override
  String get themeSocJapanDecline6 => '子どもを産まない選択をする人を、社会はどう扱うべきか？';

  @override
  String get themeSocJapanDecline7 => '「子どもを産んだ人が得をする税制」は公平か？不公平か？';

  @override
  String get themeSocJapanDecline8 => '介護ロボットが普及しても、家族が介護すべき場面はあるか？';

  @override
  String get themeSocJapanDecline9 => '2026年は丙午。迷信が出生数に影響する社会をどう思うか？';

  @override
  String get themeSocJapanDecline10 => 'あなたが80歳になったとき、どんな社会に生きていたいか？';

  @override
  String get themeSocJapanImmigration1 => '人手不足を外国人労働者で補うことへの、あなたのリアルな本音は？';

  @override
  String get themeSocJapanImmigration2 => '日本語が話せない子どもへの教育コストは、誰が負うべきか？';

  @override
  String get themeSocJapanImmigration3 => '高度人材の外国人が日本を選ばない理由は何か？どうすれば変わるか？';

  @override
  String get themeSocJapanImmigration4 =>
      '「移民を受け入れるべき」と言いながら、自分の隣人には嫌だと感じるのはなぜか？';

  @override
  String get themeSocJapanImmigration5 => '少子化対策として移民を増やすことは、文化的アイデンティティを変えるか？';

  @override
  String get themeSocJapanImmigration6 => '「日本人らしさ」とは何か？それは守るべきものか、変わっていいものか？';

  @override
  String get themeSocJapanImmigration7 => '外国人が多い職場で、チームとしてまとまるために何が必要か？';

  @override
  String get themeSocJapanImmigration8 => '欧米で外国人問題が国家分断につながっている。日本は同じ道をたどるか？';

  @override
  String get themeSocJapanImmigration9 => '外国人の土地取得を制限することに、賛成か反対か？';

  @override
  String get themeSocJapanImmigration10 => '50年後の日本が多民族国家になっていたとしたら、それはよいことか？';

  @override
  String get themeSocJapanWork1 => '週4日勤務が標準になったとき、会社と個人はそれぞれ何を変える必要があるか？';

  @override
  String get themeSocJapanWork2 => '新卒一括採用・終身雇用は、今の時代に合っているか？';

  @override
  String get themeSocJapanWork3 => '成果が同じなら、働く時間が短い人と長い人の評価は同じにすべきか？';

  @override
  String get themeSocJapanWork4 => '副業を全員に解禁すると、組織への忠誠心は下がるか？';

  @override
  String get themeSocJapanWork5 => '「やりがい搾取」はなぜなくならないのか？誰が変えるべきか？';

  @override
  String get themeSocJapanWork6 => '上司が部下より給与が低い逆転現象は、問題か？健全か？';

  @override
  String get themeSocJapanWork7 => '燃え尽き症候群（バーンアウト）を防ぐ責任は、個人か？会社か？';

  @override
  String get themeSocJapanWork8 => 'テレワークと出社、チームにとって本当にいいのはどちらか？';

  @override
  String get themeSocJapanWork9 => '「会社の飲み会」は業務か？プライベートか？';

  @override
  String get themeSocJapanWork10 => '10年後、「会社員」という働き方は主流であり続けるか？';

  @override
  String get themeSocJapanLocal1 => 'バスも電車もなくなった地方に、住み続ける権利を社会は保障すべきか？';

  @override
  String get themeSocJapanLocal2 => '廃校になった学校の跡地を、何に使うべきか？';

  @override
  String get themeSocJapanLocal3 => 'リモートワークは地方創生の救世主になれるか？それとも幻想か？';

  @override
  String get themeSocJapanLocal4 => '人口が100人を切った村に、公共サービスを提供し続けるべきか？';

  @override
  String get themeSocJapanLocal5 => '老朽化したインフラを維持するために増税することに、賛成か反対か？';

  @override
  String get themeSocJapanLocal6 => '都市への人口集中は「問題」か？それとも「効率的な選択」か？';

  @override
  String get themeSocJapanLocal7 => '地方に本社機能を移転した企業は、本当に成功できるか？';

  @override
  String get themeSocJapanLocal8 => '「消滅可能性都市」というレッテルを貼ることは、地方にとってプラスかマイナスか？';

  @override
  String get themeSocJapanLocal9 => 'あなたが地方移住を決断するとしたら、最低限必要な条件は何か？';

  @override
  String get themeSocJapanLocal10 => '地方の問題を解決する責任は、国・自治体・企業・個人のどこにあるか？';

  @override
  String valuePlayerTurn(String displayName) {
    return '$displayNameの番';
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
  String valuePlayerFinalCards(String displayName) {
    return '$displayNameが残した5枚';
  }

  @override
  String get valueNext => '次へ';

  @override
  String get valueGameComplete => 'お疲れさまでした';

  @override
  String get valueSessionCompleteAndBack => 'お疲れ様でした、セッションに戻る';

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
  String get valueTutorialTooltip => 'チュートリアル';

  @override
  String get valueTutorialPage1Title => '参加人数を選んでスタート';

  @override
  String get valueTutorialPage1Body => '2〜10人で遊べます。人数やタイマー設定をしてプレイを始めましょう。';

  @override
  String get valueTutorialPage2Title => '価値観カードでは1枚捨てて、5枚をランキング';

  @override
  String get valueTutorialPage2Body =>
      '各ラウンドで1枚引きます。6枚になったら価値観から遠いカードを1枚捨て、残り5枚を重要度順に並べて確定します。';

  @override
  String get valueTutorialPage3Title => '5ラウンドで残り5枚を共有';

  @override
  String get valueTutorialPage3Body =>
      '5ラウンド終えると、それぞれ残り5枚のカードが残ります。参加者に見せて、なぜそのカードを残したか共有しましょう。';

  @override
  String get errorDataLoadTitle => 'データの読み込みに失敗しました';

  @override
  String get errorDataLoadMessage => '問いのデータを読み込めませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get retry => '再試行';

  @override
  String get dismiss => '閉じる';

  @override
  String get showModeSelectionAtStartup => '起動時にモード選択を表示する';

  @override
  String get showModeSelectionAtStartupDone => '設定しました。次回起動時はモード選択が表示されます。';
}
