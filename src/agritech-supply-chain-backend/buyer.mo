import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";

module {
    type Buyer = Types.Buyer;
    type BuyerId = Types.BuyerId;
    type TransactionId = Types.TransactionId;
    type ContactInfo = Types.ContactInfo;

    public type BuyerStorage = {
        var buyers: HashMap.HashMap<BuyerId, Buyer>;
    };

    public func init() : BuyerStorage = {
        var buyers = HashMap.HashMap<BuyerId, Buyer>(0, Text.equal, Text.hash);
    };

    public func createBuyer(
        storage: BuyerStorage, 
        id: BuyerId, 
        name: Text, 
        location: Text,
        phone: Text,
        email: Text,
        address: Text
    ) : ?Buyer {
        if (Option.isSome(storage.buyers.get(id))) {
            return null;
        };

        let newBuyer: Buyer = {
            id;
            name;
            location;
            purchaseHistory = [];
            contactInfo = { phone; email; address };
        };

        storage.buyers.put(id, newBuyer);
        ?newBuyer;
    };

    public func getBuyer(storage: BuyerStorage, id: BuyerId) : ?Buyer = 
        storage.buyers.get(id);

    public func updateBuyer(
        storage: BuyerStorage, 
        id: BuyerId, 
        name: ?Text, 
        location: ?Text,
        phone: ?Text,
        email: ?Text,
        address: ?Text
    ) : ?Buyer {
        switch (storage.buyers.get(id)) {
            case (null) null;
            case (?existingBuyer) {
                let updatedBuyer: Buyer = {
                    id = existingBuyer.id;
                    name = Option.get(name, existingBuyer.name);
                    location = Option.get(location, existingBuyer.location);
                    purchaseHistory = existingBuyer.purchaseHistory;
                    contactInfo = {
                        phone = Option.get(phone, existingBuyer.contactInfo.phone);
                        email = Option.get(email, existingBuyer.contactInfo.email);
                        address = Option.get(address, existingBuyer.contactInfo.address);
                    };
                };
                storage.buyers.put(id, updatedBuyer);
                ?updatedBuyer;
            }
        }
    };

    public func deleteBuyer(storage: BuyerStorage, id: BuyerId) : Bool =
        switch (storage.buyers.get(id)) {
            case (null) false;
            case (?_) {
                storage.buyers.delete(id);
                true;
            }
        };

    public func addTransactionToBuyer(
        storage: BuyerStorage, 
        buyerId: BuyerId, 
        transactionId: TransactionId
    ) : Bool =
        switch (storage.buyers.get(buyerId)) {
            case (null) false;
            case (?existingBuyer) {
                let updatedBuyer: Buyer = {
                    id = existingBuyer.id;
                    name = existingBuyer.name;
                    location = existingBuyer.location;
                    purchaseHistory = Array.append(existingBuyer.purchaseHistory, [transactionId]);
                    contactInfo = existingBuyer.contactInfo;
                };
                storage.buyers.put(buyerId, updatedBuyer);
                true;
            }
        };

    public func getAllBuyers(storage: BuyerStorage) : [Buyer] =
        Iter.toArray(storage.buyers.vals());

    public func getBuyerTransactions(storage: BuyerStorage, buyerId: BuyerId) : ?[TransactionId] =
        switch (storage.buyers.get(buyerId)) {
            case (null) null;
            case (?buyer) ?buyer.purchaseHistory;
        };

    public func clearAllBuyers(storage: BuyerStorage) {
        storage.buyers := HashMap.HashMap<BuyerId, Buyer>(0, Text.equal, Text.hash);
    };
};
