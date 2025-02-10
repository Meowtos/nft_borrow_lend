module meowtos::nft_borrow_lend {
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object, ObjectCore};
    use aptos_framework::fungible_asset::{Self, FungibleStore, FungibleAsset};
    use meowtos::coin_wrapper;

    friend meowtos::router;

    const ERR_ALREADY_INITIALIZED: u64 = 0;

    struct Config has key {
        lend_fee_bps: u64,
        fee_manager: address,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct LendingData has key {
        token_store: Object<FungibleStore>,
        object: Object<ObjectCore>,
        lend_fee_bps: u64,
        apr: u64,
        duration: u64,
        delete_ref: object::DeleteRef,
    }

    #[event]
    struct CreateLending has drop, store {
        lending_obj: address,
        object: address,
        lend_fee_bps: u64,
        apr: u64,
        duration: u64,
    }

    fun init_module(module_signer: &signer) {
        coin_wrapper::initialize(module_signer);
        move_to(module_signer, Config {
            lend_fee_bps: 20, // 0.2%
            fee_manager: @meowtos
        });
    }

    public(friend) fun lend(
        acc: &signer, 
        object: Object<ObjectCore>,
        fa: FungibleAsset,
        duration: u64,
        apr: u64
    ): Object<LendingData> acquires Config {
        let constructor_ref = &object::create_object(signer::address_of(acc));
        let obj_signer = &object::generate_signer(constructor_ref);
        let config = safe_config();

        let token_store = fungible_asset::create_store(constructor_ref, fungible_asset::asset_metadata(&fa));
        fungible_asset::deposit(token_store, fa);

        let object_addr = object::object_address(&object);
        move_to(obj_signer, LendingData {
            token_store,
            object,
            lend_fee_bps: config.lend_fee_bps,
            apr,
            duration,
            delete_ref: object::generate_delete_ref(constructor_ref),
        });

        event::emit(CreateLending{
            lending_obj: object::address_from_constructor_ref(constructor_ref),
            object: object_addr,
            lend_fee_bps: config.lend_fee_bps,
            apr,
            duration,
        });

        object::object_from_constructor_ref<LendingData>(constructor_ref)
    }

    inline fun safe_config(): &Config {
        borrow_global<Config>(@meowtos)
    }
}