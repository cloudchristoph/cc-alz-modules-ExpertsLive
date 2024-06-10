# CloudChristoph Azure Landing Zone Modules

## Goal

This is an example repo showing how to use the new Azure Verified Modules to create Azure Landing Zones.

## Usage

| Folder       | Content                                                                                  |
| ------------ | ---------------------------------------------------------------------------------------- |
| alz          | Landing Zone definitions for the fictional "Cloud Christoph Company"                     |
| base-modules | Base module approach. Can be used by landing zones                                       |
| standards    | Defines constants, helpers and a Naming Convention. Used by the Landing Zone definitions |
| examples     | Example scripts, Landing Zone parameter files and stuff for the session                  |

## Requirements

All modules are written in Bicep and require either the Azure CLI or Azure PowerShell as well as the Bicep extensions to work.

Tested with:

- PowerShell 7.4.2
- Bicep 0.27.1

## Contributing

Please feel free to contribute to this repo or ask questions. If you want, you can reach out to me on Twitter: [@cloudchristoph](https://twitter.com/cloudchristoph)
