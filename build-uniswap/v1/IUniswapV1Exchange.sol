pragma solidity ^0.8.0;

interface IUniswapV1Exchange {
  function setup ( address token_addr ) external;
  function addLiquidity ( uint256 min_liquidity, uint256 max_tokens, uint256 deadline ) external payable returns ( uint256 out );
  function removeLiquidity ( uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline ) external returns ( uint256 , uint256  );
  function __default__ (  ) external payable;
  function ethToTokenSwapInput ( uint256 min_tokens, uint256 deadline ) external payable returns ( uint256 out );
  function ethToTokenTransferInput ( uint256 min_tokens, uint256 deadline, address recipient ) external payable returns ( uint256 out );
  function ethToTokenSwapOutput ( uint256 tokens_bought, uint256 deadline ) external payable returns ( uint256 out );
  function ethToTokenTransferOutput ( uint256 tokens_bought, uint256 deadline, address recipient ) external payable returns ( uint256 out );
  function tokenToEthSwapInput ( uint256 tokens_sold, uint256 min_eth, uint256 deadline ) external returns ( uint256 out );
  function tokenToEthTransferInput ( uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient ) external returns ( uint256 out );
  function tokenToEthSwapOutput ( uint256 eth_bought, uint256 max_tokens, uint256 deadline ) external returns ( uint256 out );
  function tokenToEthTransferOutput ( uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient ) external returns ( uint256 out );
  function tokenToTokenSwapInput ( uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr ) external returns ( uint256 out );
  function tokenToTokenTransferInput ( uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr ) external returns ( uint256 out );
  function tokenToTokenSwapOutput ( uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr ) external returns ( uint256 out );
  function tokenToTokenTransferOutput ( uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr ) external returns ( uint256 out );
  function tokenToExchangeSwapInput ( uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr ) external returns ( uint256 out );
  function tokenToExchangeTransferInput ( uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr ) external returns ( uint256 out );
  function tokenToExchangeSwapOutput ( uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr ) external returns ( uint256 out );
  function tokenToExchangeTransferOutput ( uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr ) external returns ( uint256 out );
  function getEthToTokenInputPrice ( uint256 eth_sold ) external returns ( uint256 out );
  function getEthToTokenOutputPrice ( uint256 tokens_bought ) external returns ( uint256 out );
  function getTokenToEthInputPrice ( uint256 tokens_sold ) external returns ( uint256 out );
  function getTokenToEthOutputPrice ( uint256 eth_bought ) external returns ( uint256 out );
  function tokenAddress (  ) external returns ( address out );
  function factoryAddress (  ) external returns ( address out );
  function balanceOf ( address _owner ) external returns ( uint256 out );
  function transfer ( address _to, uint256 _value ) external returns ( bool out );
  function transferFrom ( address _from, address _to, uint256 _value ) external returns ( bool out );
  function approve ( address _spender, uint256 _value ) external returns ( bool out );
  function allowance ( address _owner, address _spender ) external returns ( uint256 out );
  function name (  ) external returns ( bytes32 out );
  function symbol (  ) external returns ( bytes32 out );
  function decimals (  ) external returns ( uint256 out );
  function totalSupply (  ) external returns ( uint256 out );
}
