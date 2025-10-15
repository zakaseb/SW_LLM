/**
 * Get the absolute API URL for the LangGraph API
 * 
 * This function handles both relative paths (e.g., "/api") and absolute URLs (e.g., "http://localhost:3000/api").
 * 
 * - On the client side: Converts relative paths to absolute URLs using window.location.origin
 * - On the server side: Returns the value as-is (Next.js will handle it)
 * 
 * @returns The absolute API URL
 */
export function getApiUrl(): string {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL || "/api";

  // If it's already an absolute URL, return it
  if (apiUrl.startsWith("http://") || apiUrl.startsWith("https://")) {
    return apiUrl;
  }

  // If it's a relative path and we're on the client, convert to absolute URL
  if (typeof window !== "undefined") {
    const baseUrl = window.location.origin;
    const fullUrl = apiUrl.startsWith("/") ? `${baseUrl}${apiUrl}` : `${baseUrl}/${apiUrl}`;
    return fullUrl;
  }

  // Server-side: return as-is (this shouldn't happen for client components)
  // If this gets called server-side, we'll return a default localhost URL
  return `http://localhost:3001${apiUrl.startsWith("/") ? apiUrl : `/${apiUrl}`}`;
}

