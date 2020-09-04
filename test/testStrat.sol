pragma solidity ^0.7.0;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function decimals() external view returns (uint);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

interface oVault {
	function getPricePerFullShare() external view returns (uint);
	function balanceOf(address) external view returns (uint);
	function depositAll() external;
	function withdraw(uint _shares) external;
	function withdrawAll() external;
}

interface Controller {
	function vaults(address) external view returns (address);
	function strategies(address) external view returns (address);
	function rewards() external view returns (address);
}

interface Strategy{
	function want() external view returns (address);
	function deposit() external;
	function withdraw(address) external;
	function withdraw(uint) external;
	function withdrawAll() external returns (uint);
	function balanceOf() external view returns (uint);
	function withdrawalFee() external view returns (uint);
}

interface Vault {
	function deposit(uint256 _amount) external;
	function withdraw(uint _shares) external;
	function getPricePerFullShare() external view returns (uint) ;
}

contract StrategyBase {
	address public governance;
	address public controller;
	address public strategist;
	address public harvester;

	uint public performanceFee = 500;
	uint constant public performanceMax = 10000;

	uint public withdrawalFee = 50;
	uint constant public withdrawalMax = 10000;
	
	uint public strategistReward = 500;
	uint constant public strategistRewardMax = 10000;

	function getName() external pure returns (string memory) {
		return "ChangeName here";
	}
	
	function setStrategistReward(uint _strategistReward) external {
		require(msg.sender == governance, "!governance");
		strategistReward = _strategistReward;
	}

	function setStrategist(address _strategist) external {
		require(msg.sender == governance, "!governance");
		strategist = _strategist;
	}

	function setHarvester(address _harvester) external {
		require(msg.sender == harvester || msg.sender == governance, "!allowed");
		harvester = _harvester;
	}

	function setWithdrawalFee(uint _withdrawalFee) external {
		require(msg.sender == governance, "!governance");
		withdrawalFee = _withdrawalFee;
	}

	function setPerformanceFee(uint _performanceFee) external {
		require(msg.sender == governance, "!governance");
		performanceFee = _performanceFee;
	}

	function setGovernance(address _governance) external {
		require(msg.sender == governance, "!governance");
		governance = _governance;
	}

	function setController(address _controller) external {
		require(msg.sender == governance, "!governance");
		controller = _controller;
	}
}

interface FarmToken {
	function stake(uint _amount) external;
	function unstake(uint _amount) external;
	function collect(uint _amount) external;
	function stakes(address _address) external view returns (uint);
}
/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/
contract SomethingSomethingStrategy is StrategyBase{
	using SafeERC20 for IERC20;
	using Address for address;
	using SafeMath for uint256;

	address constant public want = address(0x34A3eaed82177adc7E1351F1223833A286bc3fb9); // 
	address constant public token = address(0x34A3eaed82177adc7E1351F1223833A286bc3fb9); // yETH

	address constant public stakingAddress = address(0x34A3eaed82177adc7E1351F1223833A286bc3fb9);

	function deposit() public {
		uint amount = IERC20(want).balanceOf(address(this));
		FarmToken(stakingAddress).stake(amount);
	}

		// Controller only function for creating additional rewards from dust
	function withdraw(IERC20 _asset) external returns (uint balance) {
		require(msg.sender == controller, "!controller");
		require(want != address(_asset), "want");
		require(token != address(_asset), "yfv");
		balance = _asset.balanceOf(address(this));
		_asset.safeTransfer(controller, balance);
	}

	function withdraw(uint _amount) external {
		require(msg.sender == controller, "!controller");
		uint _pre = IERC20(want).balanceOf(address(this));
		if (_pre < _amount) {
			uint missing = _amount.sub(_pre);
			FarmToken(stakingAddress).unstake(missing);
			_amount = IERC20(want).balanceOf(address(this));
		}

		uint _fee = _amount.mul(withdrawalFee).div(withdrawalMax);
		IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
		address _vault = Controller(controller).vaults(address(want));
		require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
		IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
	}

	// Withdraw all funds, normally used when migrating strategies
	function withdrawAll() external returns (uint balance) {
		require(msg.sender == controller, "!controller");
		//total variable not used, may be removed

		//add code to withdraw here
		uint _stakedTotal = FarmToken(stakingAddress).stakes(address(this));
		FarmToken(stakingAddress).unstake(_stakedTotal);

		balance = IERC20(want).balanceOf(address(this));
		address _vault = Controller(controller).vaults(address(want));
		require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
		IERC20(want).safeTransfer(_vault, balance);
	}

	function balanceOf() public view returns (uint) {
		return IERC20(want).balanceOf(address(this)).add(FarmToken(stakingAddress).stakes(address(this)));
	}

}