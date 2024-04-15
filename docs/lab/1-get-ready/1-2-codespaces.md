---
title: Setup Codespaces
parent: Get Ready
has_children: false
permalink: /lab1/codespaces
nav_order: 2
---

# Setup Codespace

You can run this application in a [GitHub Codespace](https://docs.github.com/en/codespaces/developing-in-codespaces/creating-a-codespace). This is useful for development and testing.

1. Open the [ACA Dapr Workshop GitHub](https://github.com/reidav/aca-dapr-openai-workshop)

2. Click the `Open in Codespaces` button

![Alt text](images/open-codespaces-1.png)

3. Click the `Change options` button

![Alt text](images/open-codespaces-2.png)

4. Select the `lab` branch, the `aca-dapr-openai-workshop` dev container configuration and click `create codespace`.

![Alt text](images/open-codespaces-3.png)

5. Wait for the Codespace to be created

> As we've been using GitHub Codespaces prebuild feature, Codespace should be ready in a few seconds. Click here to learn more [about prebuilds](https://docs.github.com/en/codespaces/prebuilding-your-codespaces/about-github-codespaces-prebuilds).

![Alt text](images/open-codespaces-5.png)

6. Once the Codespace is ready, you can start working on the dev container through the browser or you can also connect to it using Visual Studio Code 

![Alt text](images/open-codespaces-4.png)

> In case you're having the error message "Address already in use - bind", you can use the following command to free the address in use: `sudo lsof -i :8080` and then `sudo kill -9 <PID>`