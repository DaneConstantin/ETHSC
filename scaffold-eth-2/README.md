# 🏗 Solid Luxury

<h4 align="center">
   <a href="https://carental-rho.vercel.app/">Live Demo</a>
</h4>

🧪 Car Rental Business on Crypto
⚙️ Built using ERC1155 NFTs to represent cars and ERC20 tokens for payments

## Functionality

The smart contracts handle the rental process, including rental rates, payments, and distribution of earnings to car owners.

!For the hackathon demo, rental rate is per second not per hour!

1. Client (renter) must first hold a day's worth of LuxCoin (LUX) tokens to be able to rent the car - 3600 Tokens that need be buyed from a Decentralized Exchange (for hackathon Demo please request tokens from Owner)
2. client uses rentCar() function with the id of the car he wants.
3. client must then approve the leasing contract to spend their tokens. Go to Luxcoin token and approve leasing contract with the needed amount.
4. client must hit returnCar() with te specific id of the car he rented. Tokens will be calculated based on the duration of the rent.
5. after enough tokens gathered in the leasing contract(each NFT id earning is separately stored), owner will be able to distribute rewards to each investor after a 5% tax 