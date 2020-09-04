pragma solidity ^0.7.0;

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library Address {
	function isContract(address account) internal view returns (bool) {
		bytes32 codehash;
		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
		// solhint-disable-next-line no-inline-assembly
		assembly { codehash := extcodehash(account) }
		return (codehash != 0x0 && codehash != accountHash);
	}
	function toPayable(address account) internal pure returns (address payable) {
		return address(uint160(account));
	}
	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");

		// solhint-disable-next-line avoid-call-value
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}
}

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function decimals() external view returns (uint8);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
	using SafeMath for uint256;
	using Address for address;

	function safeTransfer(IERC20 token, address to, uint256 value) internal {
		callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

	function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
		callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
	}

	function safeApprove(IERC20 token, address spender, uint256 value) internal {
		require((value == 0) || (token.allowance(address(this), spender) == 0),
			"SafeERC20: approve from non-zero to non-zero allowance"
		);
		callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}
	function callOptionalReturn(IERC20 token, bytes memory data) private {
		require(address(token).isContract(), "SafeERC20: call to non-contract");

		// solhint-disable-next-line avoid-low-level-calls
		(bool success, bytes memory returndata) = address(token).call(data);
		require(success, "SafeERC20: low-level call failed");

		if (returndata.length > 0) { // Return data is optional
			// solhint-disable-next-line max-line-length
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
		}
	}
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}


contract ERC20 is IERC20, Context {

	using SafeMath for uint256;
	using Address for address;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;

	string private _name;
	string private _symbol;
	uint8 private _decimals;

	constructor (string memory name, string memory symbol, uint8 decimals) {
		_name = name;
		_symbol = symbol;
		_decimals = decimals;
	}
	
	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view virtual override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view virtual override returns (uint256) {
		return _balances[account];
	}

	function approve(address _spender, uint256 _amount) public virtual override returns (bool) {
		_approve(_msgSender(), _spender, _amount);
		return true;
	}

	function allowance(address _owner, address _spender) public view virtual override returns (uint256) {
		return _allowances[_owner][_spender];
	}

	function transfer(address _recipient, uint256 _amount) public virtual override returns (bool) {
		_transfer(_msgSender(), _recipient, _amount);
		return true;
	}


	function transferFrom(address _sender, address _recipient, uint256 _amount) public virtual override returns (bool) {
		_transfer(_sender, _recipient, _amount);
		_approve(_sender, _msgSender(), _allowances[_sender][_msgSender()].sub(_amount, "transfer from : allowance"));
		return true;
	}

	function _transfer(address _sender, address _recipient, uint256 _amount) internal virtual {
		require(_sender != address(0), "zero address");
		require(_recipient != address(0), "zero address");

		_balances[_sender] = _balances[_sender].sub(_amount, "!balance");
		_balances[_recipient] = _balances[_recipient].add(_amount);
		emit Transfer(_sender, _recipient, _amount);
	}

	function _approve(address _owner, address _spender, uint256 _amount) internal returns (bool) {
		require(_owner != address(0), "approve : zero address");
		require(_spender != address(0), "approve : zero address");

		_allowances[_owner][_spender] = _amount;
		emit Approval(_owner, _spender, _amount);
	}

	function _mint(address _account, uint256 _amount) internal virtual {
		require(_account != address(0), "mint: zero address");
		_totalSupply = _totalSupply.add(_amount);
		_balances[_account] = _balances[_account].add(_amount);
		emit Transfer(address(0), _account, _amount);
	}

	function _burn(address _account, uint256 _amount) internal virtual {
		require(_account != address(0), "burn : zero address");
		_balances[_account] = _balances[_account].sub(_amount, "burn : exceeds balance");
		_totalSupply = _totalSupply.sub(_amount);
		emit Transfer(_account, address(0), _amount);
	}
}

contract FarmToken is ERC20 {
	using SafeERC20 for IERC20;
	using Address for address;
	using SafeMath for uint256;

	address public owner;
	mapping (address => uint) public stakes;

	event Stake(uint amount);
	event Unstake(uint amount);

	constructor () ERC20(
		"farmToken",
		"FARM",
		18) {
		owner = msg.sender;
	}

	function mint(uint _amount) public {
		require (msg.sender == owner, "!owner");
		_mint(msg.sender, _amount);
	}

	function stake(uint _amount) public {
		stakes[msg.sender] = stakes[msg.sender].add(_amount);
		_transfer(msg.sender, address(this), _amount);
		emit Stake(_amount);
	}

	function unstake(uint _amount) public {
		stakes[msg.sender] = stakes[msg.sender].sub(_amount);
		_transfer(address(this), msg.sender, _amount);
		emit Unstake(_amount);
	}

	function collect() public {
		require (stakes[msg.sender] > 0, "!stake");
		_mint(msg.sender, stakes[msg.sender].mul(5).div(100));
	}

}