[
  import_deps: [:ecto, :phoenix, :ash, :ash_postgres, :surface],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [
    name_attribute: 1,
    library_version_attribute: 1
  ]
]
