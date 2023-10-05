//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

abstract contract Context {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }

   function _msgData() internal view virtual returns (bytes calldata) {
       this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
       return msg.data;
   }

   function _msgValue() internal view virtual returns (uint256 value) {
       return msg.value;
   }
}

abstract contract Owner is Context {
   address public owner;

   constructor () {
       owner = _msgSender();
   }

   /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_msgSender() == owner);
        _;
    }

    /**
     * @dev Check if the current caller is the contract owner.
     */
     function isOwner() internal view returns(bool) {
         return owner == _msgSender();
     }
}

contract AdLibrary is Owner {

    struct Ad {
        string company;
        string description;
        uint256 price;
        address owner;
    }
    uint256 public adId;
    mapping (uint256 => Ad) public ads;
    
    struct Tracking {
        uint256 adId;
        uint256 runs; // the number of times this ad has been run by a publisher
        uint256 profit;
    }
    uint256 public trackingId;
    mapping (uint256 => Tracking) public trackings;
    
    struct AdSpace {
        string publisher;
        string description;
        bool valid; // false if adspace has been filled
        uint256 price;
        address owner;
    }
    uint256 public adSpaceId;
    mapping (uint256 => AdSpace) public adspaces;
    

    function addAd(string memory company, string memory description, uint256 price) public returns (bool success) {
        Ad memory ad = Ad(company, description, price, _msgSender());
        ads[adId] = ad;
        return true;
    }
    
    function addAdSpace(string memory publisher, string memory description, uint256 price) public returns (bool success) {
        AdSpace memory adSpace = AdSpace(publisher, description, true, price, _msgSender());
        adspaces[adSpaceId] = adSpace;
        return true;
    }
    
    function runAd(uint256 _adId, uint256 bidPrice, uint256 _adSpaceId) public payable returns (bool) {
        Ad storage ad = ads[_adId];
        AdSpace storage space = adspaces[_adSpaceId];
        
        require(space.valid == true, "The ad space is not available.");
        require(bidPrice <= ad.price, "This payment is higher than the set ad price.");
        require(bidPrice >= space.price, "This payment is too low.");
        
        _sendTRX(space.owner, _msgValue());
        
        space.valid = false;
        
        return true;
    }
    
   /**
    * @dev Send TRX to the book's owner.
    */
   function _sendTRX(address receiver, uint256 value) internal {
       payable(address(uint160(receiver))).transfer(value);
   }
        
    
    

    
}