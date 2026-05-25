/**
 * Talk Shuffle static pages: ?lang=en | ?lang=ja (default ja).
 * Does not use navigator.language — portfolio passes ?lang=en explicitly.
 */
(function (global) {
  const SUPPORTED = new Set(['en', 'ja']);

  function getLang() {
    const params = new URLSearchParams(window.location.search);
    const lang = (params.get('lang') || '').toLowerCase();
    return SUPPORTED.has(lang) ? lang : 'ja';
  }

  function withLang(url, lang) {
    lang = lang || getLang();
    if (lang === 'ja') {
      return url;
    }
    try {
      const u = new URL(url, window.location.href);
      u.searchParams.set('lang', 'en');
      return u.pathname + u.search + u.hash;
    } catch (_) {
      const sep = url.indexOf('?') >= 0 ? '&' : '?';
      return url + sep + 'lang=en';
    }
  }

  function applyPage(pageId, pages) {
    const lang = getLang();
    const dict = (pages[pageId] && pages[pageId][lang]) || pages[pageId].ja;
    document.documentElement.lang = lang === 'en' ? 'en' : 'ja';

    Object.entries(dict).forEach(function (entry) {
      const key = entry[0];
      const value = entry[1];
      if (key.indexOf('_') === 0) {
        return;
      }
      document.querySelectorAll('[data-i18n="' + key + '"]').forEach(function (el) {
        var text = value && (value.text !== undefined ? value.text : value);
        if (el.tagName === 'IMG' && el.getAttribute('data-i18n-attr')) {
          el.setAttribute(el.getAttribute('data-i18n-attr'), text);
          return;
        }
        if (value && value.html) {
          el.innerHTML = text;
        } else {
          el.textContent = text;
        }
      });
    });

    var meta = dict._meta;
    if (meta) {
      if (meta.title) {
        document.title = meta.title;
      }
      if (meta.description) {
        var desc = document.querySelector('meta[name="description"]');
        if (desc) desc.setAttribute('content', meta.description);
      }
      if (meta.ogLocale) {
        var og = document.querySelector('meta[property="og:locale"]');
        if (og) og.setAttribute('content', meta.ogLocale);
      }
    }

    document.querySelectorAll('[data-lang-href]').forEach(function (el) {
      var base = el.getAttribute('data-lang-href');
      if (base) {
        el.setAttribute('href', withLang(base, lang));
      }
    });

    document.querySelectorAll('a[href]').forEach(function (el) {
      var href = el.getAttribute('href');
      if (!href || href.indexOf('mailto:') === 0 || href.indexOf('http') === 0) {
        return;
      }
      if (
        href === 'app.html' ||
        href === 'index.html' ||
        href === 'privacy.html' ||
        href === 'support.html' ||
        href === '/' ||
        href.indexOf('app.html') >= 0 ||
        href.indexOf('index.html') >= 0 ||
        href.indexOf('privacy.html') >= 0 ||
        href.indexOf('support.html') >= 0
      ) {
        el.setAttribute('href', withLang(href, lang));
      }
    });
  }

  global.TalkShuffleLang = {
    getLang: getLang,
    withLang: withLang,
    applyPage: applyPage,
  };
})(typeof window !== 'undefined' ? window : globalThis);
