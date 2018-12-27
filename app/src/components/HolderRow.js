import React from 'react'
import styled from 'styled-components'
import {
    TableRow,
    TableCell,
    SafeLink,
    theme,
} from '@aragon/ui'

import { makeEtherscanBaseUrl } from '../utils'

class HolderRow extends React.Component {
    static defaultProps = {
        owner: '',
        id: 0,
        address: '',
        network: '',
        onAssignTokens: () => { },
        onRemoveTokens: () => { },
    }
    handleAssignTokens = () => {
        const { owner, onAssignTokens } = this.props
        onAssignTokens(owner)
    }
    handleRemoveTokens = () => {
        const { owner, onRemoveTokens } = this.props
        onRemoveTokens(owner)
    }
    render() {
        const {
            owner,
            id,
            address,
            network

        } = this.props

        let baseLink = makeEtherscanBaseUrl(network.type);

        return (
            <TableRow>
                <TableCell>
                    <Owner>
                        <span>{owner}</span>
                    </Owner>
                </TableCell>
                <TableCell align="right">
                    <SafeLink href={`${baseLink}/token/${address}/?a=${id}`} target="_blank">
                        {id}
                    </SafeLink>
                </TableCell>
            </TableRow>
        )
    }
}


const Owner = styled.div`
  display: flex;
  align-items: center;
  & > span:first-child {
    margin-right: 10px;
  }
`

export default HolderRow