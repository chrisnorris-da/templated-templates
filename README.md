# template-templates

Generate daml templates using a `template.yaml` file:

```yaml
module-name: RoleModel

templates:
  - base:
     baseName: AssetOwner
     signatory : operator
     operator : owner
    derive:
       name: Invitation
  - base:
     baseName: AssetOwner2
     signatory : operator2
     operator : owner2
    derive:
       name: Invitation2
```

Run `stack install` and use the cli:
```shell
$ template-templates generate conf/templates.yaml
```


To generate the following in a `RoleModel.daml` file:

```haskell
module RoleModel where

template AssetOwner
  with
    operator : Party
    owner : Party
  where
    signatory operator, owner
    key (operator, owner) : (Party, Party)
    maintainer key._1

template AssetOwnerInvitation
  with
    operator : Party
    owner : Party
  where
    signatory operator
    observer owner
    key (operator, owner) : (Party, Party)
    maintainer key._1

    choice AcceptAssetOwnerInvitation: ContractId AssetOwner
      controller owner
      do
        create AssetOwner with ..

template AssetOwner2
  with
    operator2 : Party
    owner2 : Party
  where
    signatory operator2, owner2
    key (operator2, owner2) : (Party, Party)
    maintainer key._1

template AssetOwner2Invitation2
  with
    operator2 : Party
    owner2 : Party
  where
    signatory operator2
    observer owner2
    key (operator2, owner2) : (Party, Party)
    maintainer key._1

    choice AcceptAssetOwner2Invitation2: ContractId AssetOwner2
      controller owner2
      do
        create AssetOwner2 with ..

```

```shell
$ template-templates generate --help
Usage: template-templates generate YAML_FILE
  Generate a template from the template.yaml file

Available options:
  -h,--help                Show this help text
  YAML_FILE                Path to template.yaml file
```