import '@babel/polyfill'

import Aragon from '@aragon/client'
import { of } from './rxjs'

const INITIALIZATION_TRIGGER = Symbol('INITIALIZATION_TRIGGER')

const app = new Aragon()

/*
 * Calls `callback` exponentially, everytime `retry()` is called.
 *
 * Usage:
 *
 * retryEvery(retry => {
 *  // do something
 *
 *  if (condition) {
 *    // retry in 1, 2, 4, 8 seconds… as long as the condition passes.
 *    retry()
 *  }
 * }, 1000, 2)
 *
 */
const retryEvery = (callback, initialRetryTimer = 1000, increaseFactor = 5) => {
  const attempt = (retryTimer = initialRetryTimer) => {
    // eslint-disable-next-line standard/no-callback-literal
    callback(() => {
      console.error(`Retrying in ${retryTimer / 1000}s...`)

      // Exponentially backoff attempts
      setTimeout(() => attempt(retryTimer * increaseFactor), retryTimer)
    })
  }
  attempt()
}

// Get the token address to initialize ourselves
retryEvery(retry => {
  app
    .call('name')
    .first()
    .subscribe(initialize, err => {
      console.error(
        'Could not start background script execution due to the contract not loading the token:',
        err
      )
      retry()
    })
})

async function initialize(tokenName) {
  let tokenSymbol
  try {
    tokenSymbol = await loadTokenSymbol()
    app.identify(`${tokenSymbol}`)
  } catch (err) {
    console.error(
      `Failed to load information to identify app due to:`,
      err
    )
  }
  return createStore({ tokenName: tokenName, tokenSymbol: tokenSymbol })
}

// Hook up the script as an aragon.js store
async function createStore(tokenSettings) {
  const { tokenName, tokenSymbol } = tokenSettings

  return app.store(
    async (state, event) => {
      const { event: eventName } = event


      let nextState = {
        ...state,
      }

      if (!nextState.proxyAddress && event.address) {
        nextState = {
          ...nextState,
          proxyAddress: event.address
        }
      }
      if (eventName === INITIALIZATION_TRIGGER) {
        nextState = {
          ...nextState,
          tokenName,
          tokenSymbol,
          totalSupply: 0,
        }
      } else {
        switch (eventName) {
          case 'Transfer':
            nextState = await transfer(nextState, event)
            break
          default:
            break
        }
      }

      return nextState
    },
    [
      // Always initialize the store with our own home-made event
      of({ event: INITIALIZATION_TRIGGER }),
    ]
  )
}

async function transfer(state, { transactionHash, returnValues: { _from, _to, _tokenId } }, ) {
  const totalSupply = await getTotalSupply()
  const transactionDetails = {
    transactionHash,
    from: _from,
    to: _to,
    id: _tokenId,
  }
  const transactions = await updateTransactions(state, transactionDetails)

  return {
    ...state,
    totalSupply,
    transactions
  }
}

function loadTokenSymbol() {
  return new Promise((resolve, reject) => {
    app.call("symbol")
      .first()
      .subscribe(resolve, reject)
  })
}

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

function updateTransactions({ transactions = [] }, transactionDetails) {
  const transactionsIndex = transactions.findIndex(
    ({ id }) => id === transactionDetails.id
  )
  if (transactionsIndex === -1) {
    return transactions.concat(transactionDetails)
  } else {
    const newTransactions = Array.from(transactions)
    newTransactions[transactionsIndex] = transactionDetails
    return newTransactions
  }
}