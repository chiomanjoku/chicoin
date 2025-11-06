;; ChiCoin (CHI) - Simple fungible token example
;; This contract purposely keeps things minimal (no external trait deps)

(define-constant TOKEN-NAME "Chi Coin")
(define-constant TOKEN-SYMBOL "CHI")
(define-constant TOKEN-DECIMALS u6)        ;; 6 decimal places
(define-constant INITIAL-SUPPLY u100000000000) ;; 100,000 CHI with 6 decimals (100_000 * 10^6)

;; Storage
(define-data-var total-supply uint u0)
(define-map balances { owner: principal } { amount: uint })
(define-data-var initialized bool false)

;; Error codes
(define-constant ERR-ALREADY-INITIALIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-ZERO-AMOUNT (err u102))

;; Helpers
(define-private (get-balance-internal (who principal))
  (default-to u0 (get amount (map-get? balances { owner: who }))))

(define-private (set-balance (who principal) (new-amount uint))
  (if (is-eq new-amount u0)
      (begin (map-delete balances { owner: who }) true)
      (begin (map-set balances { owner: who } { amount: new-amount }) true)))

;; Initialize: mint INITIAL-SUPPLY to the first caller. Can only be called once.
(define-public (initialize)
  (if (var-get initialized)
      ERR-ALREADY-INITIALIZED
      (begin
        (map-set balances { owner: tx-sender } { amount: INITIAL-SUPPLY })
        (var-set total-supply INITIAL-SUPPLY)
        (var-set initialized true)
        (ok true))))

;; Transfer tokens from tx-sender to recipient
(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (not (is-eq amount u0)) ERR-ZERO-AMOUNT)
    (let (
      (sender tx-sender)
      (from-bal (get-balance-internal tx-sender))
      (to-bal (get-balance-internal recipient))
    )
      (if (>= from-bal amount)
          (begin
            (set-balance sender (- from-bal amount))
            (set-balance recipient (+ to-bal amount))
            (ok true))
          ERR-INSUFFICIENT-BALANCE))))

;; Read-only views
(define-read-only (get-name) (ok TOKEN-NAME))
(define-read-only (get-symbol) (ok TOKEN-SYMBOL))
(define-read-only (get-decimals) (ok TOKEN-DECIMALS))
(define-read-only (get-total-supply) (ok (var-get total-supply)))
(define-read-only (get-balance (who principal)) (ok (get-balance-internal who)))
