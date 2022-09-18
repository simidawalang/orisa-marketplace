// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.4;

  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "./IWhitelist.sol";

  contract Orisa is ERC721Enumerable, Ownable {
      /**
       * @dev _baseTokenURI for generating the tokenURI, which is
       * a combination of the baseURI and the tokenId.
       */
      string _baseTokenURI;

      uint public _price = 0.01 ether;
      uint public maxTokenIds = 25;
      uint public tokenIds;

      bool public presaleStarted;
      bool public _paused;


      // Instance of whitelist contract
      IWhitelist whitelist;

      uint256 public presaleEnded;

      modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
          _;
      }

      constructor (string memory baseURI, address whitelistContract) ERC721("Orisa", "OS") {
          _baseTokenURI = baseURI;
          whitelist = IWhitelist(whitelistContract);
      }

      function startPresale() public onlyOwner {
          presaleStarted = true;
          presaleEnded = block.timestamp + 5 minutes;
      }

      /**
       * @dev mint one NFT per transaction to a whitelisted address during the presale.
       */
      function presaleMint() public payable onlyWhenNotPaused {
          require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
          require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
          require(tokenIds < maxTokenIds, "All Orisa NFTs have been minted.");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds++;

          _safeMint(msg.sender, tokenIds);
      }

      /**
      * @dev mint allows a user to mint 1 NFT per transaction after the presale has ended.
      */
      function mint() public payable onlyWhenNotPaused {
          require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
          require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          _safeMint(msg.sender, tokenIds);
      }

    
      function _baseURI() internal view virtual override returns (string memory) {
          return _baseTokenURI;
      }

      function setPaused(bool val) public onlyOwner {
          _paused = val;
      }

      /**
       * @dev Send all the ether in the contract to the contract owner
       */
      function withdraw() public onlyOwner  {
          address _owner = owner();
          uint256 amount = address(this).balance;
          (bool sent, ) =  _owner.call{value: amount}("");
          require(sent, "Failed to send Ether.");
      }

      
      receive() external payable {}

      fallback() external payable {}
  }