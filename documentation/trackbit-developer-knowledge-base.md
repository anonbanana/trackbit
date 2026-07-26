# TrackBit Developer Knowledge Base

## A Comprehensive Guide Based on "Every Programmer Should Know"

**Project:** TrackBit - Offline-First Business Management Application  
**Version:** 1.0.0  
**Date:** July 26, 2026  
**Source:** [github.com/mtdvio/every-programmer-should-know](https://github.com/mtdvio/every-programmer-should-know)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Security](#2-security)
3. [Distributed Systems](#3-distributed-systems)
4. [Architecture](#4-architecture)
5. [Memory Management](#5-memory-management)
6. [Floating Point Arithmetic](#6-floating-point-arithmetic)
7. [Unicode and Strings](#7-unicode-and-strings)
8. [Latency and Performance](#8-latency-and-performance)
9. [Time and Timezones](#9-time-and-timezones)
10. [Code Quality Practices](#10-code-quality-practices)
11. [Falsehoods Programmers Believe](#11-falsehoods-programmers-believe)
12. [TrackBit Priority Action Items](#12-trackbit-priority-action-items)
13. [References](#13-references)

---

## 1. Introduction

This document compiles essential software engineering knowledge from the "Every Programmer Should Know" repository (100K+ stars on GitHub) and maps each concept directly to the TrackBit codebase. The goal is to provide actionable guidance for improving code quality, security, reliability, and maintainability.

TrackBit is a Flutter-based, offline-first business management application with:
- 21 SQLite (Drift) tables
- 13 feature modules (POS, Inventory, CRM, Sales, Invoicing, Expenses, Employees, Roles, Reports, Sync, Settings, Auth, Dashboard)
- Peer-to-peer data synchronization via WebSocket
- Role-Based Access Control (RBAC) with 43 permissions
- Cross-platform targets: Android, iOS, Web

---

## 2. Security

### 2.1 OWASP Top 10

**Source:** [owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten)

The OWASP Top 10 is the "gold standard" for web application vulnerabilities. While TrackBit is primarily a mobile/offline app, several OWASP categories are directly relevant:

| OWASP Category | TrackBit Relevance | Current Status | Action Required |
|---|---|---|---|
| A01: Broken Access Control | RBAC with 43 permissions, role hierarchy | Implemented | Audit all permission checks at repository level |
| A02: Cryptographic Failures | Password hashing uses SHA-256 | **CRITICAL** | Upgrade to bcrypt/argon2 |
| A03: Injection | SQL queries via Drift ORM | Partially mitigated | Verify no raw SQL injection vectors in sync_service |
| A04: Insecure Design | Peer-to-peer sync architecture | Needs review | Add mutual authentication for sync peers |
| A05: Security Misconfiguration | Default admin credentials (admin/admin123) | Known issue | Add force password change on first login |
| A06: Vulnerable Components | Dependencies may have known CVEs | Not audited | Run `dart audit` regularly |
| A07: Auth Failures | Session persistence via FlutterSecureStorage | Implemented | Add rate limiting on login attempts |
| A08: Data Integrity Failures | Sync queue accepts payloads from peers | Needs review | Validate all incoming sync payloads |
| A09: Logging Failures | No crash reporting or audit logging | **MISSING** | Add Sentry + audit trail |
| A10: SSRF | Not applicable (no server-side rendering) | N/A | N/A |

### 2.2 Cryptographic Right Answers

**Source:** [gist.github.com/tqbf/be58d2d39690c3b366ad](https://gist.github.com/tqbf/be58d2d39690c3b366ad)

Key principles for TrackBit:

1. **Password Hashing:** SHA-256 is NOT designed for password hashing. It's too fast, making brute-force attacks feasible. Use bcrypt, scrypt, or argon2 instead.
   - **Current:** `lib/features/auth/data/repositories/auth_repository_impl.dart` uses SHA-256
   - **Fix:** Use `bcrypt` package or `argon2_ffi`

2. **Encryption at Rest:** SQLite database is stored unencrypted on device. Consider SQLCipher for sensitive business data.

3. **Encryption in Transit:** WebSocket sync uses `wss://` (good), but ensure certificate pinning is implemented.

4. **Random Number Generation:** Use `dart:crypto` `SecureRandom` for tokens, not `Random()`.

### 2.3 Rolling Your Own Crypto

**Source:** [loup-vaillant.fr/articles/rolling-your-own-crypto](http://loup-vaillant.fr/articles/rolling-your-own-crypto)

TrackBit should NEVER implement custom cryptographic algorithms. The codebase correctly uses:
- `crypto` package for SHA-256 (though this should be upgraded)
- `flutter_secure_storage` for key storage
- `web_socket_channel` for encrypted transport

**Rule:** Always use well-tested, established cryptographic libraries.

### 2.4 Hashing, Encryption and Encoding

**Source:** [integralist.co.uk/posts/hashing-and-encryption](https://www.integralist.co.uk/posts/hashing-and-encryption/)

| Concept | TrackBit Usage | Correct? |
|---|---|---|
| Hashing (SHA-256) | Password storage | **No** - too fast for passwords |
| Encryption (wss://) | WebSocket sync | Yes |
| Encoding (base64) | Image storage paths | Yes |
| HMAC | Not used | Consider for sync payload integrity |

---

## 3. Distributed Systems

### 3.1 Time, Clocks and Ordering of Events (Lamport)

**Source:** Lamport, 1978 - "Time, Clocks, and the Ordering of Events in a Distributed System"

TrackBit's peer-to-peer sync is a distributed system. When two peers modify the same record independently, conflicts arise. Lamport's paper establishes that:

- **Happens-before relationship** must be maintained
- **Logical clocks** can establish ordering without physical time synchronization

**Current TrackBit Sync Behavior:**
- Uses `sync_queue` table with status (PENDING/SYNCED)
- Timestamps are used for ordering
- No vector clocks or conflict resolution strategy

**Recommended Improvement:**
```dart
// Add vector clock to sync entries
class SyncEntry {
  final String entityTable;
  final String recordId;
  final String operation;
  final String payloadJson;
  final Map<String, int> vectorClock; // {deviceId: logicalTime}
  final int timestamp;
}
```

### 3.2 There is No Now

**Source:** [queue.acm.org/detail.cfm?id=2745385](https://queue.acm.org/detail.cfm?id=2745385)

Clock skew between peer devices means "now" is different for each device. TrackBit's sync assumes synchronized clocks, which is dangerous.

**Impact on TrackBit:**
- Order timestamps may be inconsistent across peers
- Last-write-wins conflict resolution may choose wrong version
- `lastSeen` in `sync_peers` table may be inaccurate

**Mitigation:**
- Use NTP-synchronized time when available
- Add clock skew tolerance window (e.g., 5 seconds)
- Prefer vector clocks over physical timestamps

### 3.3 Fallacies of Distributed Computing

**Source:** [pages.cs.wisc.edu/~zuyu/files/fallacies.pdf](https://pages.cs.wisc.edu/~zuyu/files/fallacies.pdf)

The 8 fallacies and TrackBit's exposure:

| Fallacy | TrackBit Status | Risk Level |
|---|---|---|
| 1. The network is reliable | WebSocket can disconnect | HIGH |
| 2. Latency is zero | Sync may be slow on LAN | MEDIUM |
| 3. Bandwidth is infinite | Large payloads (receipt images) | MEDIUM |
| 4. The network is secure | wss:// used | LOW |
| 5. Topology doesn't change | Peers join/leave | HIGH |
| 6. There is one administrator | Single-user app | LOW |
| 7. Transport cost is zero | UDP broadcast every 3s | LOW |
| 8. The network is homogeneous | Mixed Android/iOS/Web | MEDIUM |

**Recommendations:**
- Add exponential backoff retry for failed sync
- Implement sync payload chunking for large transfers
- Add peer health checks beyond UDP heartbeat

### 3.4 Designing Data-Intensive Applications

**Source:** Martin Kleppmann's book

Key takeaways for TrackBit:
- **Replication:** Sync is essentially single-leader replication with conflict resolution
- **Partitioning:** Each peer has a complete copy (no partitioning needed)
- **Transactions:** Order processing is already wrapped in Drift transactions (good)

---

## 4. Architecture

### 4.1 Out of the Tar Pit

**Source:** [github.com/papers-we-love/papers-we-love](https://github.com/papers-we-love/papers-we-love)

The paper argues that complexity arises from accidental state management. TrackBit's Clean Architecture helps, but:

- **Entities** should be immutable (currently they're not)
- **State** should be managed through pure functions where possible
- **Side effects** should be isolated in the data layer (already done)

**Recommendation:** Consider using `freezed` package for immutable entities.

### 4.2 CQRS and Event Sourcing

**Source:** [youtube.com/watch?v=JHGkaShoyNs](https://www.youtube.com/watch?v=JHGkaShoyNs)

TrackBit's sync queue is already an event-sourcing-like pattern:
- Changes are logged as events in `sync_queue`
- Events are applied to peers in order
- Events can be replayed

**Improvement Opportunity:**
- Formalize the event schema (currently JSON strings)
- Add event versioning for backward compatibility
- Consider event store pattern for audit trail

### 4.3 Entity-Component-System Architecture

**Source:** [youtube.com/watch?v=lNTaC-JWmdI](https://www.youtube.com/watch?v=lNTaC-JWmdI)

While ECS is primarily for game engines, the separation of concerns principle applies:
- **Entities** = data models (already separated)
- **Components** = features (already separated by module)
- **Systems** = repositories/services (already separated)

TrackBit's Clean Architecture is well-aligned with this principle.

### 4.4 Practical Object Oriented Design

**Source:** [poodr.com](https://www.poodr.com/)

Key principles for TrackBit:
- **Single Responsibility:** Each repository handles one entity type
- **Open/Closed:** Feature modules should be extensible without modification
- **Dependency Inversion:** Abstract repositories in domain layer, concrete in data layer

TrackBit follows these principles well through Clean Architecture.

---

## 5. Memory Management

### 5.1 What Every Programmer Should Know About Memory

**Source:** [lwn.net/Articles/250967/](https://lwn.net/Articles/250967/)

While Dart has garbage collection, memory leaks still occur through:
- **Unclosed stream subscriptions**
- **Retained references in providers**
- **Unclosed database connections**

**TrackBit Risk Areas:**
1. WebSocket connections in `web_socket_sync_service.dart`
2. mDNS listeners in `peer_discovery_service.dart`
3. Stream controllers in state notifiers
4. Database connections (Drift handles this, but verify)

**Audit Checklist:**
- [ ] All `StreamSubscription` objects are cancelled in `dispose()`
- [ ] All Riverpod providers use `autoDispose` where appropriate
- [ ] WebSocket connections are closed when sync stops
- [ ] mDNS socket is closed when discovery stops
- [ ] No circular references between providers

### 5.2 Memory Leaks in Dart/Flutter

**Common patterns to check:**
```dart
// BAD: Stream subscription not cancelled
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(someStreamProvider).whenData((data) { ... });
    // If provider doesn't autoDispose, stream leaks
  }
}

// GOOD: Auto-disposing provider
final someStreamProvider = StreamProvider.autoDispose((ref) {
  final controller = StreamController();
  ref.onDispose(() => controller.close());
  return controller.stream;
});
```

---

## 6. Floating Point Arithmetic

### 6.1 The Floating Point Guide

**Source:** [floating-point-gui.de](http://floating-point-gui.de/)

**CRITICAL FOR TRACKBIT:** The app handles money (prices, totals, tax, discounts) using `double` type, which has floating-point precision issues.

**Example of the problem:**
```dart
double total = 0.1 + 0.2;
print(total); // 0.30000000000000004
```

**Current TrackBit money fields:**
- `Products.price` (double)
- `Products.cost` (double)
- `OrderItems.unitPrice` (double)
- `OrderItems.subtotal` (double)
- `Orders.subtotal`, `tax`, `discount`, `total` (double)
- `Payments.amount` (double)
- `Expenses.amount` (double)
- `Employees.salary` (double)

### 6.2 What Every Computer Scientist Should Know About Floating-Point Arithmetic

**Source:** [docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)

**Solution Options for TrackBit:**

1. **Integer Cents (Recommended for simplicity):**
   - Store all money as `int` (cents)
   - Display: `amount ~/ 100` dollars, `amount % 100` cents
   - Example: $19.99 stored as `1999`

2. **Decimal Package (Recommended for precision):**
   - Use `decimal` package for exact decimal arithmetic
   - `Decimal.parse('19.99')` instead of `19.99`

3. **Rational Numbers:**
   - Store as numerator/denominator
   - More complex but exact

**Recommended Approach:** Integer cents for simplicity, or `decimal` package for readability.

---

## 7. Unicode and Strings

### 7.1 Unicode and Character Sets (Joel on Software)

**Source:** [joelonsoftware.com/articles/Unicode.html](https://www.joelonsoftware.com/articles/Unicode.html)

TrackBit stores:
- Product names (may contain accented characters: "Café", "Ñoño")
- Customer names (international names)
- Addresses
- Notes

**Potential Issues:**
- Search may fail with Unicode normalization
- Sorting may be incorrect
- String length calculations may be wrong

**Recommendations:**
```dart
// BAD: Case-sensitive search
products.where((p) => p.name.contains(query));

// GOOD: Unicode-normalized search
products.where((p) => 
  p.name.toLowerCase().contains(query.toLowerCase()));
```

### 7.2 Homoglyphs

**Source:** [github.com/codebox/homoglyph](https://github.com/codebox/homoglyph)

Homoglyphs are characters that look alike but are different (e.g., "а" Cyrillic vs "a" Latin). This affects:
- **SKU validation:** A malicious SKU could use homoglyphs
- **Barcode scanning:** May misread similar characters
- **Usernames:** Could create confusingly similar usernames

**Recommendation:** Validate input characters against a whitelist for SKUs and barcodes.

---

## 8. Latency and Performance

### 8.1 Latency Numbers Every Programmer Should Know

**Source:** [gist.github.com/jboner/2841832](https://gist.github.com/jboner/2841832)

| Operation | Latency | TrackBit Target |
|---|---|---|
| L1 cache reference | 0.5 ns | - |
| L2 cache reference | 7 ns | - |
| Main memory reference | 100 ns | - |
| SSD random read | 150 μs | DB queries < 1ms |
| Read 1 MB from SSD | 1 ms | - |
| Read 1 MB from disk | 20 ms | - |
| Send 1 MB to US East via AWS | 13 ms | - |
| SSD random write | 150 μs | Stock updates < 1ms |

**TrackBit Performance Targets:**
- POS checkout: < 200ms (user expectation)
- Product search: < 100ms
- Database queries: < 50ms
- Sync message round-trip: < 2s on LAN

### 8.2 Interactive Latency Infographics

**Source:** [people.eecs.berkeley.edu/~rcs/research/interactive_latency.html](https://people.eecs.berkeley.edu/~rcs/research/interactive_latency.html)

Key insight: **100ms** is the threshold for "instant" response. TrackBit's POS must respond within this window for a good user experience.

**Optimization Strategies:**
1. Use database indexes on frequently queried columns
2. Implement pagination for large lists (products, orders)
3. Cache frequently accessed data (categories, settings)
4. Use `StreamProvider` for real-time UI updates

---

## 9. Time and Timezones

### 9.1 The Problem with Timezones

**Source:** [youtube.com/watch?v=-5wpm-gesOY](https://www.youtube.com/watch?v=-5wpm-gesOY)

TrackBit stores timestamps for:
- Order creation
- Expense recording
- Sync operations
- Employee hire dates
- Invoice due dates

**Current Issue:** If peers are in different timezones, timestamps may conflict.

**Best Practice:**
```dart
// Store as UTC
final now = DateTime.now().toUtc();

// Display in local time
final localTime = now.toLocal();
```

### 9.2 Some Notes About Time

**Source:** [unix4lyfe.org/time/](https://unix4lyfe.org/time/)

Key principles:
- **Always store UTC:** Never store local time
- **Convert on display:** Convert UTC to local only when showing to user
- **Handle DST:** Daylight Saving Time causes ambiguity
- **Clock skew:** Devices may have different times

**TrackBit Recommendation:** Ensure all timestamps are stored as UTC and converted to local only in the presentation layer.

---

## 10. Code Quality Practices

### 10.1 Clean Code

**Source:** Robert C. Martin's "Clean Code"

Principles for TrackBit:
- **Meaningful Names:** Variables and functions should reveal intent
- **Small Functions:** Each function should do one thing
- **No Magic Numbers:** Use constants (e.g., `AppConstants.maxLoginAttempts`)
- **DRY:** Don't Repeat Yourself

### 10.2 Test Driven Development

**Source:** Kent Beck's "Test Driven Development: By Example"

**Current TrackBit Test Coverage:**
- 39 tests across 5 test files
- 10 of 13 features have NO tests
- No integration tests
- No code coverage tracking

**Target:** 200+ tests covering all features, with 80%+ coverage.

### 10.3 Working Effectively with Legacy Code

**Source:** Michael Feathers' book

For adding tests to untested TrackBit code:
1. **Characterization Tests:** Write tests that capture current behavior
2. **Sprout Method:** Extract new functionality into testable methods
3. **Wrap Method:** Add testing hooks around existing code
4. **Extract and Override:** Pull out logic into testable subclasses

### 10.4 The Art of Readable Code

**Source:** [goodreads.com/book/show/8677004](https://www.goodreads.com/book/show/8677004)

Key practices:
- **Code should read like prose**
- **Use consistent naming conventions**
- **Add comments for "why", not "what"**
- **Keep functions short (< 20 lines)**

---

## 11. Falsehoods Programmers Believe

### 11.1 Awesome Falsehoods

**Source:** [github.com/kdeldycke/awesome-falsehood](https://github.com/kdeldycke/awesome-falsehood)

Falsehoods relevant to TrackBit:

| Falsehood | TrackBit Impact | Mitigation |
|---|---|---|
| "Names are always ASCII" | Customer/product names | Use Unicode support |
| "Phone numbers are numbers" | Customer phone field | Store as string, validate format |
| "Email addresses are simple" | Customer email | Use proper validation regex |
| "Addresses have a fixed format" | Customer/business address | Use flexible text fields |
| "A user has only one email" | Customer records | Allow multiple contacts |
| "Dates are always in the same format" | International usage | Use ISO 8601 (UTC) |
| "Money is always positive" | Expenses could be negative | Validate at business level |
| "There's only one way to spell a name" | Customer names | Case-insensitive search |

---

## 12. TrackBit Priority Action Items

### P0 - Critical (Do Immediately)

| # | Action | Knowledge Source | Files Affected |
|---|---|---|---|
| 1 | Replace SHA-256 with bcrypt for passwords | Cryptographic Right Answers | `auth_repository_impl.dart` |
| 2 | Replace `double` money with integer cents or `decimal` | Floating Point Guide | All entity classes, all repositories |
| 3 | Audit SQL injection in sync service | OWASP A03 | `sync_service.dart` |
| 4 | Add force password change for default admin | OWASP A05 | `main.dart` |

### P1 - High Priority (This Week)

| # | Action | Knowledge Source | Files Affected |
|---|---|---|---|
| 5 | Add vector clocks to sync entries | Lamport Clocks | `sync_entry.dart`, `sync_service.dart` |
| 6 | Audit all stream/provider disposal | Memory Management | All providers, all services |
| 7 | Normalize Unicode for search | Unicode Guide | All search functionality |
| 8 | Add Sentry crash reporting | OWASP A09 | `main.dart`, `pubspec.yaml` |

### P2 - Medium Priority (This Month)

| # | Action | Knowledge Source | Files Affected |
|---|---|---|---|
| 9 | Add retry logic with backoff for sync | Distributed Fallacies | `sync_service.dart` |
| 10 | Increase test coverage to 200+ tests | TDD | `test/` directory |
| 11 | Add clock skew tolerance for sync | "There is No Now" | `sync_service.dart` |
| 12 | Enforce UTC for all timestamps | Timezone Guide | All entities with timestamps |

### P3 - Low Priority (Next Month)

| # | Action | Knowledge Source | Files Affected |
|---|---|---|---|
| 13 | Consider immutable entities with freezed | Out of the Tar Pit | All entity classes |
| 14 | Add event versioning for sync | Event Sourcing | `sync_service.dart` |
| 15 | Validate input characters for SKUs | Homoglyphs | `product_form.dart` |
| 16 | Add comprehensive audit logging | OWASP A09 | All repositories |

---

## 13. References

### Primary Source
- [Every Programmer Should Know](https://github.com/mtdvio/every-programmer-should-know)

### Security
- [OWASP Top 10](https://owasp.org/www-project-top-ten)
- [Cryptographic Right Answers](https://gist.github.com/tqbf/be58d2d39690c3b366ad)
- [Rolling Your Own Crypto](http://loup-vaillant.fr/articles/rolling-your-own-crypto)
- [Hashing, Encryption and Encoding](https://www.integralist.co.uk/posts/hashing-and-encryption/)

### Distributed Systems
- [Time, Clocks and Ordering of Events](https://www.microsoft.com/en-us/research/publication/time-clocks-ordering-events-distributed-system/)
- [There is No Now](https://queue.acm.org/detail.cfm?id=2745385)
- [Fallacies of Distributed Computing](https://pages.cs.wisc.edu/~zuyu/files/fallacies.pdf)
- [Designing Data-Intensive Applications](https://www.goodreads.com/book/show/23463279-designing-data-intensive-applications)

### Architecture
- [Out of the Tar Pit](https://github.com/papers-we-love/papers-we-love)
- [CQRS and Event Sourcing](https://www.youtube.com/watch?v=JHGkaShoyNs)
- [Practical Object Oriented Design](https://www.poodr.com/)

### Memory and Performance
- [What Every Programmer Should Know About Memory](https://lwn.net/Articles/250967/)
- [Latency Numbers Every Programmer Should Know](https://gist.github.com/jboner/2841832)

### Numbers and Strings
- [The Floating Point Guide](http://floating-point-gui.de/)
- [What Every Computer Scientist Should Know About Floating-Point](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)
- [Unicode and Character Sets](https://www.joelonsoftware.com/articles/Unicode.html)

### Time
- [The Problem with Timezones](https://www.youtube.com/watch?v=-5wpm-gesOY)
- [Some Notes About Time](https://unix4lyfe.org/time/)

### Code Quality
- [Clean Code](https://www.goodreads.com/book/show/3735293-clean-code)
- [Test Driven Development](https://www.goodreads.com/book/show/387190.Test_Driven_Development)
- [Working Effectively with Legacy Code](https://www.goodreads.com/book/show/44919.Working_Effectively_with_Legacy_Code)
- [The Art of Readable Code](https://www.goodreads.com/book/show/8677004)

### Falsehoods
- [Awesome Falsehoods](https://github.com/kdeldycke/awesome-falsehood)

---

*Document generated on July 26, 2026 for the TrackBit project.*
*Source knowledge from "Every Programmer Should Know" by mtdvio (CC-BY-4.0 License).*
