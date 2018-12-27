import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

import {
  AppBar,
  AragonApp,
  Button,
  AppView,
  PublicUrl,
  observe,
  Field,
  Text,
  TextInput,
  EmptyStateCard,
  BaseStyles,
  SidePanel,
  theme,
  Table,
  TableRow,
  TableHeader,
} from '@aragon/ui'

import TokenBadge from './components/TokenBadge'
import HolderRow from './components/HolderRow'

import addFundsIcon from './components/assets/add-funds-icon.svg'


import NewTransferPanelContent from './components/NewTransfer/PanelContent'
import { makeEtherscanBaseUrl } from './utils'
import { networkContextType } from './provide-network'


const AppContainer = styled(AragonApp)`
  display: flex;
`

class App extends React.Component {
  static propTypes = {
    app: PropTypes.object.isRequired,
    proxyAddress: PropTypes.string,
  }
  static defaultProps = {
    appStateReady: false,
    holders: [],
    network: {},
    userAccount: '',
    groupMode: false,
    tokenName: '',
    transactions: []
  }

  state = {
    sidepanelOpened: false,
  }

  static childContextTypes = {
    network: networkContextType,
  }

  getChildContext() {
    const { network } = this.props

    return {
      network: {
        etherscanBaseUrl: makeEtherscanBaseUrl(network.type),
        type: network.type,
      },
    }
  }

  handleSidepanelOpen = () => {
    this.setState({ sidepanelOpened: true })
  }
  handleSidepanelClose = () => {
    this.setState({ sidepanelOpened: false })
  }

  handleChange(event) {
    this.setState({ [event.target.id]: event.target.value });
  }

  handleSubmit(event) {
    if (event.target.id === "mint") {
      this.props.app.mint(this.state.to, this.state.tokenid)
    }
  }

  handleLaunchMintToken = address => {
    this.setState({
      assignTokensConfig: { holderAddress: address },
      sidepanelOpened: true,
    })
  }

  handleMint = ({ holder, tokenId }) => {
    const { app } = this.props
    app.mint(holder, tokenId)
    this.handleSidepanelClose()
  }

  handleBurn = ({ holder, tokenId }) => {
    const { app } = this.props
    app.burn(holder, tokenId)
    this.handleSidepanelClose()
  }

  handleSidepanelClose = () => {
    this.setState({ sidepanelOpened: false })
  }


  render() {
    const { sidepanelOpened } = this.state
    const { app, tokenName, tokenSymbol, network, totalSupply, transactions, proxyAddress } = this.props

    return (
      <PublicUrl.Provider url="./aragon-ui/">
        <BaseStyles />
        <Main>
          <AppView
            appBar={
              <AppBar
                title="Aragon Non Fungible Token Dashboard"
                endContent={
                  <Button mode="strong" onClick={this.handleSidepanelOpen}>
                    Mint/Burn NFTs
                </Button>
                }
              />
            }
          >

            {transactions.length === 0 && (
              <EmptyScreen>
                <EmptyStateCard
                  icon={<img src={addFundsIcon} alt="" />}
                  title="Add NFTs to your organization"
                  text="There are no NFTs yet - add non fungible tokens easily"
                  actionText="Mint"
                  onActivate={this.handleSidepanelOpen}
                />
              </EmptyScreen>
            )}

            {transactions.length > 0 && (
              <TwoPanels>
                <Main>
                  <Table
                    header={
                      <TableRow>
                        <TableHeader title="Owner" />
                        <TableHeader title="Token  id" align="right" />
                        <TableHeader title="" />
                      </TableRow>
                    }
                  >

                    {transactions.length > 0 && (
                      transactions.reverse().slice(0, 15).map(({ id, to }) => (
                        <HolderRow
                          key={id}
                          owner={to}
                          id={id}
                          address={proxyAddress}
                          network={network}
                        />
                      )))}

                  </Table>
                </Main>
                <Info>
                  <Part>
                    <h1>
                      <Text color={theme.textSecondary} smallcaps>
                        Token Info
                  </Text>
                    </h1>
                    <ul>

                      <InfoRow>
                        <span>Total Supply</span>
                        <span>:</span>
                        <strong>{totalSupply}</strong>
                      </InfoRow>
                      <InfoRow>
                        <span>Token name</span>
                        <span>:</span>
                        <strong>{tokenName}</strong>
                      </InfoRow>
                      <InfoRow>
                        <span>Token Symbol</span>
                        <span>:</span>
                        <strong>{tokenSymbol}</strong>
                      </InfoRow>
                      <InfoRow>
                        <span>Token</span>
                        <span>:</span>
                        <TokenBadge
                          address={proxyAddress}
                          name={tokenName}
                          symbol={tokenSymbol}
                          network={network}
                        />
                      </InfoRow>
                    </ul>
                  </Part>
                </Info>
              </TwoPanels>
            )}
          </AppView>

          <SidePanel
            opened={sidepanelOpened}
            onClose={this.handleSidepanelClose}
            onTransitionEnd={this.handleSidepanelTransitionEnd}
            title="Mint/Burn NFTs"
          >
            <NewTransferPanelContent
              app={app}
              opened={sidepanelOpened}
              onMint={this.handleMint}
              onBurn={this.handleBurn}
            />
          </SidePanel>


        </Main>
      </PublicUrl.Provider >
    )
  }
}

const Main = styled.div`
width: 100%;
`

const EmptyScreen = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  flex-grow: 1;
`

const Info = styled.aside`
  flex-shrink: 0;
  flex-grow: 0;
  width: 260px;
  margin-left: 30px;
  min-height: 100%;
`

const TwoPanels = styled.div`
        display: flex;
        width: 100%;
        min-width: 800px;
      `

const Part = styled.section`
      margin-bottom: 55px;
      h1 {
        margin-bottom: 15px;
        color: ${theme.textSecondary};
        text-transform: lowercase;
        line-height: 30px;
        font-variant: small-caps;
        font-weight: 600;
        font-size: 16px;
        border-bottom: 1px solid ${theme.contentBorder};
      }
  `

const InfoRow = styled.li`
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    list-style: none;
    > span:nth-child(1) {
      font-weight: 400;
      color: ${theme.textSecondary};
    }
    > span:nth-child(2) {
      opacity: 0;
      width: 10px;
    }
    > span:nth-child(3) {
      flex-shrink: 1;
    }
    > strong {
      text-transform: uppercase;
    }
`

export default observe(
  observable =>
    observable.map(state => {
      const { tokenName, tokenSymbol, totalSupply, proxyAddress, transactions } = state || {}
      return {
        ...state,

      }
    }),
  {}
)(App)