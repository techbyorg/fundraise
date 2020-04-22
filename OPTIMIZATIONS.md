- Reduce number of re-renders
  - Every component with state causes a rerender when state is initially set...
    - So opening a new overlay causes more than 1 render, when 1 should be enough


- Never set state to "isMounted" or "isVisible" in afterMount (for an animation)
  - just manually add the class in JS so as to not re-render entire page

- Reduce complexity of $app render since that one is guaranteed called every time.
  - overlays, drawer to own component state
  - though it might only save ~1ms or less

- Figure out how to render just child components and not the whole page for a child component changing
  - Zorium would need to be rewritten a good bit, since the actual re-render
    is done on the bound element (App). It's optimized in the sense that if
    component state isn't dirty, it uses cached version
  - Once that's done, the most common change to "app" component state is adding overlay
    - Should not re-render entire app/page to add those overlays

- separate vendor and client bundles
  - vendor bundle less likely to get updated frequently
  - https://calendar.perfplanet.com/2019/bundling-javascript-for-performance-best-practices/
  - probably doesn't actually make that big of a difference since these are fetched from service worker anyways (except for iOS app)

- Use JSON.parse for large objs (10kb+) instead of JSON obj where possible
  - counter-intuitive, but faster https://www.youtube.com/watch?v=ff4fgQxPaO0
  - webpack does automatically for imported JSON, but our concat'd JSON for lang strings doesn't...

- Keep components simple if possible (no state)
  - Will make it so vdom doesn't need to have unhook fn


- Test using .publishReplay(1).refCount() in places where a mapped observable is subscribed to multiple times
- Unrelated to speed, need to swap localStorage with something else in native iOS app (gets cleared too often)
- Set user and entityUser in avatar header instead of as props
- https://github.com/IguMail/socketio-shared-webworker
- optimize FormattedMessage. markdown parser is slow (1-5ms per message)
