import "./Ownable.sol" ; 

pragma solidity ^0.5.9;

contract SPOT_Staking is Ownable {
    constructor() public{}
    
    uint256 public tokenID = 1001308 ; 
    bool public online = true ; 
    
    //Staking Defintions
    mapping (address => bool) public isMinting ; 
    mapping(address => uint256) public mintingAmount ;
    mapping(address => uint256) public mintingStart ; 
    
    uint public month = 2628000 ; 
    uint public year = 31540000 ; 
    
    uint public _lvl1 = 1000 ; 
    uint public _lvl2 = 5000 ; 
    uint public _lvl3 = 10000 ;
    
    modifier canStake() {
        require(online == true) ;
        _ ;
    }
    
    function flipswitch(bool _status) public onlyOwner {
        online = _status ; 
    }
    
    function transferToken(address payable toAddress, uint256 tokenValue, trcToken id) payable public onlyOwner {
        toAddress.transferToken(tokenValue, id);
    }
    
    function withdraw_trx(uint amount) public onlyOwner {
        msg.sender.transfer(amount) ; 
    }
    
    function getTokenBalance() public view returns (uint256) {
        return msg.sender.tokenBalance(tokenID) ; 
    }
    
    function setTokenID(uint _tokenID) public {
        tokenID = _tokenID ;
    }
    
    function update_lvl1(uint256 amount) public onlyOwner {
        _lvl1 = amount ; 
    }
    
    function update_lvl2(uint256 amount) public onlyOwner {
        _lvl2 = amount ; 
    }
    
    function update_lvl3(uint256 amount) public onlyOwner {
        _lvl3 = amount ; 
    }
    
    
    function startMint() canStake public payable {
        trcToken _id = msg.tokenid;
        uint256 _value = msg.tokenvalue;
        
        require(_id == tokenID) ; 
        
        require(_value >= _lvl1, "Not enough tokens to start staking");
        require(isMinting[msg.sender] == false, "Already staking") ;
        require(mintingStart[msg.sender] <= now, "Error getting staking timestamp") ; 
        
        isMinting[msg.sender] = true ; 
        mintingAmount[msg.sender] = _value; 
        mintingStart[msg.sender] = now ; 
    } 
    
    function stopMint() public payable {
        require(mintingStart[msg.sender] <= now) ; 
        require(isMinting[msg.sender] == true) ; 

        msg.sender.transferToken(getMintingReward(msg.sender), tokenID);
      
        mintingAmount[msg.sender] = 0 ; 
        isMinting[msg.sender] = false ; 
    }

    function getMintingReward(address minter) public view returns (uint256 __reward) {
        uint amount = mintingAmount[minter] ; 
        uint age = getCoinAge(minter) ; 
        
        if ((amount >= _lvl1) && (amount < _lvl2)) {
            if (age >= year) {
                return amount * 10938068976709838/10000000000000000 ;
            }
            
            return calc_lvl1(amount, age) ; 
        }
        
        if ((amount >= _lvl2) && (amount < _lvl3)) {
            if (age >= year) {
                return amount * 11268250301319698/10000000000000000 ; 
            }
            
            return calc_lvl2(amount, age) ; 
        }
        
        if (amount >= _lvl3) {
            if (age >= year) {
                return amount * 1195618171461534/10000000000000000 ; 
            }
            
            return calc_lvl3(amount, age) ;
        }
    }
    
    function calc_lvl1(uint amount, uint age) public view returns (uint256 reward) {
        uint256 exp = age/month ; 
        uint256 base = 10075 ; 
        return (amount * base**exp)/(10000**exp); 
    }
    
    function calc_lvl2(uint amount, uint age) public view returns (uint256 reward) {
        uint256 exp = age/month ; 
        uint256 base = 10100 ; 
        return (amount * base**exp)/(10000**exp) ;        
    }
    
    function calc_lvl3(uint amount, uint age) public view returns (uint256 reward) {
        uint256 exp = age/month ; 
        uint256 base = 10150 ; 
        return (amount * base**exp)/(10000**exp) ; 
    }
    
    function getCoinAge(address minter) public view returns(uint256 age){
        if (isMinting[minter] == true){
            return (now - mintingStart[minter]) ;
        }
        else {
            return 0 ;
        }
    }
    
}