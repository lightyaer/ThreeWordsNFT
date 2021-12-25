// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./Base64.sol";

contract ThreeWordsNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string private svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: sans-serif; font-size: 32px; }</style><rect width='100%' height='100%' fill='";

    string private svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Select",
        "Wipe",
        "Write",
        "Switch",
        "Contribute",
        "Generate",
        "Compete",
        "Allege",
        "Drown",
        "Contact",
        "Wear",
        "Guarantee",
        "Dump",
        "Supplement",
        "Explode",
        "Flee",
        "Wait",
        "Let",
        "Recover",
        "Desire"
    ];
    string[] secondWords = [
        "Exclusive",
        "Unkempt",
        "Decent",
        "Marvelous",
        "Phobic",
        "Upbeat",
        "Daffy",
        "Strict",
        "Parched",
        "Thoughtful",
        "Efficient",
        "Repulsive",
        "Broken",
        "Gainful",
        "Worthless",
        "Ablaze",
        "Regular",
        "Icky",
        "Magical",
        "Holistic"
    ];
    string[] thirdWords = [
        "Orange",
        "Version",
        "Role",
        "Resource",
        "Ratio",
        "Food",
        "Reading",
        "Disk",
        "Church",
        "Region",
        "Boyfriend",
        "Funeral",
        "Classroom",
        "Injury",
        "Insect",
        "Relationship",
        "Employee",
        "Airport",
        "Stranger",
        "President"
    ];

    string[] colors = [
        "#610094",
        "#3F0071",
        "#150050",
        "#1F1F1F",
        "#3D0000",
        "#1A1A2E",
        "#1B1B2F",
        "#2F2519",
        "#4A3F35"
    ];

    event NewThreeWordsNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("ThreeWords", "TW") {
        console.log("This is Three Words NFT Contract");
    }

    function pickRandomWord(
        uint256 tokenId,
        string memory base,
        string[] memory words
    ) public pure returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked(base, Strings.toString(tokenId)))
        );
        rand = rand % words.length;
        return words[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256, uint256) {
        uint256 currentId = _tokenIds.current();
        return (currentId, 50);
    }

    function mintNFT() public {
        uint256 newItemId = _tokenIds.current();
        require(newItemId < 50, "All tokens have been minted");

        string memory first = pickRandomWord(
            newItemId,
            "FIRST_RANDOM_WORD",
            firstWords
        );
        string memory second = pickRandomWord(
            newItemId,
            "SECOND_RANDOM_WORD",
            secondWords
        );
        string memory third = pickRandomWord(
            newItemId,
            "THIRD_RANDOM_WORD",
            thirdWords
        );

        string memory color = pickRandomWord(newItemId, "RANDOM_COLOR", colors);

        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                color,
                svgPartTwo,
                first,
                " ",
                second,
                " ",
                third,
                "</text></svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        combinedWord,
                        '","description":"A highly acclaimed collection of squares.", "image":"data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");
        console.log(finalSvg);

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewThreeWordsNFTMinted(msg.sender, newItemId);
    }
}
