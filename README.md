# appsync-family-video-api

Builds an AWS app-sync api which

1. connects to a pre existing lambda
2. lambda creates a s3 url for upload
3. api resturns payload with url or error

## deployment

through terraform

1. terraform init
2. terraform apply

# definitions

In

```
 api/schema/schema.graphql
```

## schema

```
enum UrlType {
  UPLOAD
  DOWNLOAD
}

type Query {
  getPresignedUrl(key: String!, bucket: String!, urlType: UrlType!): response
}

type response {
  statusCode: Int
  body: String
}

schema {
  query: Query
}
```
