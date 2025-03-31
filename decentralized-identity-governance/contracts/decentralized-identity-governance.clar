

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
