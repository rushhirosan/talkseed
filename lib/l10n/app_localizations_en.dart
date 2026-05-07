// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Talk Shuffle';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get backToSettings => 'Back to Settings';

  @override
  String get rollDice => 'Roll Dice';

  @override
  String get complete => 'Done';

  @override
  String get rollNow => 'Roll Now';

  @override
  String get playWithOthers => 'To Session';

  @override
  String get playWithDice => 'Play with Dice';

  @override
  String get playWithCards => 'Play with Cards';

  @override
  String alwaysOpenWithDice(String randomLabel) {
    return 'Next launch: same flow as “$randomLabel”';
  }

  @override
  String get alwaysOpenWithDiceHint =>
      'Skips this menu and opens theme setup—the same path as the purple button above.';

  @override
  String get alwaysOpenWithCards => 'Open with cards on startup';

  @override
  String get startupDefaultSection => 'On next launch';

  @override
  String get selectThemePrompt => 'Tap the dice to\nselect a theme!';

  @override
  String get selectThemePromptCard => 'Tap the button below to draw a card';

  @override
  String get themeResultAnnouncement => 'This theme came up!';

  @override
  String faceLabel(int faceNumber) {
    return 'Face $faceNumber';
  }

  @override
  String get themeInputHint => 'Enter theme or drag';

  @override
  String get dropHere => 'Drop here';

  @override
  String get randomSet => 'Random Set';

  @override
  String get reset => 'Reset';

  @override
  String get vibrationEnabled => 'Enable vibration';

  @override
  String get timerSoundEnabled => 'Timer end sound';

  @override
  String get faceThemesList => 'Display per face';

  @override
  String get themeCandidates => 'Theme Candidates';

  @override
  String get dragAndDropHint => 'Drag & drop to the text boxes on the left';

  @override
  String get tutorialWelcome => 'Welcome to Talk Shuffle!';

  @override
  String get tutorialWelcomeBody =>
      'Pick a theme by rolling dice, or draw a card to talk about your values. Use it to get everyone excited or at work.';

  @override
  String get tutorialSetTheme => 'Set your themes';

  @override
  String get tutorialSetThemeBody =>
      'Set themes for each face by dragging from the candidates or typing them in.';

  @override
  String get tutorialRollDice => 'Roll the Dice';

  @override
  String get tutorialRollDiceBody =>
      'Tap \"Roll Dice\" to roll the dice and pick a random theme.';

  @override
  String get tutorialCards => 'Play with Cards';

  @override
  String get tutorialCardsBody =>
      '\"Get excited at work\" offers three card decks.\n\nValue cards (share values), Check-in & Check-out (meeting start/end), and Self-reflection & 1-on-1 (questions with lightness and depth).';

  @override
  String get tutorialChangeSettings => 'Change Settings';

  @override
  String get tutorialChangeSettingsBody =>
      'You can go back to the settings screen anytime with the back button to change the number of players and timer.';

  @override
  String get tutorialReady => 'All set!';

  @override
  String get tutorialReadyBody =>
      'Roll the dice for a theme, or draw a card to talk about your values. Use whichever fits the moment.';

  @override
  String get skip => 'Skip';

  @override
  String get start => 'Start';

  @override
  String get showTutorial => 'Show Tutorial';

  @override
  String get themeCube => 'Themes';

  @override
  String get yourThemes => 'Choose topics to talk about';

  @override
  String get useVariantsToChooseTheme => 'Drag to the left';

  @override
  String get themeSurprised => 'Something surprising';

  @override
  String get themeFutureDream => 'Future dream';

  @override
  String get themeLoveStory => 'Love story';

  @override
  String get themeRecommendedBook => 'Recommended book';

  @override
  String get themeRecentHobby => 'Recent hobby';

  @override
  String get themeDislike => 'Something I dislike';

  @override
  String get themeFavoriteMovie => 'Favorite movie';

  @override
  String get themeTreasure => 'Something I treasure';

  @override
  String get themeCried => 'Something that made me cry';

  @override
  String get themeLaughed => 'Something that made me laugh';

  @override
  String get themeMoved => 'Something that moved me';

  @override
  String get themeRegret => 'Something I regret';

  @override
  String get themeProud => 'Something I\'m proud of';

  @override
  String get themeEmbarrassed => 'Something embarrassing';

  @override
  String get themeFavoriteMusic => 'Favorite music';

  @override
  String get themeFavoriteAnime => 'Favorite anime';

  @override
  String get themeFavoriteGame => 'Favorite game';

  @override
  String get themeFavoriteFood => 'Favorite food';

  @override
  String get themeWantToVisit => 'Place I want to visit';

  @override
  String get themeFavoriteSport => 'Favorite sport';

  @override
  String get themeFriendMemory => 'Memory with friends';

  @override
  String get themeFamilyMemory => 'Memory with family';

  @override
  String get themeGrateful => 'Something I\'m grateful for';

  @override
  String get themeSupporting => 'Someone I\'m supporting';

  @override
  String get themeWantToDo => 'Something I want to do';

  @override
  String get themeWantToAchieve => 'Something I want to achieve';

  @override
  String get themeDreamJob => 'Dream job';

  @override
  String get themeWantToVisitCountry => 'Country I want to visit';

  @override
  String get themeRecentEvent => 'Recent event';

  @override
  String get themeTodayEvent => 'Today\'s event';

  @override
  String get themeWeekendPlan => 'Weekend plan';

  @override
  String get themeRelaxMethod => 'How I relax';

  @override
  String get themeStressRelief => 'How I relieve stress';

  @override
  String get themeMorningRoutine => 'Morning routine';

  @override
  String get themeFavoriteWord => 'Favorite word';

  @override
  String get themeMotto => 'Motto';

  @override
  String get themeImportantThing => 'Important thing';

  @override
  String get themeBelief => 'Something I believe in';

  @override
  String get themeLifeLesson => 'Life lesson';

  @override
  String get themeRecentWorry => 'Recent worry';

  @override
  String get themeProudOf => 'Something I\'m proud of';

  @override
  String get themeUniqueSkill => 'Unique skill';

  @override
  String get themeSecret => 'Something I keep secret';

  @override
  String get themeChildhoodMemory => 'Childhood memory';

  @override
  String get sessionSetup => 'Session Setup';

  @override
  String get playModeLabel => 'Play mode';

  @override
  String get playModeDice => 'With dice';

  @override
  String get playModeTopicCard => 'With topic cards';

  @override
  String get drawTopic => 'Draw topic';

  @override
  String get phaseCheckIn => 'Before meeting';

  @override
  String get phaseCheckOut => 'After meeting';

  @override
  String get checkInPickOnePrompt => 'Choose one question from these';

  @override
  String get checkInHowManyPrompt => 'How many cards?';

  @override
  String get checkInCardsOne => '1 card';

  @override
  String get checkInCardsTwo => '2 cards';

  @override
  String get checkInCardsThree => '3 cards';

  @override
  String get checkInDrawCountButton => 'Draw this many';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get reselectQuestion => 'Choose again';

  @override
  String get chosenCardLabelBefore => 'Question chosen (before meeting)';

  @override
  String get chosenCardLabelAfter => 'Question chosen (after meeting)';

  @override
  String get playerCount => 'Number of participants';

  @override
  String get timerSettings => 'Timer Settings';

  @override
  String get enableTimer => 'Enable Timer';

  @override
  String get timerDuration => 'Duration';

  @override
  String get timerTimeUp => 'Time\'s up';

  @override
  String get timerExtendOneMinute => '+1 min';

  @override
  String playerName(int number) {
    return 'Player $number';
  }

  @override
  String get startSession => 'Start Session';

  @override
  String currentPlayer(int current, int total) {
    return 'Player $current/$total\'s turn';
  }

  @override
  String get nextPlayer => 'Next Player';

  @override
  String get endSession => 'End Session';

  @override
  String get sessionSummary => 'Session Summary';

  @override
  String get sessionCompleteMessage => 'Everyone has had their turn.';

  @override
  String round(int number) {
    return 'Round $number';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get share => 'Share';

  @override
  String get newSession => 'New Session';

  @override
  String get sessionSummaryScreenTitle => 'Summary of the session you just had';

  @override
  String get voteTitle => 'Who was the most fun?';

  @override
  String get voteSubtitle => 'Cast one vote for the most fun story this round.';

  @override
  String voteVoterLabel(String player) {
    return 'Voter: $player';
  }

  @override
  String get voteResultsTitle => 'Voting results';

  @override
  String voteCount(int count) {
    return '$count votes';
  }

  @override
  String get voteSkip => 'Skip voting';

  @override
  String get sessionEndButton => 'End session';

  @override
  String sessionSummaryPlayerTheme(String player) {
    return '$player\'s topic';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get aboutApp => 'About App';

  @override
  String get support => 'Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get historyEmptyMessage => 'No records yet';

  @override
  String get historyEmptyFiltered => 'No records for this filter';

  @override
  String historyListItemTitle(String date, String mode) {
    return 'Played $mode on $date';
  }

  @override
  String historyPlayerCount(int count) {
    return '$count players';
  }

  @override
  String get historyDetailTitle => 'History Details';

  @override
  String get historySummaryTitle => 'Summary';

  @override
  String get historyTopicsTitle => 'Topics';

  @override
  String get historySelectedCardsTitle => 'Selected cards';

  @override
  String get historyModeDice => 'Dice';

  @override
  String get historyModeValueCards => 'Value cards';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterDice => 'Dice';

  @override
  String get historyFilterValueCards => 'Value cards';

  @override
  String get historyModeDiscussion => 'Discussion prompts';

  @override
  String get historyFilterDiscussion => 'Discussion';

  @override
  String get historyDeleteAll => 'Delete all history';

  @override
  String get historyDeleteAllTitle => 'Delete all history?';

  @override
  String get historyDeleteAllMessage =>
      'All history on this device will be deleted.';

  @override
  String get historyDeleteOne => 'Delete this history';

  @override
  String get historyDeleteOneTitle => 'Delete this history?';

  @override
  String get historyDeleteOneMessage => 'This history cannot be restored.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get goToSessionSetup => 'Go to Session Setup';

  @override
  String get backToThemeSettings => 'Back to Theme Settings';

  @override
  String get timer30Seconds => '30 seconds';

  @override
  String get timer1Minute => '1 minute';

  @override
  String get timer2Minutes => '2 minutes';

  @override
  String get timer3Minutes => '3 minutes';

  @override
  String get timer5Minutes => '5 minutes';

  @override
  String get timerUnlimited => 'Unlimited';

  @override
  String get playerNamesOptional => 'Player Names (Optional)';

  @override
  String get playerNamesHint =>
      'You can specify player names. Tap the box below.';

  @override
  String get sessionPreviewTitle => 'This session';

  @override
  String sessionPreviewPlayers(int count) {
    return 'Play with $count players';
  }

  @override
  String sessionPreviewTimer(String timer) {
    return 'Time limit: $timer';
  }

  @override
  String get sessionPreviewNoTimer => 'No timer';

  @override
  String get modeSelectionTitle =>
      'Welcome to Talk Shuffle!\nChoose how to play';

  @override
  String get homeSectionEveryone =>
      'Roll the dice and get excited with random topics';

  @override
  String get homeSectionWork =>
      'Choose cards and share your values with each other';

  @override
  String get homeDiceLabel => 'Random topics';

  @override
  String get homeThemePickTitle => 'Choose a theme';

  @override
  String get homeRandomDecideLabel => 'Decide randomly';

  @override
  String get homeThemeShortSocial => 'Social issues';

  @override
  String get homeThemeShortProblem => 'Problem solving';

  @override
  String get homeThemeShortValues => 'Values';

  @override
  String get backToModeSelection => 'Choose mode again';

  @override
  String get cardSettingsTitle => 'Choose Cards';

  @override
  String get selectDeckPrompt => 'Select a deck';

  @override
  String get playWithDeck => 'Play with this deck';

  @override
  String get deckTeamBuilding => 'Value cards';

  @override
  String get deckTeamBuildingDesc =>
      'Share values and deepen team understanding';

  @override
  String get deckProblemSolving => 'Problem-solving practice';

  @override
  String get deckProblemSolvingDesc =>
      'Practice structuring issues: goals, options, risks, and next steps';

  @override
  String get deckSocialIssues => 'Social issues discussion';

  @override
  String get deckSocialIssuesDesc =>
      'Discuss contemporary topics with structure and mutual respect';

  @override
  String get discussionScreenTitle => 'Discussion';

  @override
  String get discussionHint =>
      'No ranking needed. Talk about the prompt and explore perspectives together.';

  @override
  String get discussionNextTopic => 'Next prompt';

  @override
  String discussionProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get deckCheckIn => 'Check-in & Check-out';

  @override
  String get deckCheckInDesc =>
      'For meeting start and end. Everyone shares briefly based on a question';

  @override
  String get deckSelfReflection => 'Self-reflection & 1-on-1';

  @override
  String get deckSelfReflectionDesc =>
      'Questions with lightness and depth. For solo reflection or 1-on-1s';

  @override
  String get deckOneOnOne => 'Growth Dialogue';

  @override
  String get deckOneOnOneDesc =>
      'For 1-on-1s. Talk about future, blockers, and what you want to grow—without evaluation.';

  @override
  String get deckRetrospective => 'Retrospective';

  @override
  String get deckRetrospectiveDesc =>
      'As a team. Reflect on what went well, improvements, and learnings';

  @override
  String get deckIceBreaker => 'Icebreaker';

  @override
  String get deckIceBreakerDesc => 'To warm up. Light topics to break the ice';

  @override
  String get themeTrust => 'Value trust and relationships';

  @override
  String get themeChallenge => 'Embrace challenges';

  @override
  String get themeGratitude => 'Express gratitude';

  @override
  String get themeFeedback => 'Welcome feedback';

  @override
  String get themeFlexibility => 'Stay flexible';

  @override
  String get themeResponsibility => 'Take responsibility';

  @override
  String get themeGrowth => 'Keep growing';

  @override
  String get themeWorkLifeBalance => 'Value work-life balance';

  @override
  String get themeCollaboration => 'Work together';

  @override
  String get themeTransparency => 'Share information openly';

  @override
  String get themeWeeklyHighlight => 'Weekly highlight';

  @override
  String get themeTodayGoal => 'Today\'s goal';

  @override
  String get themeBlocker => 'Something blocking you';

  @override
  String get themeCurrentMood => 'Current mood';

  @override
  String get themeOneWord => 'One word for today';

  @override
  String get themeWellDone => 'Something that went well';

  @override
  String get themeStruggle => 'Something you\'re struggling with';

  @override
  String get themeWantToGrow => 'Something you want to grow in';

  @override
  String get themeFeedbackWant => 'Something you want feedback on';

  @override
  String get themeGoodPoint => 'What went well';

  @override
  String get themeImprovePoint => 'What to improve';

  @override
  String get themeLearnings => 'What we learned';

  @override
  String get themeNextAction => 'Next action';

  @override
  String get themeThanks => 'Thanks';

  @override
  String get themeHonesty => 'Value honesty';

  @override
  String get themeInnovation => 'Try new approaches';

  @override
  String get themeStability => 'Value stability';

  @override
  String get themeAutonomy => 'Decide on your own';

  @override
  String get themeCommunity => 'Value team and community';

  @override
  String get themeQuality => 'Prioritize quality';

  @override
  String get themeSpeed => 'Value speed';

  @override
  String get themeCustomerFirst => 'Put customers first';

  @override
  String get themeLearning => 'Keep learning';

  @override
  String get themeBalance => 'Seek balance';

  @override
  String get themeCreativity => 'Value creativity';

  @override
  String get themeEmpathy => 'Empathize with others';

  @override
  String get themeConsistency => 'Stay consistent';

  @override
  String get themeRespect => 'Respect diversity';

  @override
  String get themeValuePriority => 'Prioritize what matters';

  @override
  String get themeValueIntegrity => 'Act on your beliefs';

  @override
  String get themeProbLogical1 =>
      'Sales are down 30% month-over-month. Classify possible causes in a MECE way.';

  @override
  String get themeProbLogical2 =>
      'Between initiative A and B, which should be prioritized? Explain with three decision axes.';

  @override
  String get themeProbLogical3 =>
      'Meetings always run long. Analyze the root cause structurally.';

  @override
  String get themeProbLogical4 =>
      'How would you decide on entering a new business in one minute? What minimum information is required?';

  @override
  String get themeProbLogical5 =>
      'Customer complaints are increasing. Prioritize where to start first.';

  @override
  String get themeProbLogical6 =>
      'Team productivity is dropping. What would you investigate to identify the bottleneck?';

  @override
  String get themeProbLogical7 =>
      'You are told to cut costs by 20%. Explain logically which categories to reduce first.';

  @override
  String get themeProbLogical8 =>
      'Data from plan A and B conflict. Which do you trust, and by what criteria?';

  @override
  String get themeProbLogical9 =>
      'A project is close to going off the rails. Who do you report to first, what do you report, and in what order?';

  @override
  String get themeProbLogical10 =>
      'Explain structurally why someone is \'busy but not delivering outcomes,\' and propose actions.';

  @override
  String get themeProbCreative1 =>
      'Come up with three businesses that turn waiting time into value.';

  @override
  String get themeProbCreative2 =>
      'How can you eliminate paper usage in the company? Challenge common assumptions.';

  @override
  String get themeProbCreative3 =>
      'If you had to take a strategy completely opposite to competitors, what would you do?';

  @override
  String get themeProbCreative4 =>
      'How will your profession change in 10 years? What idea can leverage that change?';

  @override
  String get themeProbCreative5 =>
      'How would you redesign your service for children?';

  @override
  String get themeProbCreative6 =>
      'List five ways to increase employee motivation with zero budget.';

  @override
  String get themeProbCreative7 =>
      'Turn a failed project into an asset. What ideas do you have?';

  @override
  String get themeProbCreative8 =>
      'Borrow one business model from another industry and apply it to your company.';

  @override
  String get themeProbCreative9 =>
      'How can commute time become a company strength?';

  @override
  String get themeProbCreative10 =>
      'If your price became 10x higher, what would need to change?';

  @override
  String get themeProbFermi1 =>
      'How many people pass through Shibuya Station in one day?';

  @override
  String get themeProbFermi2 =>
      'How many office chairs are there across Japan?';

  @override
  String get themeProbFermi3 =>
      'How many total characters are written in employee emails in one year at your company?';

  @override
  String get themeProbFermi4 => 'How many traffic lights are there in Tokyo?';

  @override
  String get themeProbFermi5 =>
      'How many cups of coffee are consumed per day in Japan?';

  @override
  String get themeProbFermi6 =>
      'How many boxed lunches are discarded daily at convenience stores across Japan?';

  @override
  String get themeProbFermi7 =>
      'How much electricity is used in your office in one year?';

  @override
  String get themeProbFermi8 =>
      'What is the total taxi driving distance per day in Tokyo?';

  @override
  String get themeProbFermi9 =>
      'What is the combined battery capacity (Wh) of all smartphones in Japan?';

  @override
  String get themeProbFermi10 =>
      'At this exact moment, how many people are in meetings in Japan?';

  @override
  String get themeProbDilemma1 =>
      'A high performer lacks collaboration. Keep or remove? Define your criteria.';

  @override
  String get themeProbDilemma2 =>
      'Deadline certainty vs quality protection: which do you choose, and under what conditions?';

  @override
  String get themeProbDilemma3 =>
      'Your manager\'s decision is clearly wrong. How do you act?';

  @override
  String get themeProbDilemma4 =>
      'Short-term profit vs long-term brand. How do you prioritize when trade-offs emerge?';

  @override
  String get themeProbDilemma5 =>
      'The team gets along too well and becomes complacent. How do you intervene?';

  @override
  String get themeProbDilemma6 =>
      'Telling the truth may hurt a person, but silence may hurt the organization. What do you do?';

  @override
  String get themeProbDilemma7 =>
      'Who would you promote: a highly capable but overly assertive report, or a sincere but slower-growing one?';

  @override
  String get themeProbDilemma8 =>
      'Choose between A (20% success chance, big upside) and B (almost certain, limited upside). Which do you take?';

  @override
  String get themeProbDilemma9 =>
      'Reporting your own mistake may lower team evaluation. What do you do?';

  @override
  String get themeProbDilemma10 =>
      'Resources are limited. Prioritize existing customer satisfaction or new customer acquisition?';

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
    return '$displayName\'s turn';
  }

  @override
  String get valueDiscardPrompt =>
      'Tap the card furthest from your values to discard';

  @override
  String get valueRankPrompt =>
      'Rank the 6 cards by importance (top = keep, bottom = discard)';

  @override
  String get valueConfirmRanking => 'Confirm and discard';

  @override
  String get valueDiscardLabel => 'Discard';

  @override
  String valuePlayerFinalCards(String displayName) {
    return '$displayName\'s 5 remaining cards';
  }

  @override
  String get valueNext => 'Next';

  @override
  String get valueGameComplete => 'Well done!';

  @override
  String get valueSessionCompleteAndBack => 'Well done, back to session';

  @override
  String get valueSharePrompt =>
      'Show your 5 remaining cards and share with everyone';

  @override
  String get valuePlayerCount => 'Number of participants';

  @override
  String get valueStart => 'Start';

  @override
  String get valueBackToDeck => 'Back to deck selection';

  @override
  String get valueDrawCard => 'Draw 1 card from pile';

  @override
  String valueRound(int current) {
    return 'Round $current/5';
  }

  @override
  String get valueTutorialTooltip => 'Tutorial';

  @override
  String get valueTutorialPage1Title => 'Choose players and start';

  @override
  String get valueTutorialPage1Body =>
      'Play with 2–10 players. Choose the number and tap \"Start\" to deal cards and begin the game.';

  @override
  String get valueTutorialPage2Title => 'Discard one, rank the six';

  @override
  String get valueTutorialPage2Body =>
      'Each round, draw 1 card. At 6 cards, discard the one furthest from your values, then rank the rest and confirm.';

  @override
  String get valueTutorialPage3Title => 'After 5 rounds, share your 5';

  @override
  String get valueTutorialPage3Body =>
      'After 5 rounds, each player has 5 cards left. Show them and share why you kept those cards.';

  @override
  String get errorDataLoadTitle => 'Failed to load data';

  @override
  String get errorDataLoadMessage =>
      'Could not load question data. Please try again later.';

  @override
  String get retry => 'Retry';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get showModeSelectionAtStartup => 'Show mode selection at startup';

  @override
  String get showModeSelectionAtStartupDone =>
      'Done. Mode selection will show on next launch.';
}
