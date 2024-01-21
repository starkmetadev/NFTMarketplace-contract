// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
// import "./Factory.sol";
import "./CloneFactory.sol";

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface IMarketFactory {

    struct UserInfo {
        uint8 royaltyFee;
        uint8 royaltyShare;
        address user;
        uint8 step;
    }

    function _tokenIds() external view returns (uint256);

    function uri(uint256 tokenId) external view returns (string memory);

    function setCollectionInfo(string memory _uri) external;

    function setMarketplace(address _marketplace) external;

    function transferOwnership(address newOwner) external;

    function initialize(address newOnwer) external;

    function createItem(string memory _uri, uint8 _royaltyFee, address user) external;

    function updateRoyaltyFee(uint tokenId, uint8 _royaltyFee, address user) external;

    function userInfo(uint256 tokenId) external view returns(UserInfo memory);
    event CreatItem(address indexed user, uint256 indexed tokenId, uint8 royaltyFee);
    event UpdateRoyaltyFee(address indexed user, uint256 indexed tokenId, uint8 royaltyFee);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function getUserInfo(uint tokenId) external view returns(uint8 royaltyFee, uint8 royaltyShare, uint8 nftType, uint tier0Cnt, address admin);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Main is Ownable, CloneFactory {
    using SafeERC20 for IERC20;

    address public marketFactory;
    address public tradeToken;     // for test
    address public treasury;
    uint256 public flatFee;

    struct PutOnSaleInfo {
        address maker;
        address collectionId;
        uint256 tokenId;
        uint8 royaltyFee;
        uint8 royaltyShare;
        address admin;
        uint256 price;
        AuctionInfo[] auctionInfo;
        bool isAlive;
    }

    struct AuctionInfo {
        address taker;
        uint256 price;
    }

    mapping(address => address[]) public userCollectionInfo;

    mapping(bytes32 => PutOnSaleInfo) listInfo;

    event CreateCollection(address indexed collectionId);
    event PutOnSaleEvent(
        bytes32 _key,
        uint8 royaltyFee,
        uint8 royaltyShare,
        address admin
    );
    event TradingNFT(uint256 price, uint256 income, address maker, address taker);
    event RoyaltyHistory(uint256 royaltyFee, address admin);

    constructor(address _token) {
        tradeToken = _token;
    }

    function setTradeToken(address _token) external onlyOwner {
        tradeToken = _token;
    }

    function _makeHash(
        address user,
        address collectionId,
        uint256 tokenId
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, collectionId, tokenId));
    }

    function setFlatFee(uint256 value) external onlyOwner {
        flatFee = value;
    }

    function setTreasury(address wallet) external onlyOwner {
        treasury = wallet;
    }

    function setMarketFactory(address factory) external onlyOwner {
        marketFactory = factory;
    }

    function creatCollection(string memory collectionMetadata) external payable {
        if (msg.sender != owner()) require(msg.value == flatFee, "Main: insur flat fee");
        address subFactory = createClone(marketFactory);
        userCollectionInfo[msg.sender].push(subFactory);
        IMarketFactory(subFactory).initialize(address(this));
        IMarketFactory(subFactory).setCollectionInfo(collectionMetadata);
        if (msg.value > 0) {
            payable (treasury).transfer(msg.value);
        }
        emit CreateCollection(subFactory);
    }

    function mint(address collectionId, string memory uri, uint8 royaltyFee) external payable {
        require(msg.value == flatFee, "Main: insur flat fee");
        if (collectionId == address(0)) collectionId = marketFactory;
        IMarketFactory(collectionId).createItem(uri, royaltyFee, msg.sender);
        if (msg.value > 0) {
            payable (treasury).transfer(msg.value);
        }
    }

    function putOnSale(
        address collectionId,
        uint256 tokenId,
        uint256 price
    ) external payable {
        require(msg.value == flatFee, "Main:wrong flatfee");
        bytes32 _key = _makeHash(msg.sender, collectionId, tokenId);
        if (listInfo[_key].maker == address(0) && listInfo[_key].collectionId == address(0)) {
            // hashList.push(_key);
            listInfo[_key].maker = msg.sender;
            listInfo[_key].collectionId = collectionId;
            listInfo[_key].tokenId = tokenId;
        }
        listInfo[_key].price = price;
        listInfo[_key].isAlive = true;
        listInfo[_key].royaltyFee = IMarketFactory(collectionId).userInfo(tokenId).royaltyFee;
 
        if(msg.value > 0)
            payable (treasury).transfer(msg.value);
        IERC721(collectionId).safeTransferFrom(msg.sender, address(this), tokenId, "");
        emit PutOnSaleEvent(
            _key,
            listInfo[_key].royaltyFee,
            listInfo[_key].royaltyShare,
            listInfo[_key].admin
        );
    }

    function cancelList (bytes32 _key) external {
        require(listInfo[_key].maker == msg.sender && listInfo[_key].isAlive, "Main:not owner");
        listInfo[_key].isAlive = false;
        IERC721(listInfo[_key].collectionId).safeTransferFrom(address(this), msg.sender, listInfo[_key].tokenId, "");
    }

    function auction(
        bytes32 _key,
        uint256 price
    ) external {
        require(listInfo[_key].maker != msg.sender, "Main:IV user");
        require(price > 0, "Main:IV price");
        require(listInfo[_key].isAlive, "Main:IV hash id");

        AuctionInfo[] storage auctionInfoList = listInfo[_key].auctionInfo;
        bool isExist;
        uint oldValue;
        for(uint i = 0; i < auctionInfoList.length; i++) {
            if(auctionInfoList[i].taker == msg.sender) {
                oldValue = auctionInfoList[i].price;
                auctionInfoList[i].price = price;
                isExist = true;
                break;
            }
        }
        if(!isExist) {
            AuctionInfo memory auctionInfo = AuctionInfo({ taker: msg.sender, price: price });
            listInfo[_key].auctionInfo.push(auctionInfo);
        }

        if(price > oldValue) {
            IERC20(tradeToken).safeTransferFrom(msg.sender, address(this), price - oldValue);
        } else if (price < oldValue) {
            IERC20(tradeToken).safeTransfer(msg.sender, oldValue - price);
        }
    }

    function cancelAuction (bytes32 _key) external {
        AuctionInfo[] storage auctionInfoList = listInfo[_key].auctionInfo;
        uint price = 0;
        for (uint i = 0; i < auctionInfoList.length; i++) {
            if( auctionInfoList[i].taker == msg.sender ) {
                price = auctionInfoList[i].price;
                auctionInfoList[i] = auctionInfoList[auctionInfoList.length - 1];
                auctionInfoList.pop();
                break;
            }
        }
        IERC20(tradeToken).safeTransfer(msg.sender, price);
    }

    function buyNow(bytes32 _key) external {
        require(listInfo[_key].maker != address(this), "Main:unlisted");
        require(listInfo[_key].maker != msg.sender && listInfo[_key].isAlive, "Main:IV maker");
        _exchangeDefaultNFT(_key, listInfo[_key].price, msg.sender, true);
    }

    function _exchangeDefaultNFT(bytes32 _key, uint price, address user, bool isBuyNow) private {
        require(price > 0, "Main:insuf 721");
        if(isBuyNow)
            IERC20(tradeToken).safeTransferFrom(user, address(this), price);
        
        uint256 royaltyAmount = listInfo[_key].royaltyFee * price / 100;
        uint256 income = price - royaltyAmount;
        listInfo[_key].isAlive = false;

        IERC20(tradeToken).safeTransfer(listInfo[_key].maker, income);
        uint256 shareAmount;
        if(listInfo[_key].admin != address(0)  && 100 > listInfo[_key].royaltyShare) {
            shareAmount = royaltyAmount * (100 - listInfo[_key].royaltyShare) / 100;
            IERC20(tradeToken).safeTransfer(listInfo[_key].admin, shareAmount);
        }
        IERC20(tradeToken).safeTransfer(treasury, royaltyAmount - shareAmount);
        emit TradingNFT(price, income, listInfo[_key].maker, user);
        emit RoyaltyHistory(royaltyAmount, listInfo[_key].admin);

        IERC721(listInfo[_key].collectionId).safeTransferFrom(address(this), user, listInfo[_key].tokenId);
    }

    function makeOffer(bytes32 _key, address taker) external {
        require(listInfo[_key].isAlive && msg.sender == listInfo[_key].maker, "Main:not maker");
        bool isExist;
        AuctionInfo[] storage auctionInfoList = listInfo[_key].auctionInfo;
        for(uint i = 0; i < auctionInfoList.length; i++) {
            if(auctionInfoList[i].taker == taker) {
                uint _price = auctionInfoList[i].price;
                _exchangeDefaultNFT(_key, _price, taker, false);
                auctionInfoList[i] = auctionInfoList[auctionInfoList.length - 1];
                auctionInfoList.pop();
                isExist = true;
                break;
            }
        }
        require(isExist, "Main:no user");
    }

    function ListInfo(bytes32 _key) external view returns(PutOnSaleInfo memory info, AuctionInfo[] memory auctionInfo, bool isValid) {
        auctionInfo = new AuctionInfo[](listInfo[_key].auctionInfo.length);
        auctionInfo = listInfo[_key].auctionInfo;
        return (listInfo[_key], auctionInfo, true);
    }

    function recoverTokens(address coin, address user, uint amount) external onlyOwner {
        IERC20(coin).safeTransfer(user, amount);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}