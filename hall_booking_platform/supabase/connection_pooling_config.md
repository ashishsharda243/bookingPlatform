# Supabase Connection Pooling Configuration

> Requirement 18.5: The Platform SHALL use database connection pooling via
> Supabase to handle concurrent requests efficiently.

## Overview

Supabase uses **PgBouncer** as its built-in connection pooler. It sits between
the application and PostgreSQL, reusing database connections to reduce overhead
and support high concurrency.

## Recommended Settings (Supabase Dashboard)

Navigate to **Project Settings → Database → Connection Pooling** and apply:

| Setting              | Recommended Value | Notes                                      |
|----------------------|-------------------|--------------------------------------------|
| Pool Mode            | `transaction`     | Best for serverless / short-lived queries   |
| Pool Size            | `15`              | Default; increase for >10k concurrent users |
| Connection Timeout   | `10` seconds      | Fail fast on pool exhaustion                |
| Idle Timeout         | `30` seconds      | Release idle connections promptly            |

## Client Configuration

Use the **pooler connection string** (port `6543`) instead of the direct
connection string (port `5432`) for all application traffic:

```
# Direct (for migrations only)
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Pooled (for application use)
postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
```

The `supabase_flutter` SDK automatically uses the pooled endpoint when
initialized with the project URL and anon key.

## Scaling Notes

- For **< 10,000 users**: default pool size of 15 is sufficient.
- For **10,000–100,000 users**: increase pool size to 25–50 and consider
  upgrading the Supabase plan for higher connection limits.
- Monitor connection usage via the Supabase Dashboard **Database → Connections**
  panel.
