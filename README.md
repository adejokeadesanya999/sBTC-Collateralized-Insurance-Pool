sBTC Collateralized Insurance Pool

A Clarity smart contract for managing decentralized, collateralized insurance policies on the Stacks blockchain using sBTC as collateral.
This system enables underwriters to lock collateral, users to purchase insurance coverage, and an oracle to trigger payouts in the event of a claim.

🚀 Features

Collateralized Underwriting

Participants can lock sBTC (represented in STX transfers) to become underwriters.

Collateral balances are tracked per user.

Insurance Policy Creation

Any user can create an insurance policy by paying a premium.

Policies include coverage amount, premium paid, collateral requirements, and expiry block.

Enforces a minimum collateral ratio (default 150%).

Oracle-Based Claim Settlement

Only the designated oracle can trigger claim payouts.

Validates that the policy is active, not expired, and not already claimed.

Transfers coverage amount to the insured and updates policy status.

Collateral Withdrawal

Underwriters can withdraw their collateral only if sufficient balance is available and no obligations remain.

Administration (Owner-only)

Set the minimum collateral ratio.

Set or update the oracle address.

Read-Only Views

Retrieve collateral balances, policy details, next policy ID, oracle address, and the current minimum collateral ratio.

📑 Contract Data Structures

Data Variables

next-policy-id: Counter for policy IDs.

min-collateral-ratio: Required minimum collateral percentage (default 150%).

oracle-address: Oracle address for triggering payouts.

Data Maps

collateral-balances: Tracks locked collateral per underwriter.

insurance-policies: Stores policy details (insured, coverage, premium, expiry, status, etc.).

policy-underwriters: (Placeholder) List of up to 50 underwriters per policy.

🛠️ Functions
🔓 Public

lock-collateral (amount uint) → Lock collateral to become an underwriter.

create-policy (coverage-amount uint) (premium uint) (duration-blocks uint) → Create new insurance policy.

trigger-payout (policy-id uint) → Oracle triggers claim payout.

withdraw-collateral (amount uint) → Withdraw previously locked collateral.

set-min-collateral-ratio (new-ratio uint) → Update collateral ratio (owner only).

set-oracle (new-oracle principal) → Set new oracle address (owner only).

📖 Read-Only

get-collateral-balance (user principal) → Returns user’s collateral balance.

get-policy (policy-id uint) → Returns policy details.

get-min-collateral-ratio () → Returns current collateral ratio.

get-oracle () → Returns oracle address.

get-next-policy-id () → Returns next available policy ID.

⚠️ Error Codes

u100: Owner-only function call.

u101: Insufficient collateral.

u102: Policy not found.

u103: Policy expired.

u104: Policy already claimed.

u105: Unauthorized access.

✅ Example Flow

Underwriter locks collateral using lock-collateral.

User creates policy by paying a premium via create-policy.

Oracle determines a valid claim event and calls trigger-payout.

Underwriter withdraws collateral when no active liabilities remain.

🔐 Security Considerations

Oracle authority is centralized—ensure the oracle is secure and trusted.

Collateral ratio is enforced to minimize insolvency risks.

Ensure policy durations and payouts are tested for edge cases.

📌 Future Improvements

Dynamic premium pricing based on collateral pool.

Support for multiple oracle sources (multi-sig oracle).

Integration with sBTC for real BTC-backed collateral instead of just STX transfers.

📜 License

MIT License – Free to use, modify, and distribute.