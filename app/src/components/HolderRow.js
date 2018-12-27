import React from 'react'
import styled from 'styled-components'
import {
    TableRow,
    TableCell,
    ContextMenu,
    ContextMenuItem,
    IconAdd,
    IconRemove,
    Badge,
    SafeLink,
    theme,
} from '@aragon/ui'

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

        const canAssign = true

        return (
            <TableRow>
                <TableCell>
                    <Owner>
                        <span>{owner}</span>
                    </Owner>
                </TableCell>
                <TableCell align="right">
                    <SafeLink href={`${network.etherscanBaseUrl}/token/${address}/?a=${id}`} target="_blank">
                        {id}
                    </SafeLink>
                </TableCell>
            </TableRow>
        )
    }
}

const ActionLabel = styled.span`
  margin-left: 15px;
`

const Owner = styled.div`
  display: flex;
  align-items: center;
  & > span:first-child {
    margin-right: 10px;
  }
`

const IconWrapper = styled.span`
  display: flex;
  align-content: center;
  margin-top: -3px;
  color: ${theme.textSecondary};
`

export default HolderRow