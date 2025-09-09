#!/bin/bash
#
# MIT License
# (c) 2025 bitfinity-nl
# Version: v1.0.0
#

SCRIPT_VERSION="v1.0.0"

print_help() {
    echo ""
    echo "This script interacts with Ansible Semaphore UI via the REST API."
    echo ""
    echo "Usage:"
    echo "  Run a task:        $0 -type run -url <http(s)://...> -token <api_key> -project <id> -template <id>"
    echo "  List all projects: $0 -type list_projects -url <http(s)://...> -token <api_key> [--no-pager]"
    echo "  List templates:    $0 -type list_templates -url <http(s)://...> -token <api_key> -project <id> [--no-pager]"
    echo ""
    echo "Options:"
    echo "  -type      Action type (run, list_projects, list_templates)"
    echo "  -url       URL of the Ansible Semaphore UI (must start with http:// or https://)"
    echo "  -token     API token from Ansible Semaphore UI"
    echo "  -project   Project ID (numeric, required for run and list_templates)"
    echo "  -template  Template ID (numeric, required for run)"
    echo "  --no-pager Show output directly without paging"
    echo "  -h, --help Show this help message"
    echo "  -v, --version Show script version"
    echo ""
    echo "Version: $SCRIPT_VERSION"
    echo "------------------------------------------------------------"
    echo " MIT License"
    echo " (c) 2025 bitfinity-nl"
    echo "------------------------------------------------------------"
    echo ""
    exit 0
}

print_version() {
    echo "$SCRIPT_VERSION"
    exit 0
}

check_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: 'jq' is required for this operation but is not installed."
        echo "Please install jq and try again."
        exit 1
    fi
}

validate_url() {
    if [[ ! "$SEMAPHORE_URL" =~ ^https?:// ]]; then
        echo "Error: -url must start with http:// or https://"
        exit 1
    fi
}

curl_wrapper() {
    local response
    local http_code

    response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" "$@")
    http_code="${response: -3}"
    body="${response:0:-3}"

    if [[ "$http_code" =~ ^2 ]]; then
        echo "$body" | jq --color-output .
    else
        echo "Error: API request failed with HTTP status $http_code"
        echo "Response body: $body"
        exit 1
    fi
}

run_task() {
    if [[ -z "$SEMAPHORE_URL" || -z "$TOKEN" || -z "$PROJECT_ID" || -z "$TEMPLATE_ID" ]]; then
        echo "Error: -url, -token, -project, and -template are required for -type run."
        exit 1
    fi

    validate_url

    if [[ ! "$PROJECT_ID" =~ ^[0-9]+$ ]]; then
        echo "Error: -project must be numeric"
        exit 1
    fi

    if [[ ! "$TEMPLATE_ID" =~ ^[0-9]+$ ]]; then
        echo "Error: -template must be numeric"
        exit 1
    fi

    curl_wrapper -X POST "$SEMAPHORE_URL/api/project/$PROJECT_ID/tasks" -d '{"template_id": '"$TEMPLATE_ID"'}'
}

list_projects() {
    check_jq
    if [[ -z "$SEMAPHORE_URL" || -z "$TOKEN" ]]; then
        echo "Error: -url and -token required for list_projects."
        exit 1
    fi

    validate_url

    if [[ "$NO_PAGER" == true ]]; then
        curl_wrapper -X GET "$SEMAPHORE_URL/api/projects"
    else
        curl_wrapper -X GET "$SEMAPHORE_URL/api/projects" | less -R
    fi
}

list_templates() {
    check_jq
    if [[ -z "$SEMAPHORE_URL" || -z "$TOKEN" || -z "$PROJECT_ID" ]]; then
        echo "Error: -url, -token, and -project required for list_templates."
        exit 1
    fi

    validate_url

    if [[ "$NO_PAGER" == true ]]; then
        curl_wrapper "$SEMAPHORE_URL/api/project/$PROJECT_ID/templates"
    else
        curl_wrapper "$SEMAPHORE_URL/api/project/$PROJECT_ID/templates" | less -R
    fi
}

# Default pager
NO_PAGER=false

if [[ "$#" -eq 0 ]]; then
    print_help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -type) TYPE="$2"; shift ;;
        -url) SEMAPHORE_URL="$2"; shift ;;
        -token) TOKEN="$2"; shift ;;
        -project) PROJECT_ID="$2"; shift ;;
        -template) TEMPLATE_ID="$2"; shift ;;
        --no-pager) NO_PAGER=true ;;
        -h|--help) print_help ;;
        -v|--version) print_version ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h for help."
            exit 1
            ;;
    esac
    shift
done

case "$TYPE" in
    run) run_task ;;
    list_projects) list_projects ;;
    list_templates) list_templates ;;
    *)
        echo "Error: unsupported or missing -type."
        echo "Use -h for help."
        exit 1
        ;;
esac
