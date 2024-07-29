// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface CARNFTInterface is IERC1155 {
    function ownersOf(uint256 id) external view returns (address[] memory);
}

contract CarLeasing is Ownable {
    CARNFTInterface public carNFT;
    IERC20 public paymentToken;
    uint256 public rentalRatePerSecond; // Fixed price per hour for leasing
    address public rentWallet;

    struct Rental {
        address renter;
        uint256 startTime;
        bool isActive;
    }
    // Mapping car ID to Rental
    mapping(uint256 => Rental) public rentals;

    // Mapping car ID to earnings for distributing to correct NFT investors
    mapping(uint256 => uint256) public earnings;

     modifier onlyRenter(uint256 carId) {
        require(rentals[carId].isActive, "Car is not rented");
        require(rentals[carId].renter == msg.sender, "Caller is not the renter");
        _;
    }

    event CarRented(
        address indexed renter,
        uint256 indexed carId,
        uint256 startTime
    );
    event CarReturned(
        address indexed renter,
        uint256 indexed carId,
        uint256 endTime,
        uint256 fee
    );
    event NFTCollectionUpdated(address indexed oldAddress, address indexed newAddress);
    event PaymentTokenUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );
    event RentWalletUpdated(address indexed oldAddress, address indexed newAddress);
    
    constructor(
        CARNFTInterface _carNFT,
        IERC20 _paymentToken,
        uint256 _rentalRatePerSecond,
        address _rentwallet

    ) Ownable() {
        carNFT = _carNFT;
        paymentToken = _paymentToken;
        rentalRatePerSecond = _rentalRatePerSecond;
         rentWallet = _rentwallet;
    }


    function rentCar(uint256 carId) external {
        require(carExists(carId), "car doesn't exist");
        require(!rentals[carId].isActive, "Car is already rented");
        require(paymentToken.balanceOf(msg.sender) >= 3_600e18, "You need at least one day's worth of tokens for renting.");

        rentals[carId] = Rental({
            renter: msg.sender,
            startTime: block.timestamp,
            isActive: true
        });

        emit CarRented(msg.sender, carId, block.timestamp);
    }

    function returnCar(uint256 carId) public onlyRenter(carId) {
      
        uint256 rentalDuration = block.timestamp - rentals[carId].startTime;
        uint256 rentalFee = calculateRentalFee(rentalDuration);
        
        require(paymentToken.balanceOf(msg.sender) >= rentalFee, "Insufficient deposited balance");
        require(
            paymentToken.transferFrom(msg.sender, rentWallet, rentalFee),
            "Payment transfer failed"
        );

       // reset struct
        rentals[carId].isActive = false;
        rentals[carId].renter = address(0);
        rentals[carId].startTime = 0;

        earnings[carId] += rentalFee;   //add total earnings for that car
        emit CarReturned(msg.sender, carId, block.timestamp, rentalFee);
    }

    function distributeToInvestors(uint256 tokenId)
        public
        onlyOwner
    {
        uint256 amount = earnings[tokenId];
        require(amount >= 100e18, "Not enough tokens earned by this token ID");   //min 100 tokens  to distribute
        address[] memory owners = carNFT.ownersOf(tokenId);
        
        require(owners.length > 0, "No owners found for this token ID");

        uint256 distributionAmount = (amount * 95) / 100;  // keep 5% to owner /company tax . distribute the 95%
        uint256 amountPerOwner = distributionAmount / owners.length;

        for (uint256 i = 0; i < owners.length; i++) {
            require(
                paymentToken.transferFrom(rentWallet, owners[i], amountPerOwner),
                "Payment transfer failed"
            );
        }
         // Reset the earnings for the tokenId after distribution
        earnings[tokenId] = 0;
    }

    function calculateRentalFee(uint256 duration)
        internal
        view
        returns (uint256)
    {
        return (duration / 1 seconds) * rentalRatePerSecond;
    }

    function carExists(uint256 id) public view returns (bool) {
        address[] memory owners = carNFT.ownersOf(id);
        return owners.length > 0;
    }

    function updateRentalRate(uint256 newRate) external onlyOwner {
        rentalRatePerSecond = newRate;
    }

    function updateNFTCollection(address newNFTCollection) external onlyOwner {
        require(newNFTCollection != address(0), "Invalid address");

        address oldCarToken = address(carNFT);
        carNFT = CARNFTInterface(newNFTCollection);
        emit NFTCollectionUpdated(oldCarToken, newNFTCollection);
    }

    function updatePaymentToken(address newPaymentToken) external onlyOwner {
        require(newPaymentToken != address(0), "Invalid address");

        address oldPaymentToken = address(paymentToken);
        paymentToken = IERC20(newPaymentToken);
        emit PaymentTokenUpdated(oldPaymentToken, newPaymentToken);
    }

    function updateRentWallet(address newRentWallet) external onlyOwner {

        require(newRentWallet != address(0), "Invalid address");

        address oldRentWallet = rentWallet;
        rentWallet = newRentWallet;
        emit RentWalletUpdated(oldRentWallet, newRentWallet);
    }

}