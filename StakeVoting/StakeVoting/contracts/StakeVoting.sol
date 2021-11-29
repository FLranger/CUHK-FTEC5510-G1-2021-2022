// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.7.0;

// Stake-based Voting contract
contract StakeVoting {

  mapping (uint => uint) public weightedVotesReceived;
  uint[] public candidateRateList;
  bool isOn;
  /*
   * Due to float type is not well supported, 100 times finalRate is used here
   * to represent the percentage with 2 decimal.
   */
  uint finalRateX100;
  uint totalVotingTimes;

  constructor() public {
    isOn = true;
    finalRateX100 = 0;
    totalVotingTimes = 0;
  }

  function addCandidateRate(uint candidateRate) public {
    require(isOn, append("Voting is finished, the final rate is: ", finalRateToString(finalRateX100)));
    //require(!validCandidateRate(candidateRate));
    candidateRateList.push(candidateRate);
  }

  function voteForCandidateRate(uint candidateRate, uint stake) public {
    require(isOn, append("Voting is finished, the final rate is: ", finalRateToString(finalRateX100)));
    require(validCandidateRate(candidateRate));
    weightedVotesReceived[candidateRate]  += stake;
    totalVotingTimes ++;
  }

  function finishVoting() public returns (uint) {
    require(isOn, append("Voting is finished, the final rate is: ", finalRateToString(finalRateX100)));
    isOn = false;
    uint sumOfWeightedRate = 0;
    uint sumOfStake = 0;
    for(uint i = 0; i < candidateRateList.length; i++) {
      sumOfWeightedRate += weightedVotesReceived[candidateRateList[i]] * candidateRateList[i];
      sumOfStake += weightedVotesReceived[candidateRateList[i]];
    }
    finalRateX100 = sumOfWeightedRate * 100 / sumOfStake;
    return finalRateX100;
  }

  function getFinalRate() view public returns(string memory) {
    require(!isOn, "Voting is not finished.");
    return finalRateToString(finalRateX100);
  }

  function validCandidateRate(uint candidateRate) view public returns (bool) {
    for(uint i = 0; i < candidateRateList.length; i++) {
      if (candidateRateList[i] == candidateRate) {
        return true;
      }
    }
    return false;
  }

  function append(string memory a, string memory b) internal pure returns (string memory) {
    return string(abi.encodePacked(a, b));
  }

  function finalRateToString(uint _finalRateX100) internal pure returns (string memory) {
    // full stop sign "."
    bytes memory bstrFullStopSign = new bytes(1);
    bstrFullStopSign[0] = byte(uint8(46));
    string memory fullStopSign = string(bstrFullStopSign);
    // percent sign "%"
    bytes memory bstrPercentSign = new bytes(1);
    bstrPercentSign[0] = byte(uint8(37));
    string memory percentSign = string(bstrPercentSign);
    return append(append(uintToString(_finalRateX100 / 100), fullStopSign), append(uintToString(_finalRateX100 % 100), percentSign));
  }

  function uintToString(uint _i) internal pure returns (string memory) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}