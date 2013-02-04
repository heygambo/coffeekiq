# CoffeeKiq

Coffeescript/Node.js Library to enqueue jobs to the Sidekiq Queue.

This is a very trivial implementation. I will implement more features when I need them.
Feel free to contribute.


## USAGE

You can add `coffeekiq: "~>0.0.1"` into your `package.json` or use `npm install coffeekiq`

```coffeescript
# Creates an instance of CoffeeKiq
CoffeeKiq = require('coffeekiq').CoffeeKiq
coffeekiq = new CoffeeKiq "redis_port", "redis_host"

# Enqueues a Job to redis namespace: "" and retry: false
coffeekiq.perform 'queue', 'WorkerClass', ['arg1', 'arg2']

# Enqueues a Job to redis with namespace: "myapp:staging" and retry: true
coffeekiq.perform 'queue', 'WorkerClass', ['arg1', 'arg2']
  namespace: "myapp:staging"
  retry: true

```
