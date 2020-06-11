let $fundAtAGlance;
import {z, classKebab, useContext, useStream} from 'zorium';
import * as _ from 'lodash-es';

import $tags from 'frontend-shared/components/tags';
import $icon from 'frontend-shared/components/icon';
import {giveIconPath} from 'frontend-shared/components/icon/paths';
import FormatService from 'frontend-shared/services/format';

import colors, {nteeColors} from '../../colors';
import context from '../../context';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

const VISIBLE_FOCUS_AREAS_COUNT = 5;

export default $fundAtAGlance = function({placeholderNameStream, irsFund} ) {
  const {lang, router} = useContext(context);

  const {placeholderName} = useStream(() => ({
    placeholderName: placeholderNameStream
  }));

  // TODO: component for this? it's used in the results table too
  // focusAreas = _.orderBy irsFund?.fundedNteeMajors, 'count', 'desc'
  // tags = _.map focusAreas, ({key}) ->
  //   {
  //     text: lang.get "nteeMajor.#{key}"
  //     background: nteeColors[key].bg
  //     color: nteeColors[key].fg
  //   }


  return z('.z-fund-at-a-glance',
    z('.name', irsFund?.name || placeholderName),

    z('.block',
      z('.title', lang.get('general.location')),
      z('.text', FormatService.location(irsFund))),

    // unless _.isEmpty tags
    //   z '.block',
    //     z '.title', lang.get 'fund.focusAreas'
    //     z '.text',
    //       z $tags, {
    //         tags, fitToContent: true,isNoWrap: false,
    //         maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT
    //       }

    irsFund?.website ?
      z('.block',
        z('.title', lang.get('general.web')),
        router.link(z('a.text.link', {
          href: irsFund?.website
        },
          irsFund?.website)
        )
      ) : undefined,

    irsFund?.lastYearStats ?
      [
        z('.divider'),
        z('.grant-summary',
          z('.title',
            z('.icon',
              z($icon, {
                icon: giveIconPath,
                color: colors.$secondaryMain
              }
              )
            ),
            lang.get('fund.grantSummary')),
          z('.metric',
            z('.name', lang.get('fund.medianGrant')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.lastYearStats?.grantMedian))
          ),
          z('.metric',
            z('.name', lang.get('filter.grantCount')),
            z('.value',
              FormatService.abbreviateNumber(irsFund?.lastYearStats?.grants))
          ),
          z('.metric',
            z('.name', lang.get('filter.grantSum')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.lastYearStats?.grantSum))
          ),
          z('.metric',
            z('.name', lang.get('org.assets')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.assets))
          )
        )
      ] : undefined);
};
