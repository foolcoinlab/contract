pragma solidity ^0.4.21;

library Random {

    event RandomEvent(uint256 randomNumber);

    //just for test
    function randomEvent(uint256 upper, uint256 customSeed) public {
        uint256 rnd = randomWithSeed(upper, customSeed);
        emit RandomEvent(rnd);
    }

    function maxRandom(uint256 customSeed) internal view returns (uint256 randomNumber) {
        uint256 _seed = uint256(keccak256(
                block.blockhash(block.number - 1),
                block.coinbase,
                block.difficulty,
                customSeed
            ));
        return _seed;
    }

    // return a pseudo random number between lower and upper bounds
    // given the number of previous blocks it should hash.
    function random(uint256 upper) internal view returns (uint256 randomNumber) {
        return maxRandom(0) % upper + 1;
    }

    function randomWithSeed(uint256 upper, uint256 customSeed)  internal view returns (uint256 randomNumber) {
        return maxRandom(customSeed) % upper + 1;
    }
}