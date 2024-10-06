// SPDX-License-Identifier: MIT
pragma solidity >0.8.0<=0.9.0;

contract MusicMarketplace{

    //Data of artist
    struct Artist{
        string name;
        uint age;
        string typeOfArtist;
        address Artistaddress;
        uint ArtistId;
    }

    //Data of listener
    struct Listener{
        string name;
        uint age;
        address ListenerAddress;
        uint ListenerId;
    }

    //Data of song
    struct Song{
        string name;
        bytes32 hashvalue;
        uint SongId;
        bool purchase;
        address Artistaddr;
        uint price;
        string Artistname;
        uint age;
        string typeOfArtist;
        uint ArtistId;
    }
    uint ListenerCount;
    mapping(uint=>Artist)artists;
    mapping(uint=>Listener)listeners;
    mapping(uint=>Song)songs;
    uint ArtistCount;
    uint public songCount;

    //events 
    event songuploaded(address indexed artist,uint songId);
    event purchased(address indexed listener,uint songId,uint price);
    event donation(address indexed donater,address indexed artist,uint donation_amount);

    //checking the artist is registered previously
    function isArtistRegistered(address _artistaddress) private view returns(bool){
        for(uint i=0;i<ArtistCount;i++){
            if(artists[i].Artistaddress==_artistaddress){
                return false;
            }
        }
        return true;
    }

    //Artist registration
    function ArtistRegister(string memory _name,uint _age,string memory _typeOfArtist) public {
        require(isArtistRegistered(msg.sender)==true,"You are already registered");
        artists[ArtistCount]=Artist({
            name:_name,
            age:_age,
            typeOfArtist:_typeOfArtist,
            Artistaddress:msg.sender,
            ArtistId:ArtistCount
        });
        ArtistCount++;
    }

    //checking Listener is registered previously
    function isListenerRegistered(address _listeneradd) private view returns(bool){
        for(uint i=0;i<ListenerCount;i++){
            if(listeners[i].ListenerAddress==_listeneradd){
                return false;
            }
        }
        return true;
    }

    //Listener registration
    function ListenerRegister(string memory _name,uint _age) public {
        require(isListenerRegistered(msg.sender)==true,"You are already registered");
        listeners[ListenerCount]=Listener({
            name:_name,
            age:_age,
            ListenerAddress:msg.sender,
            ListenerId:ListenerCount
        });
        ListenerCount++;
    }

    //checking whether the song is duplicated
    function isSongOriginal(string memory _songName) private view returns(bool){
        bytes32 song=keccak256(abi.encodePacked(_songName));
        for(uint i=0;i<songCount;i++){
            if(songs[i].hashvalue==song){
                return false;
            }
        }
        return true;
    }

    //song upload
    function uploadSong(string memory _songName,uint _price) public{
        require(isArtistRegistered(msg.sender)==false,"You are not an Artist");
        require(isSongOriginal(_songName)==true,"This song is Duplicated");

        uint i;
        for(i=0;i<ArtistCount;i++){
            if(artists[i].Artistaddress==msg.sender){
                break;
            }
        }
        songs[songCount]=Song({
            name:_songName,
            hashvalue:keccak256(abi.encodePacked(_songName)),
            SongId:songCount,
            purchase:false,
            Artistaddr:msg.sender,
            price:_price,
            Artistname:artists[i].name,
            age:artists[i].age,
            typeOfArtist:artists[i].typeOfArtist,
            ArtistId:artists[i].ArtistId
        });
        emit songuploaded(msg.sender,songs[songCount].SongId);
        songCount++;
    }

    // browsing songs to purchase
    function browseSongs() view public returns(Song[] memory){
        require(isListenerRegistered(msg.sender)==false,"You are not a registered Listener");
        Song[] memory songList = new Song[](songCount);
        for(uint i=0;i<songList.length;i++){
            songList[i]=songs[i];
        }
        return songList;
    }

    //song purchasing
    function purchaseSong(uint _songId) payable public{
        require(isListenerRegistered(msg.sender)==false,"You are not a registered Listener");
        require(songs[_songId].purchase==false,"It is already purchased");
        require((msg.sender).balance>=songs[_songId].price,"Insufficient balance");
        require(msg.value==songs[_songId].price,"This is not the correct amount");
        
        payable(songs[_songId].Artistaddr).transfer(songs[_songId].price);
        songs[_songId].purchase=true;
        emit purchased(msg.sender,_songId,songs[_songId].price);
    }

    //ether donation
    function donateEther(uint _artistId) public payable{
        require((msg.sender).balance>=msg.value,"Insufficient balance");
        payable(artists[_artistId].Artistaddress).transfer(msg.value);
        emit donation(msg.sender,artists[_artistId].Artistaddress,msg.value);
    }
}