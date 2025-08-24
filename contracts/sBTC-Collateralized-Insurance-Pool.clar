;; sBTC Collateralized Insurance Pool
;; A smart contract for managing collateralized insurance policies using sBTC

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-collateral (err u101))
(define-constant err-policy-not-found (err u102))
(define-constant err-policy-expired (err u103))
(define-constant err-already-claimed (err u104))
(define-constant err-unauthorized (err u105))

;; Data Variables
(define-data-var next-policy-id uint u1)
(define-data-var min-collateral-ratio uint u150) ;; 150% minimum collateral ratio
(define-data-var oracle-address principal contract-owner)

;; Data Maps
(define-map collateral-balances principal uint)
(define-map insurance-policies 
  uint 
  {
    insured: principal,
    coverage-amount: uint,
    premium-paid: uint,
    collateral-locked: uint,
    expiry-block: uint,
    active: bool,
    claimed: bool
  })
(define-map policy-underwriters uint (list 50 {underwriter: principal, collateral: uint}))

;; Public Functions

;; Lock collateral to become an underwriter
(define-public (lock-collateral (amount uint))
  (let 
    (
      (current-balance (default-to u0 (map-get? collateral-balances tx-sender)))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set collateral-balances tx-sender (+ current-balance amount))
    (ok amount)
  )
)

;; Create an insurance policy
(define-public (create-policy (coverage-amount uint) (premium uint) (duration-blocks uint))
  (let 
    (
      (policy-id (var-get next-policy-id))
      (required-collateral (* coverage-amount (var-get min-collateral-ratio)))
      (collateral-per-policy (/ required-collateral u100))
    )
    ;; Transfer premium to contract
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))

    ;; Create policy
    (map-set insurance-policies policy-id {
      insured: tx-sender,
      coverage-amount: coverage-amount,
      premium-paid: premium,
      collateral-locked: collateral-per-policy,
      expiry-block: (+ block-height duration-blocks),
      active: true,
      claimed: false
    })

    (var-set next-policy-id (+ policy-id u1))
    (ok policy-id)
  )
)

;; Oracle triggers payout for a policy
(define-public (trigger-payout (policy-id uint))
  (let 
    (
      (policy (unwrap! (map-get? insurance-policies policy-id) err-policy-not-found))
      (oracle (var-get oracle-address))
    )
    ;; Only oracle can trigger payouts
    (asserts! (is-eq tx-sender oracle) err-unauthorized)

    ;; Check policy is active and not expired
    (asserts! (get active policy) err-policy-expired)
    (asserts! (< block-height (get expiry-block policy)) err-policy-expired)
    (asserts! (not (get claimed policy)) err-already-claimed)

    ;; Transfer coverage amount to insured
    (try! (as-contract (stx-transfer? (get coverage-amount policy) tx-sender (get insured policy))))

    ;; Mark policy as claimed
    (map-set insurance-policies policy-id 
      (merge policy {claimed: true, active: false}))

    (ok (get coverage-amount policy))
  )
)

;; Withdraw collateral (only if no active policies)
(define-public (withdraw-collateral (amount uint))
  (let 
    (
      (current-balance (default-to u0 (map-get? collateral-balances tx-sender)))
    )
    (asserts! (>= current-balance amount) err-insufficient-collateral)

    ;; Transfer collateral back to user
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set collateral-balances tx-sender (- current-balance amount))

    (ok amount)
  )
)

;; Administrative Functions

;; Set minimum collateral ratio (owner only)
(define-public (set-min-collateral-ratio (new-ratio uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set min-collateral-ratio new-ratio)
    (ok new-ratio)
  )
)

;; Set oracle address (owner only)
(define-public (set-oracle (new-oracle principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set oracle-address new-oracle)
    (ok new-oracle)
  )
)

;; Read-only Functions

;; Get collateral balance for a user
(define-read-only (get-collateral-balance (user principal))
  (default-to u0 (map-get? collateral-balances user))
)

;; Get policy details
(define-read-only (get-policy (policy-id uint))
  (map-get? insurance-policies policy-id)
)

;; Get current minimum collateral ratio
(define-read-only (get-min-collateral-ratio)
  (var-get min-collateral-ratio)
)

;; Get oracle address
(define-read-only (get-oracle)
  (var-get oracle-address)
)

;; Get next policy ID
(define-read-only (get-next-policy-id)
  (var-get next-policy-id)
)