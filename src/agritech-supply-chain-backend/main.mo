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
    public type Error = { #NotFound; #AlreadyExists; #NotAuthorized; #InvalidInput };

    public type Buyer = {
        id: Text;
        name: Text;
        email: Text;
        phone: Text;
        address: Text;
        profilePic: Text;
        registrationDate: Text;
    };

    // Storage
    private let buyerStorage = HashMap.HashMap<Text, Buyer>(0, Text.equal, Text.hash);

    // Utility: Input Validation
    private func isValidEmail(email: Text) : Bool {
        let emailRegex = #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b";
        Text.contains(email, emailRegex);
    };

    private func isValidPhone(phone: Text) : Bool {
        let phoneRegex = #"^\+?[0-9]{7,15}$";
        Text.contains(phone, phoneRegex);
    };

    // Create Buyer
    public shared func createBuyer(
        name: Text,
        email: Text,
        phone: Text,
        address: Text,
        profilePic: Text
    ) : async Result.Result<Buyer, Error> {
        if (Text.size(name) == 0 or Text.size(email) == 0 or Text.size(phone) == 0 or Text.size(address) == 0) {
            return #err(#InvalidInput);
        };

        if (not isValidEmail(email)) {
            return #err(#InvalidInput);
        };

        if (not isValidPhone(phone)) {
            return #err(#InvalidInput);
        };

        let id = generateBuyerId();
        let registrationDate = generateTimestamp();

        let buyer : Buyer = { id; name; email; phone; address; profilePic; registrationDate };

        switch (buyerStorage.get(id)) {
            case (?_) { #err(#AlreadyExists) };
            case null {
                buyerStorage.put(id, buyer);
                #ok(buyer)
            };
        }
    };

    // Update Buyer
    public shared func updateBuyer(
        id: Text,
        name: ?Text,
        email: ?Text,
        phone: ?Text,
        address: ?Text,
        profilePic: ?Text
    ) : async Result.Result<Buyer, Error> {
        switch (buyerStorage.get(id)) {
            case (?existing) {
                let updatedBuyer : Buyer = {
                    id = existing.id;
                    name = Option.get(name, existing.name);
                    email = Option.get(email, existing.email);
                    phone = Option.get(phone, existing.phone);
                    address = Option.get(address, existing.address);
                    profilePic = Option.get(profilePic, existing.profilePic);
                    registrationDate = existing.registrationDate;
                };
                buyerStorage.put(id, updatedBuyer);
                #ok(updatedBuyer)
            };
            case null { #err(#NotFound) };
        }
    };

    // Get Buyer
    public query func getBuyer(id: Text) : async Result.Result<Buyer, Error> {
        switch (buyerStorage.get(id)) {
            case (?buyer) { #ok(buyer) };
            case null { #err(#NotFound) };
        }
    };

    // Get All Buyers (with Pagination)
    public query func getAllBuyers(offset: Nat, limit: Nat) : async [Buyer] {
        let buyers = Buffer.Buffer<Buyer>(limit);
        let entries = Array.tabulate<(Text, Buyer)>(buyerStorage.size(), func(i) {
            Iter.toArray(buyerStorage.entries())[i];
        });

        let paginated = Array.slice(entries, offset, limit);

        for ((_, buyer) in paginated.vals()) {
            buyers.add(buyer);
        };

        Buffer.toArray(buyers)
    };

    // Delete Buyer
    public shared func deleteBuyer(id: Text) : async Result.Result<(), Error> {
        switch (buyerStorage.get(id)) {
            case (?_) {
                buyerStorage.delete(id);
                #ok(())
            };
            case null { #err(#NotFound) };
        }
    };

    // Helper Functions
    private func generateBuyerId() : Text {
        "BUYER-" # Int.toText(Time.now())
    };

    private func generateTimestamp() : Text {
        Int.toText(Time.now())
    };
}
