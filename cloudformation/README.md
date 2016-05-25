From Zero to Cloud
==================

Use `bundler install && rake` to build the templates.

If you don't have a Ruby environment you can use Docker as well:

```
docker run -it --rm -v $PWD:/app -w /app ruby sh -c "bundler install && rake"
```