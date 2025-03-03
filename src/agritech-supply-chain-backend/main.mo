import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Principal "mo:base/Principal";

actor {
    // Type Definitions
    public type Error = {
        #NotFound;
        #AlreadyExists;
        #NotAuthorized;
        #InvalidInput;
    };

    public type Buyer = {
        id : Text;
        name : Text;
        nfid : Principal;
        phone : Text;
        address : Text;
        profilePic : Text;
        registrationDate : Text;
    };

    // Storage
    private let buyerStorage = HashMap.HashMap<Text, Buyer>(0, Text.equal, Text.hash);
    
    // Helper function to validate phone number
    private func isValidPhone(phone : Text) : Bool {
        // Implement your phone validation logic here
        // For example, check if it's a valid format or length
        return Text.size(phone) >= 10;
    };

    // Create Buyer
    public shared func createBuyer(
        name : Text,
        nfid : Principal,
        phone : Text,
        address : Text,
        profilePic : Text,
    ) : async Result.Result<Buyer, Error> {
        // More detailed input validation
        if (Text.size(name) < 2) {
            return #err(#InvalidInput);
        };

        if (not isValidPhone(phone)) {
            return #err(#InvalidInput);
        };

        if (Text.size(address) < 5) {
            return #err(#InvalidInput);
        };

        let id = generateBuyerId();
        let registrationDate = generateTimestamp();

        let buyer : Buyer = {
            id;
            name;
            nfid;
            phone;
            address;
            profilePic;
            registrationDate;
        };

        switch (buyerStorage.get(id)) {
            case (?_) { #err(#AlreadyExists) };
            case null {
                buyerStorage.put(id, buyer);
                #ok(buyer);
            };
        };
    };
    // Update Buyer
    public shared func updateBuyer(
        id : Text,
        name : ?Text,
        phone : ?Text,
        address : ?Text,
        profilePic : ?Text,
    ) : async Result.Result<Buyer, Error> {
        switch (buyerStorage.get(id)) {
            case (?existing) {
                let updatedBuyer : Buyer = {
                    id = existing.id;
                    name = Option.get(name, existing.name);
                    nfid = existing.nfid;
                    phone = Option.get(phone, existing.phone);
                    address = Option.get(address, existing.address);
                    profilePic = Option.get(profilePic, existing.profilePic);
                    registrationDate = existing.registrationDate;
                };
                buyerStorage.put(id, updatedBuyer);
                #ok(updatedBuyer);
            };
            case null { #err(#NotFound) };
        };
    };

    // Get Buyer
    public query func getBuyer(id : Text) : async Result.Result<Buyer, Error> {
        switch (buyerStorage.get(id)) {
            case (?buyer) { #ok(buyer) };
            case null { #err(#NotFound) };
        };
    };

    // Get All Buyers (with Pagination)
   public query func getAllBuyers(offset: Nat, limit: Nat) : async [Buyer] {
    let buyers = Buffer.Buffer<Buyer>(limit);
    let entries = Iter.toArray(buyerStorage.entries()); // Convert HashMap entries to an array

    let paginated = Array.slice(entries, offset, limit); // Extract the required slice

    for (entry in paginated) { // Iterate over the array directly
        let (_, buyer) = entry; // Destructure tuple (Text, Buyer)
        buyers.add(buyer);
    };

    Buffer.toArray(buyers) // Convert Buffer to Array before returning
};

    // Delete Buyer
    public shared func deleteBuyer(id : Text) : async Result.Result<(), Error> {
        switch (buyerStorage.get(id)) {
            case (?_) {
                buyerStorage.delete(id);
                #ok(());
            };
            case null { #err(#NotFound) };
        };
    };

    // Helper Functions
    private func generateBuyerId() : Text {
        "BUYER-" # Int.toText(Time.now());
    };

    private func generateTimestamp() : Text {
        Int.toText(Time.now());
    };
};
