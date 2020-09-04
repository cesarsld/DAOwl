/**
 *Submitted for verification at Etherscan.io on 2020-08-31
*/

pragma solidity ^0.5.17;

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
		(bool success, ) = recipient.call.value(amount)("");
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

interface Uni {
	function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
		external
		returns (uint[] memory amounts);
}

interface BPool {
	function swapExactAmountIn(
		address tokenIn,
		uint tokenAmountIn,
		address tokenOut,
		uint minAmountOut,
		uint maxPrice
	) external returns (uint tokenAmountOut, uint spotPriceAfter);

	function joinswapExternAmountIn(
		address tokenIn,
		uint tokenAmountIn,
		uint minPoolAmountOut
	) external returns (uint poolAmountOut);

	function exitswapExternAmountOut(
		address tokenOut,
		uint tokenAmountOut,
		uint maxPoolAmountIn
	) external returns (uint poolAmountIn);

	function exitswapPoolAmountIn(
		address tokenOut,
		uint poolAmountIn,
		uint minAmountOut
	) external returns (uint tokenAmountOut);

	function calcSingleOutGivenPoolIn(
		uint tokenBalanceOut,
		uint tokenWeightOut,
		uint poolSupply,
		uint totalWeight,
		uint poolAmountIn,
		uint swapFee
	) public pure returns (uint tokenAmountOut)

	function getDenormalizedWeight(address token) external view returns (uint);
	
	function totalSupply() external view returns (uint);

	// gives _totalWeight
	function getTotalDenormalizedWeight() external view returns (uint);

	function getSwapFee() external view returns (uint);

	function getBalance(address token) external view returns (uint);

}

/*
		tokenAmountOut = calcSingleOutGivenPoolIn(
							getBalance(want)
							outRecord.denorm, getDenormalizedWeight(want)
							totalSupply()
							getTotalDenormalizedWeight(), ok
							poolAmountIn, param
							getSwapFee() ok
						);
*/

interface RewardPool {
	function getReward() external returns (uint256);
	function exit() external;
	// does not work as this leads to 0x0 in reward pool
	function stakeReward() external;
	function stake(uint256 amount, address referrer) external;
	function withdraw(uint256 amount) external;
	function earned(address account) external view returns (uint256);
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

contract StrategyrewardPool {
	using SafeERC20 for IERC20;
	using Address for address;
	using SafeMath for uint256;

	address constant public want = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
	address constant public token = address(0x45f24BaEef268BB6d63AEe5129015d69702BCDfa); // yfv
	address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public yfv = address(0x45f24BaEef268BB6d63AEe5129015d69702BCDfa);


	address public rewardPool = address(0x10DD17eCfc86101Eab956E0A443cab3e9C62d9b4);
	address constant public bPool = address(0x10DD17eCfc86101Eab956E0A443cab3e9C62d9b4);

	uint public performanceFee = 500;
	uint constant public performanceMax = 10000;

	uint public withdrawalFee = 50;
	uint constant public withdrawalMax = 10000;
	
	uint public strategistReward = 1000;
	uint constant public strategistRewardMax = 10000;

	uint public bptStaked = 0;

	address public governance;
	address public controller;
	address public strategist;
	address public harvester;

	constructor(address _controller, address  _harvester) public {
		governance = msg.sender;
		strategist = msg.sender;
		harvester = _harvester;
		controller = _controller;
	}

	function getName() external pure returns (string memory) {
		return "StrategyYFVRewardPool";
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

	function _approveAll() external {
		IERC20(yfv).approve(bPool, uint(-1));
		IERC20(weth).approve(bPool, uint(-1));
		IERC20(bPool).approve(rewardPool, uint(-1));
	}

	function deposit() public {
		uint _token = IERC20(weth).balanceOf(address(this));
		uint _bpt = 0;
		if (_token > 0) {
			_bpt = BPool(bPool).joinswapExternAmountIn(weth, _token, 0);
			if (_bpt > 0) {
				bptStaked = bptStaked.add(_bpt);
				// can refer strategist if possible
				RewardPool(rewardPool).stake(_bpt, address(0));
			}
		}
	}

	// Controller only function for creating additional rewards from dust
	function withdraw(IERC20 _asset) external returns (uint balance) {
		require(msg.sender == controller, "!controller");
		require(want != address(_asset), "want");
		require(yfv != address(_asset), "yfv");
		balance = _asset.balanceOf(address(this));
		_asset.safeTransfer(controller, balance);
	}

	// Withdraw partial funds, normally used with a vault withdrawal
	// withdraw _amount of weth out
	function withdraw(uint _amount) external {
		require(msg.sender == controller, "!controller");
		uint _balance = IERC20(weth).balanceOf(address(this));
		if (_balance < _amount) {
			_amount = _withdrawSome(_amount.sub(_balance));
			_amount = _amount.add(_balance);
		}
		uint _fee = _amount.mul(withdrawalFee).div(withdrawalMax);
		IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
		address _vault = Controller(controller).vaults(address(want));
		require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

		IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
	}

	function _withdrawSome(uint256 _amount) internal returns (uint) {
		uint _removed = BPool(bPool).exitswapExternAmountOut(weth, _amount, bptStaked);
		bptStaked = bptStaked.sub(_removed);
		return _amount;
	}

	// Withdraw all funds, normally used when migrating strategies
	function withdrawAll() external returns (uint balance) {
		require(msg.sender == controller, "!controller");
		//total variable not used, may be removed
		uint total = BPool(bPool).exitswapPoolAmountIn(weth, bptStaked, 0);
		bptStaked = 0;
		balance = IERC20(want).balanceOf(address(this));
		address _vault = Controller(controller).vaults(address(want));
		require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
		IERC20(want).safeTransfer(_vault, balance);
	}

	// no other way to figure out 
	function balanceOf() public view returns (uint) {
		uint amount = BPool(bPool).calcSingleOutGivenPoolIn(
			BPool(bPool).getBalance(want),
			BPool(bPool).getDenormalizedWeight(want),
			BPool(bPool).totalSupply(),
			BPool(bPool).getTotalDenormalizedWeight(),
			bptStaked,
			BPool(bPool).getSwapFee();
		);
		return amount;
	}

	function getCurrentReward() public view returns (uint256) {
		return RewardPool(rewardPool).earned(address(this));
	}

	function harvest() public {
		require(msg.sender == strategist || msg.sender == harvester || msg.sender == governance, "!authorized");
		uint y = RewardPool(rewardPool).getReward();
		if (y > 0) {
			//risky line but at least guarantees the swap
			BPool(bPool).swapExactAmountIn(yfv, y, want, 0, uint(-1));
			uint _want = IERC20(want).balanceOf(address(this));
			if (_want > 0) {
				uint _fee = _want.mul(performanceFee).div(performanceMax);
				uint _strategistReward = _fee.mul(strategistReward).div(strategistRewardMax);
				IERC20(want).safeTransfer(strategist, _strategistReward);
				IERC20(want).safeTransfer(Controller(controller).rewards(), _fee.sub(_strategistReward));
				deposit();
				//return funds in the vault is another solution				
			}
		}
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