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
    uint256 public rentalRatePerHour; // Fixed price per hour for leasing
    struct Rental {
        address renter;
        uint256 startTime;
        bool isActive;
    }
// Mapping car ID to Rental
    mapping(uint256 => Rental) public rentals;


   event CarRented(address indexed renter, uint256 indexed carId, uint256 startTime);
    event CarReturned(address indexed renter, uint256 indexed carId, uint256 endTime, uint256 fee);
    event CarNFTUpdated(address indexed oldAddress, address indexed newAddress);
    event PaymentTokenUpdated(address indexed oldAddress, address indexed newAddress);

    constructor(CARNFTInterface _carNFT, IERC20 _paymentToken, uint256 _rentalRatePerSecond) Ownable(msg.sender){
       carNFT = _carNFT;
        paymentToken = _paymentToken;
        rentalRatePerHour = _rentalRatePerSecond;        
    }
    function rentCar(uint256 carId) external {
    require(carExists(carId), "car doesn't exist");
        require(!rentals[carId].isActive, "Car is already rented");
        rentals[carId] = Rental({
            renter: msg.sender,
            startTime: block.timestamp,
            isActive: true
        });
        emit CarRented(msg.sender, carId, block.timestamp);
    }
    function returnCar(uint256 carId) external {
        require(rentals[carId].isActive, "Car is not rented");
        require(rentals[carId].renter == msg.sender, "You are not the renter");
        uint256 rentalDuration = block.timestamp - rentals[carId].startTime;
        uint256 rentalFee = calculateRentalFee(rentalDuration);
        rentals[carId].isActive = false;
        // Transfer rental fee to the contract
        paymentToken.transferFrom(msg.sender, address(this), rentalFee);
        emit CarReturned(msg.sender, carId, block.timestamp, rentalFee);
    }
    function calculateRentalFee(uint256 duration) internal view returns (uint256) {
        return (duration / 1 seconds) * rentalRatePerHour;
    }
    function updateRentalRate(uint256 newRate) external onlyOwner {
        rentalRatePerHour = newRate;
    }
     function updateCarToken(address newCarToken) external onlyOwner {
        require(newCarToken != address(0), "Invalid address");
        address oldCarToken = address(carNFT);
        carNFT = CARNFTInterface(newCarToken);
        emit CarNFTUpdated(oldCarToken, newCarToken);
    }
    function updatePaymentToken(address newPaymentToken) external onlyOwner {
        require(newPaymentToken != address(0), "Invalid address");
        address oldPaymentToken = address(paymentToken);
        paymentToken = IERC20(newPaymentToken);
        emit PaymentTokenUpdated(oldPaymentToken, newPaymentToken);
    }
    function _distributeToInvestors(uint256 tokenId, uint256 amount) public onlyOwner {
        require(amount>=100, "amount too low");
        address[] memory owners = carNFT.ownersOf(tokenId);
        require(owners.length > 0, "No owners found for this token ID");
        uint256 amountPerOwner = amount / owners.length;
        for (uint256 i = 0; i < owners.length; i++) {
            require(paymentToken.transfer(owners[i], amountPerOwner), "Payment transfer failed");
        }
    }

   function carExists(uint256 id) public view returns (bool) {
   address[] memory owners = carNFT.ownersOf(id);
        return owners.length > 0;
}
}
