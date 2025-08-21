;; Carbon Offset Coordinator Contract
;; Manages carbon credit purchases and retirement

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-NOT-FOUND (err u202))
(define-constant ERR-INSUFFICIENT-CREDITS (err u203))
(define-constant ERR-ALREADY-RETIRED (err u204))

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var next-offset-id uint u1)
(define-data-var next-project-id uint u1)

;; Data maps
(define-map offset-projects
  { project-id: uint }
  {
    name: (string-ascii 100),
    project-type: (string-ascii 50),
    location: (string-ascii 100),
    credits-available: uint,
    credits-retired: uint,
    price-per-credit: uint,
    verified: bool,
    verifier: (optional principal),
    created-at: uint
  }
)

(define-map carbon-offsets
  { offset-id: uint }
  {
    purchaser: principal,
    project-id: uint,
    credits-purchased: uint,
    total-cost: uint,
    retired: bool,
    retirement-reason: (optional (string-ascii 200)),
    purchase-timestamp: uint,
    retirement-timestamp: (optional uint)
  }
)

(define-map user-offset-totals
  { user: principal }
  {
    total-purchased: uint,
    total-retired: uint,
    total-spent: uint,
    offset-count: uint
  }
)

;; Public functions

;; Register new offset project
(define-public (register-offset-project
    (name (string-ascii 100))
    (project-type (string-ascii 50))
    (location (string-ascii 100))
    (credits-available uint)
    (price-per-credit uint))
  (let
    (
      (project-id (var-get next-project-id))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> credits-available u0) ERR-INVALID-INPUT)
    (asserts! (> price-per-credit u0) ERR-INVALID-INPUT)

    (map-set offset-projects
      { project-id: project-id }
      {
        name: name,
        project-type: project-type,
        location: location,
        credits-available: credits-available,
        credits-retired: u0,
        price-per-credit: price-per-credit,
        verified: false,
        verifier: none,
        created-at: block-height
      }
    )

    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

;; Purchase carbon credits
(define-public (purchase-carbon-credits (project-id uint) (credits-requested uint))
  (let
    (
      (project (unwrap! (map-get? offset-projects { project-id: project-id }) ERR-NOT-FOUND))
      (available-credits (get credits-available project))
      (retired-credits (get credits-retired project))
      (remaining-credits (- available-credits retired-credits))
      (total-cost (* credits-requested (get price-per-credit project)))
      (offset-id (var-get next-offset-id))
    )
    (asserts! (> credits-requested u0) ERR-INVALID-INPUT)
    (asserts! (>= remaining-credits credits-requested) ERR-INSUFFICIENT-CREDITS)
    (asserts! (get verified project) ERR-NOT-AUTHORIZED)

    ;; Record the offset purchase
    (map-set carbon-offsets
      { offset-id: offset-id }
      {
        purchaser: tx-sender,
        project-id: project-id,
        credits-purchased: credits-requested,
        total-cost: total-cost,
        retired: false,
        retirement-reason: none,
        purchase-timestamp: block-height,
        retirement-timestamp: none
      }
    )

    ;; Update user totals
    (update-user-offset-totals tx-sender credits-requested u0 total-cost)

    ;; Increment offset ID
    (var-set next-offset-id (+ offset-id u1))

    (ok offset-id)
  )
)

;; Retire carbon credits
(define-public (retire-carbon-credits (offset-id uint) (reason (string-ascii 200)))
  (let
    (
      (offset (unwrap! (map-get? carbon-offsets { offset-id: offset-id }) ERR-NOT-FOUND))
      (project-id (get project-id offset))
      (project (unwrap! (map-get? offset-projects { project-id: project-id }) ERR-NOT-FOUND))
      (credits-to-retire (get credits-purchased offset))
    )
    (asserts! (is-eq tx-sender (get purchaser offset)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get retired offset)) ERR-ALREADY-RETIRED)

    ;; Update offset record
    (map-set carbon-offsets
      { offset-id: offset-id }
      (merge offset {
        retired: true,
        retirement-reason: (some reason),
        retirement-timestamp: (some block-height)
      })
    )

    ;; Update project retired credits
    (map-set offset-projects
      { project-id: project-id }
      (merge project {
        credits-retired: (+ (get credits-retired project) credits-to-retire)
      })
    )

    ;; Update user totals
    (update-user-offset-totals tx-sender u0 credits-to-retire u0)

    (ok true)
  )
)

;; Verify offset project
(define-public (verify-project (project-id uint))
  (let
    (
      (project (unwrap! (map-get? offset-projects { project-id: project-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)

    (map-set offset-projects
      { project-id: project-id }
      (merge project {
        verified: true,
        verifier: (some tx-sender)
      })
    )

    (ok true)
  )
)

;; Private functions

;; Update user offset totals
(define-private (update-user-offset-totals
    (user principal)
    (purchased uint)
    (retired uint)
    (spent uint))
  (let
    (
      (current-totals (default-to
        {
          total-purchased: u0,
          total-retired: u0,
          total-spent: u0,
          offset-count: u0
        }
        (map-get? user-offset-totals { user: user })
      ))
    )
    (map-set user-offset-totals
      { user: user }
      {
        total-purchased: (+ (get total-purchased current-totals) purchased),
        total-retired: (+ (get total-retired current-totals) retired),
        total-spent: (+ (get total-spent current-totals) spent),
        offset-count: (+ (get offset-count current-totals) (if (> purchased u0) u1 u0))
      }
    )
  )
)

;; Read-only functions

;; Get offset project details
(define-read-only (get-offset-project (project-id uint))
  (map-get? offset-projects { project-id: project-id })
)

;; Get carbon offset details
(define-read-only (get-carbon-offset (offset-id uint))
  (map-get? carbon-offsets { offset-id: offset-id })
)

;; Get user offset totals
(define-read-only (get-user-offset-totals (user principal))
  (map-get? user-offset-totals { user: user })
)

;; Calculate required offsets for emissions
(define-read-only (calculate-required-offsets (emissions-kg uint))
  (let
    (
      ;; Convert kg CO2 to credits (1 credit = 1000 kg CO2)
      (credits-needed (/ emissions-kg u1000))
      (remainder (mod emissions-kg u1000))
    )
    (ok (if (> remainder u0) (+ credits-needed u1) credits-needed))
  )
)

;; Get available credits for project
(define-read-only (get-available-credits (project-id uint))
  (match (map-get? offset-projects { project-id: project-id })
    project (ok (- (get credits-available project) (get credits-retired project)))
    ERR-NOT-FOUND
  )
)
