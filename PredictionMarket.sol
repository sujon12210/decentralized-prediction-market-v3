// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PredictionMarket is ReentrancyGuard {
    enum MarketState { Open, Resolved, Cancelled }
    enum Outcome { None, Yes, No }

    struct Market {
        string question;
        uint256 resolutionTime;
        IERC20 collateralToken;
        uint256 totalYesTokens;
        uint256 totalNoTokens;
        Outcome winner;
        MarketState state;
    }

    mapping(uint256 => Market) public markets;
    mapping(uint256 => mapping(address => uint256)) public yesBalances;
    mapping(uint256 => mapping(address => uint256)) public noBalances;
    uint256 public marketCount;

    event MarketCreated(uint256 indexed id, string question);
    event TokensMinted(uint256 indexed id, address indexed user, uint256 amount);
    event MarketResolved(uint256 indexed id, Outcome winner);

    function createMarket(string memory _question, address _collateral, uint256 _duration) external {
        uint256 id = marketCount++;
        markets[id].question = _question;
        markets[id].collateralToken = IERC20(_collateral);
        markets[id].resolutionTime = block.timestamp + _duration;
        markets[id].state = MarketState.Open;

        emit MarketCreated(id, _question);
    }

    function mintOutcomeTokens(uint256 _id, uint256 _amount) external nonReentrant {
        Market storage m = markets[_id];
        require(m.state == MarketState.Open, "Market not open");
        
        m.collateralToken.transferFrom(msg.sender, address(this), _amount);
        
        yesBalances[_id][msg.sender] += _amount;
        noBalances[_id][msg.sender] += _amount;
        
        m.totalYesTokens += _amount;
        m.totalNoTokens += _amount;

        emit TokensMinted(_id, msg.sender, _amount);
    }

    function resolveMarket(uint256 _id, Outcome _winner) external {
        // In production, gated by Oracle role
        Market storage m = markets[_id];
        require(block.timestamp >= m.resolutionTime, "Too early");
        m.winner = _winner;
        m.state = MarketState.Resolved;

        emit MarketResolved(_id, _winner);
    }

    function redeem(uint256 _id) external nonReentrant {
        Market storage m = markets[_id];
        require(m.state == MarketState.Resolved, "Not resolved");
        
        uint256 payout = 0;
        if (m.winner == Outcome.Yes) {
            payout = yesBalances[_id][msg.sender];
            yesBalances[_id][msg.sender] = 0;
        } else if (m.winner == Outcome.No) {
            payout = noBalances[_id][msg.sender];
            noBalances[_id][msg.sender] = 0;
        }

        require(payout > 0, "No winning tokens");
        m.collateralToken.transfer(msg.sender, payout);
    }
}
