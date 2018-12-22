import React from 'react'
import {
  AragonApp,
  Button,
  Text,
  TextInput,
  observe
} from '@aragon/ui'
import styled from 'styled-components'

const AppContainer = styled(AragonApp)`
  display: flex;
  padding: 30px;
`

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tokenid: '',
      to: '',
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({ [event.target.id]: event.target.value });
  }

  handleSubmit(event) {
    console.log(event.target.id)
    if (event.target.id === "mint") {
      this.props.app.mint(this.state.to, this.state.tokenid)
    }
  }

  render() {
    
  const style = {
    margin: '0.5em',
    paddingLeft: 10,
    listStyle: 'none'
  };
    return (
      <AppContainer>
        <div style={style}>
          <ObservedCount style={style} observable={this.props.observable} />
          <TextInput  style={style} id="to" placeholder="To" value={this.state.to} onChange={this.handleChange} wide />
          <TextInput  style={style} id="tokenid" placeholder="TokenID" value={this.state.tokenid} onChange={this.handleChange} type="number" wide />
          <Button  style={style} id="mint" onClick={this.handleSubmit}>Mint new NFTs</Button>
        </div>
      </AppContainer>
    )
  }
}

const ObservedCount = observe(
  (state$) => state$,
  { totalSupply: 0 }
)(
  ({ totalSupply }) => <Text.Block style={{ textAlign: 'center' }} size='xxlarge'>{totalSupply} Total AragonNFT minted</Text.Block>
)
