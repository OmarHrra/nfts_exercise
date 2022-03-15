// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Base64.sol";
import "./Dna.sol";

contract ProjectPunks is ERC721, ERC721Enumerable, Dna {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _idCounter;
  uint256 public maxSupply;
  mapping(uint256 => uint256) public tokenDna;

  constructor(uint256 _maxSupply) ERC721("ProjectPunks", "PP") {
    maxSupply =_maxSupply;
  }

  function mint() public {
    uint256 current = _idCounter.current();
    require(current < maxSupply, "minting above the total token supply");

    tokenDna[current] = deterministicPseudoRandomDna(current, msg.sender);

    _safeMint(msg.sender, current);
    _idCounter.increment();
  }

  function _baseURI() internal pure override returns(string memory) {
    return "https://avataaars.io/";
  }

  function _paramsURI(uint256 _dna) internal view returns(string memory) {
    string memory params;

    {
      params = string(
        abi.encodePacked(
          "accessoriesType=",
          getAccessoriesType(_dna),
          "&clotheColor=",
          getClotheColor(_dna),
          "&clotheType=",
          getClotheType(_dna),
          "&eyeType=",
          getEyeType(_dna),
          "&eyebrowType=",
          getEyeBrowType(_dna),
          "&facialHairColor=",
          getFacialHairColor(_dna),
          "&facialHairType=",
          getFacialHairType(_dna),
          "&hairColor=",
          getHairColor(_dna),
          "&hatColor=",
          getHatColor(_dna),
          "&graphicType=",
          getGraphicType(_dna),
          "&mouthType=",
          getMouthType(_dna),
          "&skinColor=",
          getSkinColor(_dna)
        )
      );
    }

    return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
  }

  function imageByDNA(uint256 _dna) public view returns (string memory) {
    string memory baseURI = _baseURI();
    string memory paramsURI = _paramsURI(_dna);

    return string(abi.encodePacked(baseURI, "?", paramsURI));
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'ERC721 Metadata: URI query for noneexisten token');

    uint256 dna = tokenDna[tokenId];
    string memory image = imageByDNA(dna);

    string memory jsonUri = Base64.encode(
      abi.encodePacked(
        '{ "name": "PlatziPunks #',
        tokenId.toString(),
        '", "description": "Description...", "image": "',
        image,
        '"}'
      )
    );

    return string(abi.encodePacked("data:application/json;base64,", jsonUri));
  }

  // The following functions are overrides required by Solidity.
  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
      internal
      override(ERC721, ERC721Enumerable)
  {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, ERC721Enumerable)
      returns (bool)
  {
      return super.supportsInterface(interfaceId);
  }
}