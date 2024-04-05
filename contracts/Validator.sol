// SPDX-License-Identifier: GPL-3.0-or-later
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
pragma solidity ^0.8.2;

/**
 * @title Validator
 * @dev To handle the multisig
 * Author: victor.luu
 * Company: xoxlabs.io
 **/

contract Validator is EIP712Upgradeable {
    // keccak256("CreateMeeting(uint256 _id,string _title,uint256 _start_time,uint256 _end_time,string _meeting_link,uint256 _company_id,uint256 _timeEnd)");
    bytes32 public constant CREATE_MEETING_TYPEHASH =
        0x015f0881051cf5b72eb24f8d409807090a04561be8301c284f86f0261dee0131;

    // keccak256("UpdateMeeting(uint256 _id,string _title,uint256 _start_time,uint256 _end_time,string _meeting_link,uint256 _company_id,uint256 _timeEnd)");
    bytes32 public constant UPDATE_MEETING_TYPEHASH =
        0xf10ec8f5d66b6a1126f09f716fa0f24c03b010afcd529059ba24049519c544f6;

    address[] private validators;
    mapping(address => bool) private operations;
    // Fixed threshold to validate unlock/refund/emergency withdraw equal or more than 2/3 signatures
    // uint256 private constant threshold = 66;

    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require(
            operations[msg.sender],
            "Validator: caller is not the operator"
        );
        _;
    }

    function getValidators() public view returns (address[] memory) {
        return validators;
    }

    event LogAddValidator(address _validator);

    function _addValidator(address _validator) internal {
        require(_validator != address(0), "Null address");
        for (uint256 index = 0; index < validators.length; index++) {
            require(_validator != validators[index], "Already added");
        }
        operations[_validator] = true;
        validators.push(_validator);

        emit LogAddValidator(_validator);
    }

    event LogRemoveValidator(address _validator);

    function _removeValidator(address _validator) internal {
        for (uint256 index = 0; index < validators.length; index++) {
            if (_validator == validators[index]) {
                validators[index] = validators[validators.length - 1];
                validators.pop();
                operations[_validator] = false;
                emit LogRemoveValidator(_validator);
                return;
            }
        }

        require(false, "Could not find validator to remove");
    }

    function _checkSignature(
        bytes memory signature,
        bytes32 digest
    ) private view returns (bool) {
        address checkAdress = ECDSAUpgradeable.recover(digest, signature);
        for (uint256 index = 0; index < validators.length; index++) {
            if (checkAdress == validators[index]) {
                return true;
            }
        }
        return false;
    }

    function _checkCreateSig(
        bytes[] memory signature,
        uint256 _id,
        string memory _title,
        uint256 _start_time,
        uint256 _end_time,
        string memory _meeting_link,
        uint256 _company_id,
        uint256 _timeEnd
    ) internal view returns (bool) {
        // digest the data to transactionHash
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    CREATE_MEETING_TYPEHASH,
                    _id,
                    _title,
                    _start_time,
                    _end_time,
                    _meeting_link,
                    _company_id,
                    _timeEnd
                )
            )
        );
        for (uint256 index = 0; index < signature.length; index++) {
            if (!_checkSignature(signature[index], digest)) return false;
        }
        return true;
    }

    function _checkUpdateSig(
        bytes[] memory signature,
        uint256 _id,
        string memory _title,
        uint256 _start_time,
        uint256 _end_time,
        string memory _meeting_link,
        uint256 _company_id,
        uint256 _timeEnd
    ) internal view returns (bool) {
        // digest the data to transactionHash
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    UPDATE_MEETING_TYPEHASH,
                    _id,
                    _title,
                    _start_time,
                    _end_time,
                    _meeting_link,
                    _company_id,
                    _timeEnd
                )
            )
        );
        for (uint256 index = 0; index < signature.length; index++) {
            if (!_checkSignature(signature[index], digest)) return false;
        }
        return true;
    }

    modifier validatorPrecheck(bytes[] memory signature) {
        require(signature.length > 0, "validator(s) is empty");

        // require(
        //     (signature.length * 100) / validators.length >= threshold,
        //     "Threshold not reached"
        // );

        if (signature.length >= 2) {
            for (uint256 i = 0; i < signature.length; i++) {
                for (uint256 j = i + 1; j < signature.length; j++) {
                    require(
                        keccak256(abi.encodePacked(signature[i])) !=
                            keccak256(abi.encodePacked(signature[j])),
                        "Can not be the same signature"
                    );
                }
            }
        }
        _;
    }
}
