//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

/**
 * @title InfinityMintValues
 * @dev This contract is used to store values that are used by the InfinityMint contract.
 * It is used to store the values that are used by the InfinityMint contract.
 */
contract InfinityMintValues {
    mapping(string => uint256) private values;
    mapping(string => bool) private booleanValues;
    mapping(string => bool) private registeredValues;
    mapping(address => bool) public approved;

    address public deployer;
    /// @notice for re-entry prevention, keeps track of a methods execution count
    uint256 private executionCount;

    constructor() {
        deployer = msg.sender;
        approved[msg.sender] = true;
        executionCount = 0;
    }

    event PermissionChange(
        address indexed sender,
        address indexed changee,
        bool value
    );

    event TransferedOwnership(address indexed from, address indexed to);

    /// @notice Limits execution of a method to once in the given context.
    /// @dev prevents re-entry attack
    modifier onlyOnce() {
        executionCount += 1;
        uint256 localCounter = executionCount;
        _;
        require(localCounter == executionCount, 're-entry');
    }

    modifier onlyDeployer() {
        require(deployer == msg.sender, 'not deployer');
        _;
    }

    modifier onlyApproved() {
        require(deployer == msg.sender || approved[msg.sender], 'not approved');
        _;
    }

    function setPrivilages(address addr, bool value) public onlyDeployer {
        require(addr != deployer, 'cannot modify deployer');
        approved[addr] = value;

        emit PermissionChange(msg.sender, addr, value);
    }

    function multiApprove(address[] memory addrs) public onlyDeployer {
        require(addrs.length != 0);
        for (uint256 i = 0; i < addrs.length; ) {
            approved[addrs[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    function multiRevoke(address[] memory addrs) public onlyDeployer {
        require(addrs.length != 0);
        for (uint256 i = 0; i < addrs.length; ) {
            approved[addrs[i]] = false;
            unchecked {
                ++i;
            }
        }
    }

    function isAuthenticated(address addr) external view returns (bool) {
        return addr == deployer || approved[addr];
    }

    function transferOwnership(address addr) public onlyDeployer {
        approved[deployer] = false;
        deployer = addr;
        approved[addr] = true;

        emit TransferedOwnership(msg.sender, addr);
    }

    function setValue(string memory key, uint256 value) public onlyDeployer {
        values[key] = value;
        registeredValues[key] = true;
    }

    function setupValues(
        string[] memory keys,
        uint256[] memory _values,
        string[] memory booleanKeys,
        bool[] memory _booleanValues
    ) public onlyDeployer {
        require(keys.length == _values.length);
        require(booleanKeys.length == _booleanValues.length);
        for (uint256 i = 0; i < keys.length; i++) {
            setValue(keys[i], _values[i]);
        }

        for (uint256 i = 0; i < booleanKeys.length; i++) {
            setBooleanValue(booleanKeys[i], _booleanValues[i]);
        }
    }

    function setBooleanValue(
        string memory key,
        bool value
    ) public onlyDeployer {
        booleanValues[key] = value;
        registeredValues[key] = true;
    }

    function isTrue(string memory key) external view returns (bool) {
        return booleanValues[key];
    }

    function getValue(string memory key) external view returns (uint256) {
        if (!registeredValues[key]) revert('Invalid Value');

        return values[key];
    }

    /// @dev Default value it returns is zero
    function tryGetValue(string memory key) external view returns (uint256) {
        if (!registeredValues[key]) return 0;

        return values[key];
    }
}
