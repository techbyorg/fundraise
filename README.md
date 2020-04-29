#

## Manifesto
---

### Getting Started
`npm install`
`npm run dev`


### Commands
##### `npm run dev` - Starts the server, watching files

More to come soonish

- all BehaviorSubject / Observable named ____Stream (eg valueStream)
  - if it's something that can be either stream or String/Bool/Number (useStream doesn't care), call it ____Streamy
- all ReplaySubjects named ____Streams (eg valueStreams)
- $$ for dom refs (typically $$el)
- order
  - props
  - useRef
  - useMemo for all observable instantiation / state prep
  - useEffect
    - be explicity about return for beforeUnmount, or use beforeUnmount fn
    - always include return, even if no fn (return null)
  - useStream for state
  - usecallback functions
  - normal functions?
  - z


### Cleanup
Occassionally run node /usr/lib/node_modules/coffee-unused/index.js --src ./src and clean up unused vars

More for just clean code vs reduced bundle size. As of 1/19 have only done for src/models and it only saved ~120b gzipped
