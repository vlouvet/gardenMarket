Remaining TODOs

1) Admin + moderation basics

 listings moderation toggles (pause/hide)

 Product & UX

Marketplace readiness: add buyer-facing search/filter by pickup day, plant type, and grow methods; add “in stock” and “pickup window” badges.
Grower onboarding: guided setup (profile, payout details, first listing) with progress tracker.
Trust signals: verified grower badges, reviews/ratings, and “grown within X miles” tags.
Notifications: email/SMS for order confirmations, pickup reminders, and order status updates.
Mobile-first polish: fast loading, large tap targets, offline-friendly gallery for booths.
Operations & Admin

Real admin moderation dashboard for listings, reports, and grower verification.
Inventory control: listing thresholds, auto‑pause on low stock, batch updates.
Order management: pick/pack lists, export to CSV for market day, QR check-in for pickup.
Distribution centers: live capacity, pickup windows, and market day scheduling.
Payments & Legal

Real payments (Stripe) with refunds and tax handling.
Terms, privacy policy, and seller agreement (especially for food safety).
Role-based access audits and proper admin account provisioning.
Infrastructure & Security

Production settings: proper ALLOWED_HOSTS, SECURE_* headers, error monitoring, and backups.
Separate media storage, CDN, and image processing (thumbnails, compression).
Rate limiting and abuse protection across public endpoints.
Observability: structured logs, metrics, uptime alerts.
Marketing & Growth

Partner landing pages for each market or nursery (custom URL and branding).
Grower referral system + buyer invite codes.
Analytics for funnel conversion, top listings, and repeat buyers.
“Market day specials” announcements with scheduled drops.
Data & Compliance

Audit trails for listing changes and order status changes.
Data export for growers (inventory, sales, payout history).
Food safety and plant health disclaimers where required.