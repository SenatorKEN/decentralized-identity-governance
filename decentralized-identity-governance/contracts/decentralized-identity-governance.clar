

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
