# Clever Cloud deployment

## Setup

### Clever Cloud interface

Create 2 Node.js applications with the `XS` plan:
* `chatwoot`
* `chatwoot-staging`

And 2 PostgreSQL databases (version 12) with any plan that you will binding to each app accordingly:
* `chatwoot`
* `chatwoot-staging`

_For the staging environment it's fine to choose the database plan named `DEV` (lowest plan), but sometimes it may break with a `FATAL: too many connections` error, so a solution is to add a specific parameter to the database URL (`DATABASE_URL=xxx?connection_limit=1`) to keep connections under the limit._

Add 2 Cellar addons:
* `chatwoot`
* `chatwoot-staging`

And create respectively inside them the buckets:
* `betagouv-chatwoot-assets` _(to be created into `chatwoot` addon)_
* `betagouv-chatwoot-staging-assets` _(to be created into `chatwoot-staging` addon)_

Add 2 Redis addons with the `S` plan:
* `chatwoot`
* `chatwoot-staging`

_(depending on when you created those addonds, don't forget to bind them to the appropriate application)_

Now set for both apps these options:
* Zero downtime deployment
* Enable dedicated build instance: `XL`
* Cancel ongoing deployment on new push
* Force HTTPS

Adjust the domain names as you want, and configure the environment variables as follow:
* `ACTIVE_STORAGE_SERVICE`: `s3_compatible`
* `CC_NODE_VERSION`: `20` _(needed since Clever Cloud does not retrieve the Node version from `package.json` due to being in a Rails application)_
* `CC_POST_BUILD_HOOK`: `RAILS_ENV=production rails assets:precompile`
* `CC_PRE_BUILD_HOOK`: `yarn install`
* `CC_PRE_RUN_HOOK`: `rake db:chatwoot_prepare`
* `CC_RACKUP_SERVER`: `puma`
* `DATABASE_URL`: [GENERATED] _(provided by the interface, but you must add as query parameter `sslmode=prefer`)_
* `DEFAULT_LOCALE`: `fr`
* `ENABLE_ACCOUNT_SIGNUP`: `false`
* `FORCE_SSL`: `true`
* `FRONTEND_URL`: `https://${YOUR_DOMAIN}`
* `MAILER_INBOUND_EMAIL_DOMAIN`: `${YOUR_EMAIL_DOMAIN}`
* `MAILER_SENDER_EMAIL`: `Chatwoot beta.gouv <chatwoot@${YOUR_EMAIL_DOMAIN}>`
* `PORT`: `8080`
* `RAILS_ENV`: `production`
* `SECRET_KEY_BASE`: [SECRET]
* `SENTRY_DSN`: [GENERATED] _(format `https://xxx.yyy.zzz/nn`)_
* `SENTRY_ENVIRONMENT`: `prod` or `staging` _(depending on the instance you deploy)_
* `SMTP_ADDRESS`: [GENERATED]
* `SMTP_AUTHENTICATION`: `plain`
* `SMTP_ENABLE_STARTTLS_AUTO`: `true`
* `SMTP_PASSWORD`: [SECRET]
* `SMTP_PORT`: `587` _(may be different)_
* `SMTP_USERNAME`: [SECRET]
* `STORAGE_ACCESS_KEY_ID`: [GENERATED]
* `STORAGE_BUCKET_NAME`: [TO_DEFINE] _(refering to the bucket you created, knowing most of the time this is a unique value across your S3 provider)_
* `STORAGE_ENDPOINT`: [GENERATED]
* `STORAGE_REGION`: [GENERATED]
* `STORAGE_SECRET_ACCESS_KEY`: [GENERATED]

### GitHub interface

#### GitHub Actions

Configure the following repository secrets (not environment ones):

- `CLEVER_APP_ID_PRODUCTION`: [GENERATED] _(format `app_{uuid}`, can be retrieved into the Clever Cloud interface)_
- `CLEVER_APP_ID_STAGING`: [GENERATED] _(format `app_{uuid}`, can be retrieved into the Clever Cloud interface)_
- `CLEVER_TOKEN`: [GENERATED] _(can be retrieved from `clever login`, but be warned it gives wide access)_
- `CLEVER_SECRET`: [GENERATED] _(can be retrieved from `clever login`, but be warned it gives wide access)_

## Upgrade Chatwoot version

1. Synchronize your fork with the original repository
2. Search for the specific commit representing the wanted version
3. Rebase your `deploy` or `deploy-staging` branches to it while making sure to not take third-party files into `.github`
4. Force-push the branch
