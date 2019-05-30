# elife-jats-2-dar-jats

## Requirements

- node
- zorba (to use convert.sh)

## Install

```bash
./setup.sh
```

## Convert files

Convert all files, run

```bash
./convert.sh
```

Edit the regex in the convert.sh find command to convert only a subset of XML files.

## Validate

Validate all files, run

```bash
./validate.sh
```

Edit the regex for find in the script to validate a subset of XML files.

Validate detail: run

```bash
./validate.sh detail
```

will print the detailed schema validation error message if the validation fails.

## Roadmap

Would like to use docker to install and run some of the dependencies.

