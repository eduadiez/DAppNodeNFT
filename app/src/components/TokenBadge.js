import React from 'react'
import styled from 'styled-components'
import { SafeLink } from '@aragon/ui'
import provideNetwork from '../provide-network'

class TokenBadge extends React.PureComponent {
  render() {
    const { address, name, symbol, network } = this.props
    return (
      <Main
        title={`${name} (${address})`}
        href={`${network.etherscanBaseUrl}/token/${address}`}
      >
        <Label>
          <NameWrapper>
            <Name>{name}</Name>
            {name !== symbol && <Symbol>({symbol})</Symbol>}
          </NameWrapper>
        </Label>
      </Main>
    )
  }
}

const Main = styled(SafeLink).attrs({ target: '_blank' })`
  overflow: hidden;
  display: flex;
  align-items: center;
  height: 24px;
  background: #daeaef;
  border-radius: 3px;
  cursor: pointer;
  text-decoration: none;
  padding: 0 8px;
`

const Label = styled.span`
  display: flex;
  align-items: center;
  white-space: nowrap;
  font-size: 15px;
  min-width: 0;
  flex-shrink: 1;
`

const NameWrapper = styled.span`
  flex-shrink: 1;
  display: flex;
  min-width: 0;
`

const Name = styled.span`
  flex-shrink: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 20%;
`

const Symbol = styled.span`
  flex-shrink: 0;
  margin-left: 5px;
`

export default provideNetwork(TokenBadge)