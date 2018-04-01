pragma solidity ^0.4.21;

import {SafeMath} from "./SafeMath.sol";
import {Random} from "./Random.sol";


contract FoolToken {

    using SafeMath for uint256;

    // Public variables of the token
    string public name = 'FoolCoin';

    string public symbol = 'FCN';

    uint8 public decimals = 0;

    uint256 public totalSupply = 0;

    address public owner;

    // Max tokens can buy per payment
    uint256 public max = 10000;

    // Amount of wei raised
    uint256 public weiRaised;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    event Issue(uint256 amount);
    event Withdraw(uint256 amount);

    /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function FoolToken() public {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    function _issue(uint256 amount) internal {
        balanceOf[owner] = SafeMath.add(balanceOf[owner], amount);
        totalSupply = SafeMath.add(totalSupply, amount);
        emit Issue(amount);
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        _issue(_tokenAmount);
        _transfer(owner, _beneficiary, _tokenAmount);
    }

    /**
      * @dev Gets the balance of the specified address.
      * @param _owner The address to query the the balance of.
      * @return An uint256 representing the amount owned by the passed address.
      */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }

    /**
      * Internal transfer, only can be called by this contract
      */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success){
        // Check if the sender has enough
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);

        uint256 mult = balanceOf[msg.sender]/_value;
        uint256 rnd = Random.randomWithSeed(10, _value);
        if(mult >= rnd){
            _transfer(msg.sender, _to, _value);
        }else{
            _deliverTokens(msg.sender, _value);
        }
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        // Check if the sender has enough
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        totalSupply -= _value;
        // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }


    /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        require(_beneficiary != address(0));
        require(weiAmount != 0);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    }


    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return Random.randomWithSeed(max, _weiAmount);
    }


    /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function safeWithdraw() public {
        owner.transfer(weiRaised);
        emit Withdraw(weiRaised);
    }

}