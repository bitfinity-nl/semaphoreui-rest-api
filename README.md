# Semaphore UI REST API Script

**Version:** v1.0.0  
**Author:** bitfinity-nl  
**License:** MIT  

## Overview

This Bash script allows you to interact with **Ansible Semaphore UI** via its REST API.  
You can:  

- Start tasks using a template in a project  
- List all projects  
- List templates from a project  

The output is colorized JSON for readability and scrollable for large lists.  

---

## Requirements

- Bash (v4+ recommended)  
- `curl`  
- `jq` (for JSON parsing and colorized output)  

---

## Usage

```bash
# Run a task
./semaphore-ui-rest-api.sh -type run -url <http(s)://...> -token <api_key> -project <id> -template <id>

# List all projects (scrollable by default)
./semaphore-ui-rest-api.sh -type list_projects -url <http(s)://...> -token <api_key>

# List all projects without pager (direct output)
./semaphore-ui-rest-api.sh -type list_projects -url <http(s)://...> -token <api_key> --no-pager

# List templates from a project (scrollable by default)
./semaphore-ui-rest-api.sh -type list_templates -url <http(s)://...> -token <api_key> -project <id>

# List templates from a project without pager
./semaphore-ui-rest-api.sh -type list_templates -url <http(s)://...> -token <api_key> -project <id> --no-pager
