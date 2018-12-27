import React from 'react'
import styled from 'styled-components'
import { TabBar } from '@aragon/ui'

import Mint from './Mint'
import Burn from './Burn'

const initialState = {
    screenIndex: 0,
}

class PanelContent extends React.Component {
    static defaultProps = {
        onMint: () => { },
        onBurn: () => { },
        proxyAddress: null,
    }
    state = {
        ...initialState,
    }

    componentWillReceiveProps({ opened }) {
        if (!opened && this.props.opened) {
            // Panel closed: reset the state
            this.setState({ ...initialState })
        }
    }

    handleSelect = screenIndex => {
        this.setState({ screenIndex })
    }

    render() {
        const { screenIndex } = this.state
        const {
            app,
            opened,
            onMint,
            onBurn, 
            
        } = this.props

        return (
            <div>
                <TabBarWrapper>
                    <TabBar
                        items={['Mint', 'Burn']}
                        selected={screenIndex}
                        onSelect={this.handleSelect}
                    />
                </TabBarWrapper>
                {screenIndex === 0 && (
                    <Mint
                        app={app}
                        onMint={onMint}
                    />
                )}
                {screenIndex === 1 && (
                    <Burn
                        app={app}
                        onBurn={onBurn}
                    />
                )}
            </div>
        )
    }
}

const TabBarWrapper = styled.div`
  margin: 0 -30px 30px;
`

export default PanelContent