/* Talk Shuffle static page copy (ja / en). Loaded after lang.js */
(function () {
  var APP_STORE_JA =
    'https://apps.apple.com/jp/app/talk-shuffle/id6760679042';
  var APP_STORE_EN =
    'https://apps.apple.com/app/talk-shuffle/id6760679042';

  window.TalkShuffleI18n = {
    landing: {
      ja: {
        _meta: {
          title: 'Talk Shuffle — 会話のテーマを3Dサイコロで決めるアプリ',
          description:
            'Talk Shuffleは、会議のチェックイン・1on1・アイスブレイク・雑談のきっかけに使える会話テーマアプリ。3Dサイコロとカードデッキで話題をランダムに決められます。無料・登録不要。',
          ogLocale: 'ja_JP',
        },
        logoAlt: 'Talk Shuffle アプリアイコン',
        tagline: '会話のテーマを、3Dサイコロとカードでサッと決める',
        ctaAppStore: 'App Store で無料ダウンロード',
        ctaWeb: 'ブラウザ版を試す',
        aboutTitle: 'Talk Shuffle とは',
        aboutBody: {
          html: true,
          text: 'Talk Shuffle は、会話のテーマを決めたいときに使える<strong>トーク支援アプリ</strong>です。3Dサイコロでランダムにお題を引くほか、目的別のカードデッキも搭載しています。アカウント登録不要で、個人データを外部サーバーへ送信しません。',
        },
        featuresTitle: '主な機能',
        feature1: '3Dサイコロでテーマをランダムに決定',
        feature2: 'テーマ候補のカスタマイズ（ドラッグ&ドロップ）',
        feature3: '価値観・チェックイン・1on1・グループディスカッションなど目的別デッキ',
        feature4: '参加人数・プレイヤー名・タイマー設定',
        feature5: 'セッション履歴（端末内保存）',
        feature6: '日本語 / 英語対応',
        scenesTitle: 'こんな場面で',
        scene1: '会議前のチェックイン・会議後の振り返り',
        scene2: '1on1 や自己内省のきっかけ作り',
        scene3: 'チームビルディングやアイスブレイク',
        scene4: '友人との雑談や創作活動のテーマ決め',
        privacyTitle: 'プライバシー',
        privacyBody: {
          html: true,
          text: 'Talk Shuffle はアカウント登録なしで利用できます。セッション履歴は端末内にのみ保存され、外部サーバーへ個人データを送信しません。詳しくは<a href="privacy.html">プライバシーポリシー</a>をご覧ください。',
        },
        navAppStore: 'App Store',
        navSupport: 'サポート',
        navPrivacy: 'プライバシーポリシー',
      },
      en: {
        _meta: {
          title: 'Talk Shuffle — Conversation prompts with 3D dice',
          description:
            'Talk Shuffle helps teams pick conversation topics for check-ins, 1:1s, icebreakers, and casual chats. Roll 3D dice or draw themed card decks. Free, no sign-up.',
          ogLocale: 'en_US',
        },
        logoAlt: 'Talk Shuffle app icon',
        tagline: 'Pick conversation topics with 3D dice and card decks',
        ctaAppStore: 'Download free on the App Store',
        ctaWeb: 'Try in your browser',
        aboutTitle: 'What is Talk Shuffle?',
        aboutBody: {
          html: true,
          text: 'Talk Shuffle is a <strong>conversation starter app</strong> when you need a topic. Roll 3D dice for random prompts or use purpose-built card decks. No account required; personal data is not sent to external servers.',
        },
        featuresTitle: 'Features',
        feature1: 'Random topics with 3D dice',
        feature2: 'Customize topic lists (drag & drop)',
        feature3: 'Decks for values, check-ins, 1:1s, group discussion, and more',
        feature4: 'Player count, names, and timer settings',
        feature5: 'Session history (stored on device only)',
        feature6: 'Japanese and English',
        scenesTitle: 'Use it for',
        scene1: 'Meeting check-ins and retrospectives',
        scene2: '1:1s and personal reflection',
        scene3: 'Team building and icebreakers',
        scene4: 'Casual chats and creative prompts',
        privacyTitle: 'Privacy',
        privacyBody: {
          html: true,
          text: 'No account is required. Session history stays on your device only; we do not send personal data to external servers. See the <a href="privacy.html">Privacy Policy</a> for details.',
        },
        navAppStore: 'App Store',
        navSupport: 'Support',
        navPrivacy: 'Privacy Policy',
      },
    },
    privacy: {
      ja: {
        _meta: {
          title: 'プライバシーポリシー - Talk Shuffle',
          description:
            'Talk Shuffle アプリのプライバシーポリシー。会話テーマ支援アプリのデータ取り扱いについて。',
        },
        navTop: 'Talk Shuffle トップ',
        navAppStore: 'App Store',
        h1: 'プライバシーポリシー',
        updated: '最終更新日: 2025年3月',
        s1Title: '1. はじめに',
        s1Body:
          'Talk Shuffle（以下「本アプリ」）は、会話のテーマを決める際の支援を目的としたアプリです。本プライバシーポリシーは、本アプリにおける利用者情報の取り扱いについて説明します。',
        s2Title: '2. 収集するデータ',
        s2Body:
          '本アプリは、利用者を特定する個人情報を収集しません。アカウント登録も不要です。',
        s3Title: '3. 端末内でのデータ保存',
        s3Body:
          'セッション履歴（使用したテーマや日時など）は、本アプリを利用している端末内にのみ保存されます。これらのデータは外部サーバーへ送信されません。',
        s4Title: '4. 外部へのデータ送信',
        s4Body:
          '本アプリは、個人を特定できる情報を外部のサーバーや第三者へ送信しません。アプリの利用状況の分析や広告配信の目的でデータを収集することもありません。',
        s5Title: '5. サードパーティサービス',
        s5Body:
          '本アプリは、現時点ではサードパーティの分析ツールや広告ネットワークを含んでいません。将来的にこれらを導入する場合は、本ポリシーを更新してお知らせします。',
        s6Title: '6. お問い合わせ',
        s6Body: {
          html: true,
          text: '本プライバシーポリシーに関するご質問は、<a href="support.html">サポートページ</a>からお問い合わせください。',
        },
        s7Title: '7. ポリシーの変更',
        s7Body:
          '本プライバシーポリシーは、必要に応じて変更することがあります。重要な変更がある場合は、アプリ内または本ページでお知らせします。',
        footer: {
          html: true,
          text: '<a href="/">トップに戻る</a> · <a href="' +
            APP_STORE_JA +
            '">App Store でダウンロード</a>',
        },
      },
      en: {
        _meta: {
          title: 'Privacy Policy - Talk Shuffle',
          description:
            'Privacy Policy for Talk Shuffle, a conversation prompt app. How we handle your data.',
        },
        navTop: 'Talk Shuffle home',
        navAppStore: 'App Store',
        h1: 'Privacy Policy',
        updated: 'Last updated: March 2025',
        s1Title: '1. Introduction',
        s1Body:
          'Talk Shuffle (the "App") helps you choose conversation topics. This Privacy Policy explains how we handle information when you use the App.',
        s2Title: '2. Data we collect',
        s2Body:
          'The App does not collect personally identifiable information. No account sign-up is required.',
        s3Title: '3. Data stored on your device',
        s3Body:
          'Session history (topics used, dates, etc.) is stored only on the device where you use the App. This data is not sent to external servers.',
        s4Title: '4. Data sent externally',
        s4Body:
          'The App does not send personally identifiable information to external servers or third parties. We do not collect data for analytics or advertising.',
        s5Title: '5. Third-party services',
        s5Body:
          'The App currently does not include third-party analytics or ad networks. If we add them in the future, we will update this policy.',
        s6Title: '6. Contact',
        s6Body: {
          html: true,
          text: 'For questions about this Privacy Policy, please contact us via the <a href="support.html">Support page</a>.',
        },
        s7Title: '7. Changes to this policy',
        s7Body:
          'We may update this Privacy Policy as needed. Material changes will be announced in the App or on this page.',
        footer: {
          html: true,
          text: '<a href="/">Back to home</a> · <a href="' +
            APP_STORE_EN +
            '">Download on the App Store</a>',
        },
      },
    },
    support: {
      ja: {
        _meta: {
          title: 'サポート - Talk Shuffle',
          description:
            'Talk Shuffle アプリのサポート・お問い合わせ。会話テーマ支援アプリのFAQと連絡先。',
        },
        navTop: 'Talk Shuffle トップ',
        navAppStore: 'App Store',
        h1: 'サポート',
        contactTitle: 'お問い合わせ',
        contactIntro:
          '不具合の報告、機能のご要望、その他のお問い合わせは、以下までご連絡ください。',
        contactEmailLabel: 'メール:',
        faqTitle: 'よくある質問',
        faq1Q: 'Q: アカウント登録は必要ですか？',
        faq1A:
          'A: いいえ、不要です。アプリを起動するだけでご利用いただけます。',
        faq2Q: 'Q: データはどこに保存されますか？',
        faq2A:
          'A: セッション履歴は端末内にのみ保存されます。外部サーバーへは送信されません。',
        linksTitle: '関連リンク',
        linksBody: {
          html: true,
          text: '<a href="privacy.html">プライバシーポリシー</a> · <a href="/">トップ</a> · <a href="' +
            APP_STORE_JA +
            '">App Store でダウンロード</a>',
        },
      },
      en: {
        _meta: {
          title: 'Support - Talk Shuffle',
          description:
            'Support and contact for Talk Shuffle. FAQ and how to reach us.',
        },
        navTop: 'Talk Shuffle home',
        navAppStore: 'App Store',
        h1: 'Support',
        contactTitle: 'Contact',
        contactIntro:
          'For bug reports, feature requests, or other inquiries, please email:',
        contactEmailLabel: 'Email:',
        faqTitle: 'FAQ',
        faq1Q: 'Q: Do I need an account?',
        faq1A: 'A: No. Just open the app and start using it.',
        faq2Q: 'Q: Where is my data stored?',
        faq2A:
          'A: Session history is stored only on your device. Nothing is sent to external servers.',
        linksTitle: 'Related links',
        linksBody: {
          html: true,
          text: '<a href="privacy.html">Privacy Policy</a> · <a href="/">Home</a> · <a href="' +
            APP_STORE_EN +
            '">Download on the App Store</a>',
        },
      },
    },
  };
})();
