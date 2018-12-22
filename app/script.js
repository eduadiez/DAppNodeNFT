import '@babel/polyfill'

import Aragon from '@aragon/client'

const app = new Aragon()

const initialState = {
  totalSupply: 0
}
app.store(async (state, event) => {
  if (state === null) state = initialState

  switch (event.event) {
    case 'Transfer':
      return { totalSupply: await getTotalSupply() }
    default:
      return state
  }
})

function getTotalSupply() {
  // Get TotalSupply by calling the public getter
  return new Promise(resolve => {
    app
      .call('totalSupply')
      .first()
      .map(value => parseInt(value, 10))
      .subscribe(resolve)
  })
}
