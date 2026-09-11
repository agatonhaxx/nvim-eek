# Redis Snippets

Complete copy-paste artifacts extracted from know-how/redis.md.

## Distributed Lock (Lua)

```bash
# Distributed lock (Redlock / single-node simple)
SET lock:resource random-token NX EX 30
# Do work...
# Release only if you still own it:
EVAL "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) end" 1 lock:resource random-token
```

## Rate Limiting (sorted set)

```bash
# Rate limiting (sliding window with sorted set)
ZREMRANGEBYSCORE ratelimit:user:123 0 $(date -d '1 min ago' +%s%3N)
ZADD ratelimit:user:123 $(date +%s%3N) $(date +%s%N)
ZCOUNT ratelimit:user:123 0 +inf
# If count > limit → reject
```
