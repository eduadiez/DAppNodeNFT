import React from 'react'
import styled from 'styled-components'
import { Field, TextInput, Button, IconCross, Text } from '@aragon/ui'
import { isAddress } from '../../web3-utils'

const initialState = {
    tokenIdField: {
        error: null,
        value: '',
        warning: null,
        max: '',
    },
    holderField: {
        error: null,
        warning: null,
        value: '',
    },
}

class Mint extends React.Component {
    static defaultProps = {
        onMint: () => { },
    }
    state = {
        ...initialState,
    }

    handleHolderChange = event => {
        this.updateHolderAddress(event.target.value)
    }

    updateHolderAddress(value) {
        this.setState(({ holderField, tokenIdField }) => ({
            holderField: { ...holderField, value, error: null },
            tokenIdField: { ...tokenIdField }
        }))
    }

    handleTokenIdChange = event => {
        const { tokenIdField } = this.state
        this.setState({
            tokenIdField: { ...tokenIdField, value: event.target.value },
        })
    }

    filteredHolderAddress() {
        const { holderField } = this.state
        return holderField.value.trim()
    }

    filteredAmount() {
        const { tokenIdField } = this.state
        return tokenIdField.value.trim()
    }

    handleSubmit = event => {
        event.preventDefault()
        const holderAddress = this.filteredHolderAddress()

        const holderError = !isAddress(holderAddress) && `Recipient must be a valid Ethereum address.`

        if (isAddress(holderAddress)) {
            this.props.onMint({
                tokenId: this.filteredAmount(),
                holder: holderAddress,
            })
        } else {
            this.setState(({ holderField }) => ({
                holderField: {
                    ...holderField,
                    error: holderError,
                },
            }))
        }
    }

    render() {
        const { holderField, tokenIdField } = this.state

        const errorMessage = holderField.error || tokenIdField.error
        const warningMessage = holderField.warning || tokenIdField.warning

        return (
            <div>
                <form onSubmit={this.handleSubmit.bind(this)}>
                    <Field label='Recipient (must be a valid Ethereum address)' >
                        <TextInput
                            innerRef={element => (this.holderInput = element)}
                            value={holderField.value}
                            onChange={this.handleHolderChange}
                            required
                            wide
                        />
                    </Field>

                    <Field label='Token ID to assign' >
                        <TextInput.Number
                            value={tokenIdField.value}
                            onChange={this.handleTokenIdChange}
                            min='0'
                            max={tokenIdField.max}
                            disabled={tokenIdField.max === '0'}
                            step='1'
                            required
                            wide
                        />
                    </Field>
                    <Button
                        mode="strong"
                        type="submit"
                        disabled={tokenIdField.max === '0'}
                        wide
                    >
                        Mint Token
              </Button>
                    <Messages>
                        {errorMessage && <ErrorMessage message={errorMessage} />}
                        {warningMessage && <WarningMessage message={warningMessage} />}
                    </Messages>
                </form>
            </div>
        )
    }
}

const Messages = styled.div`
  margin-top: 15px;
`

const WarningMessage = ({ message }) => <Info.Action>{message}</Info.Action>

const ErrorMessage = ({ message }) => (
    <p>
        <IconCross />
        <Text size="small" style={{ marginLeft: '10px' }}>
            {message}
        </Text>
    </p>
)

export default Mint