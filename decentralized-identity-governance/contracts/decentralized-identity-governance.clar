

;; Constants and Error Codes
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-IDENTITY-NOT-FOUND (err u102))
(define-constant ERR-INVALID-CREDENTIAL (err u103))
(define-constant ERR-GOVERNANCE-RESTRICTION (err u104))
(define-constant ERR-VOTING-PERIOD-CLOSED (err u105))
(define-constant ERR-DUPLICATE-VOTE (err u106))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u107))
(define-constant ERR-INVALID-PARAMETER (err u108))
(define-constant ERR-CREDENTIAL-EXPIRED (err u109))
(define-constant ERR-RATE-LIMIT-EXCEEDED (err u110))
(define-constant ERR-CONTRACT-PAUSED (err u111))
(define-constant ERR-THRESHOLD-NOT-MET (err u112))

(define-constant ERR-IDENTITY-ALREADY-EXISTS (err u113))
(define-constant ERR-MAX-CREDENTIALS-REACHED (err u114))
(define-constant ERR-SIGNATURE-INVALID (err u115))
(define-constant ERR-DELEGATION-NOT-FOUND (err u116))
(define-constant ERR-MULTISIG-THRESHOLD-NOT-MET (err u117))
(define-constant ERR-ESCROW-LOCKED (err u118))
(define-constant ERR-ORACLE-DATA-UNAVAILABLE (err u119))

;; Identity Verification Levels
(define-constant IDENTITY-UNVERIFIED u0)
(define-constant IDENTITY-BASIC u1)
(define-constant IDENTITY-INTERMEDIATE u2)
(define-constant IDENTITY-ADVANCED u3)

;; Governance Proposal States
(define-constant PROPOSAL-DRAFT u0)
(define-constant PROPOSAL-ACTIVE u1)
(define-constant PROPOSAL-PASSED u2)
(define-constant PROPOSAL-REJECTED u3)

;; NEW CONTRACT STATE VARIABLES
(define-data-var contract-paused bool false)
(define-data-var admin-address principal CONTRACT-OWNER)
(define-data-var fee-basis-points uint u50)  ;; 0.5% default fee
(define-data-var protocol-treasury principal CONTRACT-OWNER)
(define-data-var min-voting-threshold uint u100)  ;; Minimum votes required

;; Comprehensive Identity Structure
(define-map identity-profiles
  principal
  {
    did: (buff 32),
    verification-level: uint,
    credentials: (list 10 {
      credential-type: (string-utf8 50),
      issuer: principal,
      issuance-timestamp: uint,
      expiration-timestamp: uint,
      verification-hash: (buff 32)
    }),
    reputation-score: {
      overall-score: uint,
      category-scores: (list 5 {
        category: (string-utf8 50),
        score: uint
      })
    },
    social-verification: {
      linked-accounts: (list 5 {
        platform: (string-utf8 30),
        account-id: (string-utf8 100),
        verification-status: bool
      }),
      proof-of-humanity: bool
    },
    privacy-settings: {
      default-visibility: (string-utf8 20),
      selective-disclosure: bool
    }
  }
)

;; Credential Issuer Reputation
(define-map credential-issuer-reputation
  principal
  {
    total-credentials-issued: uint,
    valid-credentials: uint,
    revoked-credentials: uint,
    reputation-score: uint
  }
)

;; Read-only Functions for Retrieving Information
(define-read-only (get-identity-profile (subject principal))
  (map-get? identity-profiles subject)
)


(define-read-only (get-credential-issuer-reputation (issuer principal))
  (map-get? credential-issuer-reputation issuer)
)

;; Governance Proposals
(define-map governance-proposals
  uint
  {
    id: uint,
    title: (string-utf8 100),
    description: (string-utf8 500),
    proposer: principal,
    start-block-height: uint,
    end-block-height: uint,
    status: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    execution-params: (list 5 {
      param-name: (string-utf8 50),
      param-value: (string-utf8 100)
    })
  }
)

;; Vote Registry
(define-map votes
  { proposal-id: uint, voter: principal }
  { vote-type: bool, weight: uint, timestamp: uint }
)

;; Activity Log
(define-map activity-log
  { user: principal, action-id: uint }
  {
    action-type: (string-utf8 50),
    timestamp: uint,
    metadata: (optional (string-utf8 200))
  }
)

;; Rate Limiting
(define-map rate-limits
  principal
  {
    last-action-time: uint,
    action-count: uint,
    timeout-until: uint
  }
)

;; Feature Flags
(define-map feature-flags
  (string-utf8 50)
  {
    enabled: bool,
    admin-only: bool,
    min-identity-level: uint
  }
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? governance-proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-contract-admin)
  (var-get admin-address)
)

(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

(define-read-only (get-fee-basis-points)
  (var-get fee-basis-points)
)

(define-read-only (get-feature-status (feature-name (string-utf8 50)))
  (map-get? feature-flags feature-name)
)

(define-read-only (check-rate-limit (user principal))
  (let ((user-limits (default-to 
    { last-action-time: u0, action-count: u0, timeout-until: u0 } 
    (map-get? rate-limits user))))
    (< (get timeout-until user-limits) stacks-block-height)
  )
)


(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-admin (address principal))
  (or (is-eq address CONTRACT-OWNER) (is-eq address (var-get admin-address)))
)

(define-private (update-rate-limit (user principal))
  (let ((current-limits (default-to 
        { last-action-time: u0, action-count: u0, timeout-until: u0 } 
        (map-get? rate-limits user)))
        (current-block stacks-block-height))
    (if (is-eq (get last-action-time current-limits) current-block)
      (let ((new-count (+ u1 (get action-count current-limits))))
        (map-set rate-limits user
          (merge current-limits {
            action-count: new-count,
            timeout-until: (if (> new-count u5)
                            (+ current-block u10)
                            (get timeout-until current-limits))
          })))
      (map-set rate-limits user
        { last-action-time: current-block, action-count: u1, timeout-until: u0 })
    )
  )
)

(define-constant IDENTITY-ENTERPRISE u4)
(define-constant IDENTITY-GUARDIAN u5)

(define-constant PROPOSAL-PENDING-REVIEW u4)
(define-constant PROPOSAL-IMPLEMENTATION u5)
(define-constant PROPOSAL-CANCELLED u6)


(define-data-var protocol-upgrade-timelock uint u1440) ;; 24 hours in blocks
(define-data-var emergency-mode bool false)
(define-data-var guardian-multisig-threshold uint u3) ;; Require 3 guardians for emergency actions
(define-data-var oracle-update-frequency uint u144) ;; Update every ~24 hours (assuming 10 min blocks)

;; Enhanced identity structure with biometric verification and recovery options
(define-map enhanced-identity-details
  principal
  {
    biometric-hash: (optional (buff 64)),
    recovery-contacts: (list 3 principal),
    last-verification-date: uint,
    risk-score: uint,
    identity-metadata: (list 10 {
      meta-key: (string-utf8 30),
      meta-value: (string-utf8 100),
      is-public: bool
    }),
    compliance-status: {
      last-check: uint,
      status-code: uint,
      jurisdiction: (string-utf8 30)
    }
  }
)

;; Delegated authority system
(define-map delegations
  { delegator: principal, action-type: (string-utf8 30) }
  {
    delegate: principal,
    restrictions: (list 5 {
      restriction-type: (string-utf8 30),
      restriction-value: (string-utf8 100)
    }),
    expiration: uint,
    revocable: bool
  }
)

;; Multi-signature control
(define-map multisig-requirements
  (string-utf8 30) ;; action type
  {
    required-signers: uint,
    authorized-signers: (list 10 principal),
    timelock-blocks: uint
  }
)

;; Pending multisig transactions
(define-map pending-multisig-txs
  uint ;; transaction-id
  {
    action-type: (string-utf8 30),
    initiator: principal,
    signers: (list 10 principal),
    params: (list 5 {
      param-name: (string-utf8 30),
      param-value: (string-utf8 100)
    }),
    expiration-height: uint
  }
)

;; Escrow system for conditional transactions
(define-map escrow-deposits
  uint ;; escrow-id
  {
    depositor: principal,
    recipient: principal,
    amount: uint,
    lock-until: uint,
    condition-type: (string-utf8 30),
    condition-params: (list 3 {
      param-name: (string-utf8 30),
      param-value: (string-utf8 100)
    }),
    status: (string-utf8 20)
  }
)

;; Oracle data feeds
(define-map oracle-data
  (string-utf8 30) ;; data-feed-id
  {
    value: (string-utf8 100),
    source: principal,
    last-updated: uint,
    signature: (buff 64),
    confidence-score: uint
  }
)

;; Read-only Functions for Retrieving Information
(define-read-only (get-identity-profile (subject principal))
  (map-get? identity-profiles subject)
)

(define-read-only (get-credential-issuer-reputation (issuer principal))
  (map-get? credential-issuer-reputation issuer)
)



