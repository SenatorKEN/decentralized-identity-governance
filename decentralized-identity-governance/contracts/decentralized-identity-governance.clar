

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