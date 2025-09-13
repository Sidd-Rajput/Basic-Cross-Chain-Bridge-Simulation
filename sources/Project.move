module MyModule::TokenStaking {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    /// Struct representing a user's staking position.
    struct StakePosition has store, key {
        amount: u64,           // Amount of tokens staked
        stake_time: u64,       // Timestamp when tokens were staked
        is_active: bool,       // Whether the stake is currently active
    }

    /// Function to stake tokens with a minimum lock period.
    public fun stake_tokens(staker: &signer, amount: u64) {
        // Ensure the user doesn't already have an active stake
        let staker_addr = signer::address_of(staker);
        assert!(!exists<StakePosition>(staker_addr), 1);

        // Withdraw tokens from staker's account (tokens are held by contract logic)
        let staked_coins = coin::withdraw<AptosCoin>(staker, amount);
        
        // In a real implementation, you'd deposit to a pool address
        // For simplicity, we'll deposit back (representing pool management)
        coin::deposit<AptosCoin>(staker_addr, staked_coins);

        // Create and store the stake position
        let stake_position = StakePosition {
            amount,
            stake_time: timestamp::now_seconds(),
            is_active: true,
        };
        
        move_to(staker, stake_position);
    }

    /// Function to unstake tokens after minimum lock period (e.g., 7 days).
    public fun unstake_tokens(staker: &signer) acquires StakePosition {
        let staker_addr = signer::address_of(staker);
        
        // Ensure the user has an active stake
        assert!(exists<StakePosition>(staker_addr), 2);
        
        let stake_position = borrow_global_mut<StakePosition>(staker_addr);
        assert!(stake_position.is_active, 3);
        
        // Check if minimum staking period has passed (7 days = 604800 seconds)
        let current_time = timestamp::now_seconds();
        let min_stake_period = 604800; // 7 days in seconds
        assert!(current_time >= stake_position.stake_time + min_stake_period, 4);
        
        // Mark stake as inactive
        stake_position.is_active = false;
        
        // In a real implementation, you'd handle reward calculation and distribution
        // For now, user just gets their original stake back (already in their account)
    }
}