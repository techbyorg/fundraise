let $searchInput;
import {z, useRef, useLayoutEffect} from 'zorium';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $searchInput = function({placeholder, valueStream}) {
  // {value} = useStream ->
  //   value: valueStream

  const $$ref = useRef();

  useLayoutEffect(() => $$ref.current.focus()
  , []);

  return z('input.z-search-input', {
    ref: $$ref,
    placeholder,
    oninput(e) {
      return valueStream.next(e.target.value);
    }
  }
  );
};
