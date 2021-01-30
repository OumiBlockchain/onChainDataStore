pragma solidity ^0.5.17;

import "./Dummy/VersionedInitializable.sol";

/**
 * @author Mustafa Refaey <mustafarefaey@gmail.com>
 * @dev Implementation of proof of existence contract.
 */
contract ProofOfExistenceV2 is VersionedInitializable{
    /// the owner of the contract
    address owner;
    
    uint256 public constant REVISION = 0x3;

    /// a circuit breaker to stop the contract
    bool public contractStatus;

    /// a mapping of the hash uploaders and their hashes, stamped by the block number
    mapping(address => mapping(string => uint256)) private hashes;


    uint256 public check;

    /// an event to be emitted when a new hash has been added
    event LogAdditionEvent(
        address indexed stampper,
        uint256 blockNumber,
        string hash
    );

    /// an event to be emitted when a new hash has been added
    event LogAppVersionUpdated(uint256 appVersion);

    /// an event to be emitted when the contract status is updated
    event LogContractStatusUpdated(bool contractStatus);

    /// checks if the msg.sender is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "You must be the owner!");
        _;
    }

    /// stopInEmergency
    modifier stopInEmergency {
        require(contractStatus, "The contract is down currently!");
        _;
    }

    function initialize() public initializer {
        /// set the owner as the contract deployer
        owner = msg.sender;

        contractStatus = true;
        emit LogAppVersionUpdated(REVISION);
        check = 3;
        
    }

    function getRevision() internal pure returns (uint256) {
        return REVISION;
    }

    /// @notice Stores the hash in the contract's state
    /// @param hash The hash to be stored
    function storeHash(string memory hash) public stopInEmergency {
        require(
            hashes[msg.sender][hash] == 0,
            "This hash has been stored previously!"
        );

        hashes[msg.sender][hash] = block.number;

        emit LogAdditionEvent(msg.sender, block.number, hash);
    }

    /// @notice Verifies if the hash exists
    /// @param stampper The address of the stampper
    /// @param hash The hash to be stored
    /// @return the block number of a hash if it exists in the contract's state
    /// or returns 0
    function verifyHash(address stampper, string memory hash)
        public
        view
        stopInEmergency
        returns (uint256)
    {
        return hashes[stampper][hash];
    }

    /// @notice Enable/Disable contract functionality (a circuit breaker)
    /// @param _contractStatus The new circuit breaker state
    function updateContractStatus(bool _contractStatus) public onlyOwner {
        contractStatus = _contractStatus;

        emit LogContractStatusUpdated(_contractStatus);
    }

    /// @notice Retrieves the contract status
    /// @return the contract status
    function getContractStatus() public view returns (bool) {
        return contractStatus;
    }
}