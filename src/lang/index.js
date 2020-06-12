import * as _ from 'lodash-es'

import config from '../config'

let files = {
  strings: null,
  paths: null
}

class Language {
  constructor () {
    this.getJsonString = this.getJsonString.bind(this)
  }

  getLangFiles (language) {
    return _.mapValues(files, (val, file) => {
      let languages
      if (!language || (file === 'paths')) {
        languages = config.LANGUAGES
      } else {
        languages = _.uniq([language, 'en'])
      }

      // always need en for fallback
      return _.reduce(languages, (obj, lang) => {
        // be explicit about /lang/ and .json so webpack can strip from prod
        obj[lang] = (() => {
          try {
            return require(`../lang/${lang}/${file}_${lang}.json`)
          } catch { return null }
        })()
        if (file === 'strings') {
          // add from frontend-shared
          // be explicit about /lang/ and .json so webpack can strip from prod
          const sharedLang = (() => {
            try {
              return require(`frontend-shared/lang/${lang}/${file}_${lang}.json`)
            } catch { return null }
          })()
          obj[lang] = _.defaults(obj[lang], sharedLang)
        }
        return obj
      }
      , {})
    })
  }

  // used by gulp to concat lang to bundle
  getJsonString (language) {
    files = this.getLangFiles(language)

    const str = JSON.stringify(files)
    return `if(typeof window !== 'undefined'){window.languageStrings=${str};} `
  }
}

export default new Language()
