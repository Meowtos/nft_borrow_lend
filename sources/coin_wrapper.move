module meowtos::coin_wrapper {
    use std::string::String;
    use aptos_framework::object::Object;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::fungible_asset::{BurnRef, Metadata, MintRef};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_framework::coin::{Self, Coin};

    friend meowtos::nft_borrow_lend;

    const COIN_WRAPPER: vector<u8> = b"COIN_WRAPPER";

    struct FungibleAssetData has store {
        burn_ref: BurnRef,
        metadata: Object<Metadata>,
        mint_ref: MintRef,
    }
    struct WrapperAccount has key {
        signer_cap: SignerCapability,
        coin_to_fungible_asset: SmartTable<String, FungibleAssetData>,
        fungible_asset_to_coin: SmartTable<Object<Metadata>, String>,
    }
    public(friend) fun initialize(module_signer: &signer) {
        let (_, signer_cap) = account::create_resource_account(module_signer, COIN_WRAPPER);
        move_to(module_signer, WrapperAccount {
            signer_cap,
            coin_to_fungible_asset: smart_table::new(),
            fungible_asset_to_coin: smart_table::new(),
        });
    }

    #[view]
    public fun is_initialized(): bool {
        exists<WrapperAccount>(@meowtos)
    }

    public(friend) fun wrap<CoinType>(coins: Coin<CoinType>): FungibleAsset acquires WrapperAccount {

    }

    // public(friend) fun unwrap()
}