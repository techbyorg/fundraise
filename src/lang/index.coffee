import _defaults from 'lodash/defaults'
import _mapValues from 'lodash/mapValues'
import _reduce from 'lodash/reduce'
import _uniq from 'lodash/uniq'

import config from '../config'

files = {
  strings: null
  paths: null
}

class Language
  getLangFiles: (language) ->
    _mapValues files, (val, file) ->
      if not language or file is 'paths'
        languages = config.LANGUAGES
      else
        languages = _uniq([language, 'en'])

      # always need en for fallback
      _reduce languages, (obj, lang) ->
        obj[lang] = try require "./#{lang}/#{file}_#{lang}" \
                    catch e then null
        if file is 'strings'
          # add from frontend-shared
          sharedLang = try require "frontend-shared/lang/#{lang}/#{file}_#{lang}" \
                       catch e then null
          obj[lang] = _defaults obj[lang], sharedLang
        obj
      , {}

  # used by gulp to concat lang to bundle
  getJsonString: (language) =>
    files = @getLangFiles language

    str = JSON.stringify files
    "if(typeof window !== 'undefined'){window.languageStrings=#{str};} "

export default new Language()
