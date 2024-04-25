function handler(event) {
    // Action #1 - Return a 301 redirect to the root domain if www version of website is requested
    const request = event.request;
    const hostHeader = request.headers.host.value;

    // Regular expression to extract the top-level domain and root domain
    const domainRegex = /(?:.*\.)?([a-z0-9\-]+\.[a-z]+)$/i;
    const domainMatch = hostHeader.match(domainRegex);

    // If the host starts with 'www.' construct and return the redirect response
    if (domainMatch && hostHeader.startsWith('www.')) {
        const rootDomain = domainMatch[1];

        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                "location": { "value": `https://${rootDomain}${request.uri}` },
                "cache-control": { "value": "max-age=3600" }
            }
        };
    }

    // Action #2 - Rewrite URL to append index.html for statically generated websites
    const uri = request.uri;

    // Check whether the URI is missing a file name
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } 
    // Check whether the URI is missing a file extension
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
