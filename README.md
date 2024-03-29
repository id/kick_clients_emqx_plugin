# EMQX Plugin to kick client via publishing an MQTT message

Publish an MQTT message to `kick/<client_id>` to kick a client from the broker.
Plugin is configured to work with EMQX e5.5.1.

## Usage

```
make rel
cp ./_build/default/emqx_plugrel/kick_clients_emqx_plugin-1.0.0.tar.gz ./
```

Then upload `kick_clients_emqx_plugin-1.0.0.tar.gz` to EMQX Dashboard's Management/Extensions/Plugins page.

See [EMQX documentation](https://docs.emqx.com/en/enterprise/latest/extensions/plugins.html) for details on how to deploy custom plugins.
