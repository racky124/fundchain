;; Crowdfunding Smart Contract for Stacks Blockchain

(define-trait sip010-trait
  (
    ;; Optional: for future SIP-010 integration (token-based crowdfunding)
  )
)

(define-data-var campaign-counter uint u0)

(define-map campaigns
  uint
  {
    creator: principal,
    goal: uint,
    deadline: uint,
    total-raised: uint,
    claimed: bool
  }
)

(define-map contributions
  { campaign-id: uint, contributor: principal }
  uint
)

;; Create a new crowdfunding campaign
(define-public (create-campaign (goal uint) (deadline uint))
  (let (
    (id (+ (var-get campaign-counter) u1))
  )
    (begin
      (var-set campaign-counter id)
      (map-set campaigns id {
        creator: tx-sender,
        goal: goal,
        deadline: deadline,
        total-raised: u0,
        claimed: false
      })
      (ok id)
    )
  )
)

;; Contribute STX to a campaign
(define-public (contribute (id uint) (amount uint))
  (let (
    (campaign (map-get? campaigns id))
  )
    (match campaign
      campaign-data
        (begin
          ;; Check if campaign hasn't expired
          (asserts! (< stacks-block-height (get deadline campaign-data)) (err u100))
          ;; Check if amount is greater than 0
          (asserts! (> amount u0) (err u109))
          ;; Transfer STX from contributor to contract
          (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
          ;; Update contribution record
          (map-set contributions 
            { campaign-id: id, contributor: tx-sender } 
            (+ (default-to u0 (map-get? contributions { campaign-id: id, contributor: tx-sender })) amount)
          )
          ;; Update campaign total
          (map-set campaigns id 
            (merge campaign-data { total-raised: (+ (get total-raised campaign-data) amount) })
          )
          (ok true)
        )
      (err u404) ;; campaign not found
    )
  )
)

;; Creator claims funds if goal is met
(define-public (claim-funds (id uint))
  (let (
    (campaign (map-get? campaigns id))
  )
    (match campaign
      campaign-data
        (begin
          ;; Only creator can claim
          (asserts! (is-eq tx-sender (get creator campaign-data)) (err u102))
          ;; Goal must be met
          (asserts! (>= (get total-raised campaign-data) (get goal campaign-data)) (err u103))
          ;; Campaign must be expired or goal met
          (asserts! (>= stacks-block-height (get deadline campaign-data)) (err u104))
          ;; Funds not already claimed
          (asserts! (not (get claimed campaign-data)) (err u105))
          ;; Mark as claimed
          (map-set campaigns id (merge campaign-data { claimed: true }))
          ;; Transfer funds to creator
          (try! (as-contract (stx-transfer? (get total-raised campaign-data) tx-sender (get creator campaign-data))))
          (ok true)
        )
      (err u404)
    )
  )
)

;; Contributors can request refund if goal not met after deadline
(define-public (request-refund (id uint))
  (let (
    (campaign (map-get? campaigns id))
    (contributed (map-get? contributions { campaign-id: id, contributor: tx-sender }))
  )
    (match campaign
      campaign-data
        (begin
          ;; Goal must not be met
          (asserts! (< (get total-raised campaign-data) (get goal campaign-data)) (err u106))
          ;; Campaign must be expired
          (asserts! (>= stacks-block-height (get deadline campaign-data)) (err u107))
          ;; Check if user contributed
          (match contributed
            amount
              (begin
                ;; Remove contribution record
                (map-delete contributions { campaign-id: id, contributor: tx-sender })
                ;; Update campaign total
                (map-set campaigns id 
                  (merge campaign-data { total-raised: (- (get total-raised campaign-data) amount) })
                )
                ;; Refund the contributor
                (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
                (ok true)
              )
            (err u108) ;; no contribution found
          )
        )
      (err u404) ;; campaign not found
    )
  )
)

;; Read-only functions for querying data
(define-read-only (get-campaign (id uint))
  (map-get? campaigns id)
)

(define-read-only (get-contribution (id uint) (contributor principal))
  (map-get? contributions { campaign-id: id, contributor: contributor })
)

(define-read-only (get-campaign-count)
  (var-get campaign-counter)
)

