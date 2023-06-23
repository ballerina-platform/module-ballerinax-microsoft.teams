Ballerina Microsoft Teams Connector
===================
[![Build Status](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.teams.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
 
[Microsoft Teams](https://www.microsoft.com/en-ww/microsoft-teams/group-chat-software) is a chat-based collaboration 
platform complete with document sharing, online meetings, and many more extremely useful features for business 
communications. It provides the capability to connect to the MS Teams platform API in Microsoft Graph via Ballerina. 
It allows you to perform basic functionalities provided in MS Teams such as sending messages, viewing messages, 
creating teams, channels, and chats, deleting and updating resources, etc., programmatically. This version of the 
connector only supports the access to the resources and information of a specific account (currently logged-in user).
 
For more information, see module(s).
- [microsoft.teams](teams/Module.md)
 
## Building from the source
### Setting up the prerequisites
1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).
   > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.
 
2. Download and install [Ballerina Swan Lake](https://ballerina.io/)

### Building the source
 
Execute the following commands to build from the source:
 
- To build the package:
   ```   
   bal pack ./teams
   ```
- To run tests after build:
   ```
   bal test ./teams
   ```
## Contributing to ballerina
 
As an open source project, Ballerina welcomes contributions from the community.
 
For more information, see [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).
 
## Code of conduct
 
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
 
## Useful links

* Discuss code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
