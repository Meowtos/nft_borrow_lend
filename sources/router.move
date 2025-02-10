module meowtos::router {
    // use std::signer;
    use aptos_framework::object::{Object, ObjectCore};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{FungibleAsset, Metadata};
    use meowtos::nft_borrow_lend::{Self, LendingData};

    public entry fun lend_entry(
        acc: &signer,
        object: Object<ObjectCore>,
        token_metadata: Object<Metadata>,
        amount: u64,
        duration: u64,
        apr: u64,
    ) {
        let fa = primary_fungible_store::withdraw(acc, token_metadata, amount);
        lend(acc, object, fa, duration, apr);
    }

    public fun lend(
        acc: &signer,
        object: Object<ObjectCore>,
        fa: FungibleAsset,
        duration: u64,
        apr: u64,
    ): Object<LendingData> {
        nft_borrow_lend::lend(acc, object, fa, duration, apr)
    }

    // public entry fun lend_coin_entry<CoinType>(
    //     acc: &signer,
    //     object: Object<ObjectCore>,
    //     amount: u64,
    //     duration: u64,
    //     apr: u64,
    // ) {

    // }
} 