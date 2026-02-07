# API examples

## Register
```bash
curl -X POST http://localhost:8000/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"changeme","role":"CONSUMER"}'
```

## Propose center
```bash
curl -X POST http://localhost:8000/api/centers/propose/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name":"North Hub","address_line1":"123 Main St","city":"Denver","state":"CO","postal_code":"80202","country":"US"}'
```

## Create listing
```bash
curl -X POST http://localhost:8000/api/listings/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"plant":1,"type":"PRODUCE","unit":"lb","price":"4.50","quantity_available":10}'
```

## Browse listings
```bash
curl "http://localhost:8000/api/listings/?address=123%20Main%20St%2C%20Denver%2C%20CO"
```

## Checkout
```bash
curl -X POST http://localhost:8000/api/orders/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"distribution_center":1,"pickup_window":"2026-02-10 10:00-12:00"}'
```
