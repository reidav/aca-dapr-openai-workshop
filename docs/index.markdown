---
title: About this workshop
layout: default
permalink: /
nav_order: 1
---

#  About this workshop

Welcome to this **Dapr, Azure Container Apps Workshop**. You'll be experimenting with Azure Serverless services in multiple labs to achieve a real world scenario. Don't worry, even if the challenges will increase in difficulty, this is a step by step lab, you will be guided through the whole process.

During this workshop you will have the instructions to complete each steps. It is recommended to search for the answers in provided resources and links before looking at the solutions placed under the 'Toggle solution' panel.

## Summarizer

**Summarizer** is an application designed to demonstrates how to build a, intelligent cloud native application using Dapr, Containers Apps and Open AI. It is composed of multiple microservices.

![SummarizeArchitecture](assets/images/summarizer-dapr-aca.png)

**Summarizer Blazor App (Front-end)** : A Blazor WebAssembly application that allows to browse all summaries and eventually queue new links to be summarized.

**Requests API (Python)** : FastAPI leveraging Dapr state management to store / get all requests of summaries. It allows to track and reuse previous summaries eventually generated. When a new completed request is created following processing, it sends a email message to the requestor.

**Requests Processor (Python)** : A Python application that allows to process summary requests in queue. If no summary has already being provided, it will prompt Azure Open AI to get a new summary. In any case, requests will be tracked using the requests API at the end of the process.


# Contributors

<ul class="list-style-none">
{% for contributor in site.github.contributors %}
  <li class="d-inline-block mr-1">
     <a href="{{ contributor.html_url }}"><img src="{{ contributor.avatar_url }}" width="32" height="32" alt="{{ contributor.login }}"/></a>
  </li>
{% endfor %}
</ul>

# Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
